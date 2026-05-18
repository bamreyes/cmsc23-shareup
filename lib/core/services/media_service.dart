import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:project/core/utils/result.dart';

class MediaService {
  final ImagePicker _picker = ImagePicker();

  Future<Result<File>> pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (picked != null) {
        return Result.success(File(picked.path));
      }
      return Result.error('No image selected');
    } catch (e) {
      return Result.error(e.toString());
    }
  }
}
