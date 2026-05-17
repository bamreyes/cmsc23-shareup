import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/core/models/user_model.dart';
import '../models/post_model.dart';
import '../models/request_model.dart';
import 'package:project/core/utils/result.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Result<bool>> createPost(PostModel post) async {
    try {
      await _firestore.collection('posts').add(post.toJson());
      return Result.success(true);
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  /// Updates an existing post 
  Future<Result<bool>> updatePost(
    String postId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('posts').doc(postId).update(updates);
      return Result.success(true);
    } catch (e) {
      print("Error updating post: $e");
      return Result.error(e.toString());
    }
  }

  /// Updates an existing request document
  Future<Result<bool>> updateRequest(
    String requestId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('requests').doc(requestId).update(updates);
      return Result.success(true);
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  /// Fetches a specific post (Used if Item View needs fresh data)
  Future<Result<PostModel?>> getPostById(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (doc.exists && doc.data() != null) {
        return Result.success(PostModel.fromJson(doc.data()!, doc.id));
      }
      return Result.error("No post with id exists");
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> getRequestDetailsByPostId(String postId) async {
    try {
      final postResult = await getPostById(postId);
      if (postResult.isSuccess && postResult.data != null) {
        final post = postResult.data!;
        final userResult = await getUserById(post.userId);
        if (userResult.isSuccess && userResult.data != null) {
          return Result.success({
            'post': post,
            'owner': userResult.data!,
          });
        }
        return Result.error(userResult.error ?? "Failed to fetch user");
      }
      return Result.error(postResult.error ?? "Failed to fetch post");
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  Future<Result<RequestModel>> getRequestByPostId(String postId) async {
    try {
      final snapshot = await _firestore
          .collection('requests')
          .where('postId', isEqualTo: postId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final req = RequestModel.fromJson(
            snapshot.docs.first.data(), snapshot.docs.first.id);
        final finalReq = await _autoCancelIfExpired(req);
        return Result.success(finalReq);
      }
      return Result.error("Request not found");
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  /// Gets the accepted request for a post 
  Future<Result<RequestModel>> getAcceptedRequestByPostId(String postId) async {
    try {
      final snapshot = await _firestore
          .collection('requests')
          .where('postId', isEqualTo: postId)
          .where('status', isEqualTo: RequestStatus.accepted.name)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final req = RequestModel.fromJson(
            snapshot.docs.first.data(), snapshot.docs.first.id);
        final finalReq = await _autoCancelIfExpired(req);
        return Result.success(finalReq);
      }
      return Result.error("Accepted request not found");
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  /// Gets all requests for a post 
  Future<Result<List<RequestModel>>> getRequestsForPost(String postId) async {
    try {
      final snapshot = await _firestore
          .collection('requests')
          .where('postId', isEqualTo: postId)
          .orderBy('createdAt', descending: true)
          .get();

      final requests = snapshot.docs
          .map((doc) => RequestModel.fromJson(doc.data(), doc.id))
          .toList();
      
      final List<RequestModel> finalRequests = [];
      for (final req in requests) {
        finalRequests.add(await _autoCancelIfExpired(req));
      }
      return Result.success(finalRequests);
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  Future<Result<List<PostModel>>> getMyPosts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final myPosts = snapshot.docs
          .map((doc) => PostModel.fromJson(doc.data(), doc.id))
          .toList();
      return Result.success(myPosts);
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  Future<Result<List<PostModel>>> getAllPosts() async {
    try {
      final snapshot = await _firestore.collection('posts').get();
      final posts = snapshot.docs
          .map((doc) => PostModel.fromJson(doc.data(), doc.id))
          .toList();
      return Result.success(posts);
    } on FirebaseException catch (e) {
      return Result.error(e.message ?? "An error occurred fetching posts");
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  Future<Result<List<PostModel>>> getCompletedPosts() async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .where('status', isEqualTo: PostStatus.completed.name)
          .get();
      final posts = snapshot.docs
          .map((doc) => PostModel.fromJson(doc.data(), doc.id))
          .toList();
      return Result.success(posts);
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  Future<Result<UserModel>> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return Result.success(
          UserModel.fromMap({...doc.data()!, 'uid': doc.id}),
        );
      }
      return Result.error("User not found");
    } catch (e) {
      return Result.error(e.toString());
    }
  }


  Future<Result<RequestModel>> createRequest(RequestModel request) async {
    try {
      // First check if user already has an ACTIVE request for this post
      final existingReq = await _firestore
          .collection('requests')
          .where('postId', isEqualTo: request.postId)
          .where('requesterId', isEqualTo: request.requesterId)
          .where('status', whereIn: [
            RequestStatus.pending.name,
            RequestStatus.accepted.name,
          ])
          .get();

      if (existingReq.docs.isNotEmpty) {
        return Result.error("You have already requested this item");
      }

      return await _firestore.runTransaction((transaction) async {
        final postRef = _firestore.collection('posts').doc(request.postId);
        final postDoc = await transaction.get(postRef);

        if (!postDoc.exists) {
          return Result.error("Post not found");
        }

        final currentStatus = postDoc.data()?['status'];

        if (currentStatus != PostStatus.available.name) {
          return Result.error("Item already reserved!");
        }

        final requestRef = _firestore.collection('requests').doc();
        transaction.set(requestRef, request.toJson());

        final createdRequest = RequestModel(
          id: requestRef.id,
          postId: request.postId,
          requesterId: request.requesterId,
          pickupDatetime: request.pickupDatetime,
          message: request.message,
          status: request.status,
          createdAt: request.createdAt,
        );

        return Result.success(createdRequest);
      });
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  Future<Result<List<RequestModel>>> getMyRequests(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('requests')
          .where('requesterId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      final requests = snapshot.docs
          .map((doc) => RequestModel.fromJson(doc.data(), doc.id))
          .toList();
      
      final List<RequestModel> finalRequests = [];
      for (final req in requests) {
        finalRequests.add(await _autoCancelIfExpired(req));
      }
      return Result.success(finalRequests);
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  Future<Result<bool>> cancelRequest(String requestId, String postId) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        final requestRef = _firestore.collection('requests').doc(requestId);
        final postRef = _firestore.collection('posts').doc(postId);

        final requestDoc = await transaction.get(requestRef);
        final postDoc = await transaction.get(postRef);

        if (!requestDoc.exists || !postDoc.exists) {
          return Result.error("Request or Post not found");
        }

        final requesterId = requestDoc.data()?['requesterId'];
        final receiverIdOnPost = postDoc.data()?['receiverId'];

        transaction.update(requestRef, {
          'status': RequestStatus.cancelled.name,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (postDoc.data()?['status'] == PostStatus.reserved.name &&
            receiverIdOnPost == requesterId) {
          transaction.update(postRef, {
            'status': PostStatus.available.name,
            'receiverId': null,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        return Result.success(true);
      });
    } catch (e) {
      return Result.error(e.toString());
    }
  }
  
  Future<Result<bool>> acceptRequest(String requestId, String postId) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        final requestRef = _firestore.collection('requests').doc(requestId);
        final postRef = _firestore.collection('posts').doc(postId);

        final otherRequestsQuery = await _firestore
            .collection('requests')
            .where('postId', isEqualTo: postId)
            .where('status', isEqualTo: RequestStatus.pending.name)
            .get();

        final requestDoc = await transaction.get(requestRef);
        final postDoc = await transaction.get(postRef);

        if (!requestDoc.exists || !postDoc.exists) {
          return Result.error("Request or Post not found");
        }

        final currentPostStatus = postDoc.data()?['status'];
        if (currentPostStatus != PostStatus.available.name) {
          return Result.error("This item is no longer available to accept");
        }

        final requesterId = requestDoc.data()?['requesterId'];

        transaction.update(requestRef, {
          'status': RequestStatus.accepted.name,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        transaction.update(postRef, {
          'status': PostStatus.reserved.name,
          'receiverId': requesterId,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        for (var doc in otherRequestsQuery.docs) {
          if (doc.id != requestId) {
            transaction.update(doc.reference, {
              'status': RequestStatus.rejected.name,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
        return Result.success(true);
      });
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  Future<Result<bool>> rejectRequest(String requestId) async {
    try {
      final requestRef = _firestore.collection('requests').doc(requestId);
      
      await requestRef.update({
        'status': RequestStatus.rejected.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return Result.success(true);
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  // Called when the poster scans the receiver's QR code.
  Future<Result<String>> completePostByQr({
    required String postId,
    required String scannerId,
  }) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        final postRef = _firestore.collection('posts').doc(postId);
        final postDoc = await transaction.get(postRef);

        if (!postDoc.exists) {
          return Result.error("Post not found.");
        }

        final data = postDoc.data()!;
        final postOwnerId = data['userId'] as String?;
        final currentStatus = data['status'] as String?;

        // Only the post owner can complete via QR
        if (postOwnerId != scannerId) {
          return Result.error(
            "Only the item owner can complete this exchange.",
          );
        }

        if (currentStatus == PostStatus.completed.name) {
          return Result.error("This item has already been completed.");
        }

        if (currentStatus != PostStatus.reserved.name) {
          return Result.error(
            "This item is not currently reserved.",
          );
        }

        // Find the accepted request so we can mark it completed too
        final reqSnapshot = await _firestore
            .collection('requests')
            .where('postId', isEqualTo: postId)
            .where('status', isEqualTo: RequestStatus.accepted.name)
            .limit(1)
            .get();

        transaction.update(postRef, {
          'status': PostStatus.completed.name,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (reqSnapshot.docs.isNotEmpty) {
          final reqRef = reqSnapshot.docs.first.reference;
          transaction.update(reqRef, {
            'status': RequestStatus.completed.name,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        return Result.success("Exchange completed successfully!");
      });
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  Future<RequestModel> _autoCancelIfExpired(RequestModel req) async {
    if ((req.status == RequestStatus.pending || req.status == RequestStatus.accepted) &&
        req.pickupDatetime.isBefore(DateTime.now())) {
      try {
        await cancelRequest(req.id!, req.postId);
        return RequestModel(
          id: req.id,
          postId: req.postId,
          requesterId: req.requesterId,
          pickupDatetime: req.pickupDatetime,
          message: req.message,
          status: RequestStatus.cancelled,
          createdAt: req.createdAt,
        );
      } catch (_) {
        return req;
      }
    }
    return req;
  }
}