import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({
    super.key,
    required this.onPickImage,
  });

  final void Function(dynamic)
      onPickImage; // Accepts File (mobile) or Uint8List (web)

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImageFile;
  Uint8List? _pickedImageBytes; // Web image storage

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery, // Change to ImageSource.camera if needed
      imageQuality: 50,
      maxWidth: 150,
    );

    if (pickedImage == null) return;

    if (kIsWeb) {
      // Handle web image as Uint8List
      Uint8List imageBytes = await pickedImage.readAsBytes();
      setState(() {
        _pickedImageBytes = imageBytes;
      });

      widget.onPickImage(imageBytes);
    } else {
      // Handle mobile image as File
      File imageFile = File(pickedImage.path);
      setState(() {
        _pickedImageFile = imageFile;
      });

      widget.onPickImage(imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
            image: _pickedImageBytes != null
                ? DecorationImage(
                    image: MemoryImage(_pickedImageBytes!), // Web
                    fit: BoxFit.cover,
                  )
                : _pickedImageFile != null
                    ? DecorationImage(
                        image: FileImage(_pickedImageFile!), // Mobile
                        fit: BoxFit.cover,
                      )
                    : null,
          ),
        ),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
          label: Text(
            'Add Image',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
