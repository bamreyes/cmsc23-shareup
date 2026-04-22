import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/core/utils/result.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Result<void>> addUser(UserModel user) async {
    try {
      await _db.collection('users').doc(user.uid).set(user.toMap());
      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.error(
        e.message ?? "An error occurred adding user to database",
      );
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  Future<Result<bool>> isEmailUnique(String email) async {
    if (email.isEmpty) return Result.success(true);

    try {
      final snapshot = await _db
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return Result.success(snapshot.docs.isEmpty);
    } on FirebaseException catch (e) {
      return Result.error(e.message ?? "Database error occurred");
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  Future<Result<bool>> isUsernameUnique(String username) async {
    if (username.isEmpty) return Result.success(true);

    try {
      final snapshot = await _db
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      return Result.success(snapshot.docs.isEmpty);
    } on FirebaseException catch (e) {
      return Result.error(e.message ?? "Database error occurred");
    } catch (e) {
      return Result.error(e.toString());
    }
  }
}
