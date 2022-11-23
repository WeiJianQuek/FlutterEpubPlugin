import 'dart:typed_data';

/// Manifest declare all the resources that will be used in epub
class ManifestEpubModel {
  final String id;
  final String filePath;
  final String mediaType;
  final Uint8List? data;

  const ManifestEpubModel({
    required this.id,
    required this.filePath,
    required this.mediaType,
    required this.data,
  });
}

class MutableManifestEpubModel {
  String id;
  String filePath;
  String mediaType;
  Uint8List? data;

  MutableManifestEpubModel({
    this.id = '',
    this.filePath = '',
    this.mediaType = '',
    this.data,
  });

  ManifestEpubModel toImmutable() {
    return ManifestEpubModel(
      id: id,
      filePath: filePath,
      mediaType: mediaType,
      data: data,
    );
  }
}
