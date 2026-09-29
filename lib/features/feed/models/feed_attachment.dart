import 'dart:io';

enum FeedAttachmentType { image, document, audio, video }

class FeedAttachment {
  const FeedAttachment({
    required this.url,
    required this.name,
    required this.type,
    required this.size,
  });

  final String url;
  final String name;
  final FeedAttachmentType type;
  final int size;

  factory FeedAttachment.fromMap(Map<String, dynamic> map) => FeedAttachment(
    url: map['url'] as String? ?? '',
    name: map['name'] as String? ?? 'Archivo',
    type: FeedAttachmentType.values.firstWhere(
      (value) => value.name == map['type'],
      orElse: () => FeedAttachmentType.document,
    ),
    size: map['size'] as int? ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'url': url,
    'name': name,
    'type': type.name,
    'size': size,
  };
}

class PendingFeedAttachment {
  const PendingFeedAttachment({
    required this.file,
    required this.name,
    required this.type,
    required this.size,
  });

  final File file;
  final String name;
  final FeedAttachmentType type;
  final int size;

  String get contentType {
    final extension = name.split('.').last.toLowerCase();
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'pdf' => 'application/pdf',
      'm4a' => 'audio/mp4',
      'wav' => 'audio/wav',
      'mov' => 'video/quicktime',
      'mp4' => 'video/mp4',
      'mp3' => 'audio/mpeg',
      _ => 'image/jpeg',
    };
  }
}
