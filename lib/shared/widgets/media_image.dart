import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vecindario_app/core/services/mock_media_storage.dart';

ImageProvider<Object> mediaImageProvider(String url) {
  if (MockMediaStorage.isLocal(url)) {
    return FileImage(MockMediaStorage.fileFromUrl(url));
  }
  return NetworkImage(url);
}

class MediaImage extends StatelessWidget {
  const MediaImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    if (MockMediaStorage.isLocal(url)) {
      return Image.file(
        File(Uri.parse(url).toFilePath()),
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.broken_image_outlined)),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      placeholder: (_, __) =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      errorWidget: (_, __, ___) =>
          const Center(child: Icon(Icons.broken_image_outlined)),
    );
  }
}
