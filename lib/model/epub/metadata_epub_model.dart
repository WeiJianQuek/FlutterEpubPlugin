class MetadataEpubModel {
  final String title;
  final String author;
  final String source;
  final String identifier;
  final String publisher;
  final String language;
  final String copyright;

  const MetadataEpubModel({
    required this.title,
    required this.author,
    required this.source,
    required this.identifier,
    required this.publisher,
    required this.language,
    required this.copyright,
  });
}

class MutableMetadataEpubModel {
  String title;
  String author;
  String source;
  String identifier;
  String publisher;
  String language;
  String copyright;

  MutableMetadataEpubModel({
    this.title = '',
    this.author = '',
    this.source = '',
    this.identifier = '',
    this.publisher = '',
    this.language = '',
    this.copyright = '',
  });

  MetadataEpubModel toImmutable() {
    return MetadataEpubModel(
      title: title,
      author: author,
      source: source,
      identifier: identifier,
      publisher: publisher,
      language: language,
      copyright: copyright,
    );
  }
}
