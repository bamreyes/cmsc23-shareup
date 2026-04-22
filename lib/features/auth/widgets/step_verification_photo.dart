import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/core/widgets/buttons/primary_button.dart';
import 'package:project/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class VerificationPhoto extends StatefulWidget {
  const VerificationPhoto({super.key});

  @override
  State<VerificationPhoto> createState() => _VerificationPhotoState();
}

class _VerificationPhotoState extends State<VerificationPhoto> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return FormField(
      validator: (_) => authProvider.imageFile == null
          ? 'Verification photo is required'
          : null,
      builder: (state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (authProvider.imageFile != null)
              Image.file(
                File(authProvider.imageFile!.path),
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              ),
            Text(
              "Verification Photo",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            PrimaryButton(
              text: "Take a photo",
              onPressed: () async {
                final xFileImage = await ImagePicker().pickImage(
                  source: ImageSource.camera,
                );
                if (xFileImage != null) {
                  final image = File(xFileImage.path);
                  authProvider.setImageFile(image);
                  if (state.hasError) {
                    Future.microtask(() => state.validate());
                  }
                }
              },
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                child: Text(
                  state.errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
