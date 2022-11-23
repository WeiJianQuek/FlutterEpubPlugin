import 'book/chapter_book_model.dart';

class BookModel {
  final String title;
  final String author;
  final String source;
  final String identifier;
  final String publisher;
  final String language;
  final String copyright;
  final List<String> cssStyleList;
  final Map<String, dynamic> imageMap;
  final Map<int, ChapterBookModel> chapterModelMap;

  const BookModel({
    required this.title,
    required this.author,
    required this.source,
    required this.identifier,
    required this.publisher,
    required this.language,
    required this.copyright,
    required this.cssStyleList,
    required this.imageMap,
    required this.chapterModelMap,
  });

  List<String> get allChapterParagraphList {
    final paragraphList = <String> [];

    for (final chapterModel in chapterModelMap.values) {
      paragraphList.addAll(chapterModel.paragraphList);
    }

    return paragraphList;
  }
}

class MutableBookModel {
  String title;
  String author;
  String source;
  String identifier;
  String publisher;
  String language;
  String copyright;
  final cssStyleList = <String> [];
  final imageMapList = <String, dynamic> {};
  final chapterModelMap= <int, ChapterBookModel> {};

  MutableBookModel({
    this.title = '',
    this.author = '',
    this.source = '',
    this.identifier = '',
    this.publisher = '',
    this.language = '',
    this.copyright = '',
});

  BookModel toImmutable() {
    return BookModel(
      title: title,
      author: author,
      source: source,
      identifier: identifier,
      publisher: publisher,
      language: language,
      copyright: copyright,
      cssStyleList: cssStyleList,
      imageMap: imageMapList,
      chapterModelMap: chapterModelMap,
    );
  }
}
