/// Spine determine the arrangement of content within the epub
class SpineEpubModel {
  final String id;

  const SpineEpubModel({
    required this.id,
  });
}

class MutableSpineEpubModel {
  String id;

  MutableSpineEpubModel({
    this.id = '',
  });

  SpineEpubModel toImmutable() {
    return SpineEpubModel(
      id: id,
    );
  }
}
