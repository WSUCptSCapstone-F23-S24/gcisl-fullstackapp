import 'package:flutter/material.dart';
import 'package:image_downloader_web/image_downloader_web.dart';

class ImageDialog extends StatelessWidget {
  final String imageUrl;

  const ImageDialog({required this.imageUrl});

  Future<void> _downloadImage(BuildContext context) async {
    await WebImageDownloader.downloadImageFromWeb(imageUrl, imageQuality: 100);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Image.network(imageUrl),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  _downloadImage(context);
                },
                child: const Text('Download'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
