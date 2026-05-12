import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: FormField(
              validator: (_) => authProvider.imageFile == null
                  ? 'Verification photo is required'
                  : null,
              builder: (state) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Verification Photo",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Upload a photo of yourself for verification purposes.",
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40),
                    GestureDetector(
                      onTap: () async {
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
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: authProvider.imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(
                                  File(authProvider.imageFile!.path),
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.outline
                                        .withValues(alpha: 0.2),
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt_outlined,
                                      size: 64,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.5),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      "Tap to take a photo",
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    if (state.hasError)
                      Padding(
                        padding: EdgeInsets.only(top: 12.0),
                        child: Text(
                          state.errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
