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
}
