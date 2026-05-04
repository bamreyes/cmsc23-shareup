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
      print("Error creating post: $e");
      return Result.error(e.toString());
    }
  }

  /// Updates an existing post (Edit details)
  Future<Result<bool>> updatePost(
    String postId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updated_at'] = FieldValue.serverTimestamp();
      await _firestore.collection('posts').doc(postId).update(updates);
      return Result.success(true);
    } catch (e) {
      print("Error updating post: $e");
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

  //for creating request
  Future<Result<bool>> createRequest(RequestModel request) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        final postRef = _firestore.collection('posts').doc(request.postId);
        final postDoc = await transaction.get(postRef);

        if (!postDoc.exists) {
          return Result.error("Post not found");
        }

        final currentStatus = postDoc.data()?['status'];

        //checker for availability of item
        if (currentStatus != PostStatus.available.name) {
          return Result.error("Item already reserved!");
        }

        final requestRef = _firestore.collection('requests').doc();
        transaction.set(requestRef, request.toJson());

        transaction.update(postRef, {
          'status': PostStatus.reserved.name,
          'receiverId': request.requesterId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return Result.success(true);
      });
    } catch (e) {
      return Result.error(e.toString());
    }
  }
}
