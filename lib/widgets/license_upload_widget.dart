import 'package:flutter/material.dart';

class LicenseUploadWidget extends StatelessWidget {
  final Function(String) onImageSelected;

  const LicenseUploadWidget({super.key, required this.onImageSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Загрузите фото прав'),
        ElevatedButton.icon(
          onPressed: () {
            onImageSelected('mock_path_to_image.jpg');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Фото загружено')),
            );
          },
          icon: const Icon(Icons.upload),
          label: const Text('Загрузить'),
        ),
      ],
    );
  }
}
