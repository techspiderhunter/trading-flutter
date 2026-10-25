import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImagePickerInput extends StatelessWidget {
  final String placeholder;
  final File? selectedImage;
  final Function(File?)? onImagePicked;

  const ImagePickerInput({
    super.key,
    required this.placeholder,
    required this.selectedImage,
    this.onImagePicked,
  });

  Future pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? result = await picker.pickImage(source: ImageSource.gallery);

    if (result != null) {
      onImagePicked?.call(File(result.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: pickImage,
      child: Container(
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 0.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(Icons.image, color: Colors.grey),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                selectedImage == null ? placeholder : "Image Selected",
                style: TextStyle(fontFamily: 'DeskSans', color: Colors.grey),
              ),
            ),
            if (selectedImage != null)
              Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
