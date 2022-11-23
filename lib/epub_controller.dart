import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'model/book_model.dart';
import 'service/epub_service.dart';

const _defaultFontSize = 14.0;
const _defaultFontUpdateSize = 2.0;

class EpubController extends ChangeNotifier {
  BookModel? _bookModel;
  BookModel? get bookModel => _bookModel;

  double _fontSize = _defaultFontSize;
  double get fontSize => _fontSize;

  double _fontUpdateSize = _defaultFontUpdateSize;
  double get fontUpdateSize => _fontUpdateSize;

  String _highlightText = '';
  String get highlightText => _highlightText;

  Color? _highlightColor;
  Color? get highlightColor => _highlightColor;

  Color? _highlightOnColor;
  Color? get highlightOnColor => _highlightOnColor;

  /// Configure the epub settings
  void configure({
    final double? fontSize,
    final double? fontUpdateSize,
    final String? highlightText,
    final Color? highlightColor,
    final Color? highlightOnColor,
  }) {
    if (fontSize != null) _fontSize = fontSize;

    if (fontUpdateSize != null) _fontUpdateSize = fontUpdateSize;

    if (highlightText != null) _highlightText = highlightText;

    if (highlightColor != null) _highlightColor = highlightColor;

    if (highlightOnColor != null) _highlightOnColor = highlightOnColor;

    notifyListeners();
  }

  /// Open Epub
  void open(final Uint8List epubData) async {
    _bookModel = EpubService.decode(epubData);
    reset();
  }

  void openFile(final File epubFile) async {
    if (!epubFile.existsSync()) return;

    open(await epubFile.readAsBytes());
  }

  void openAsset(final String epubAsset) async {
    final byteData = await rootBundle.load(epubAsset);

    open(byteData.buffer.asUint8List());
  }

  /// Clear the book that's loaded
  void clear() {
    _bookModel = null;
    reset();
  }

  /// Reset all the configuration
  void reset() {
    _fontSize = _defaultFontSize;
    _fontUpdateSize = _defaultFontUpdateSize;
    _highlightText = '';
    _highlightColor = null;
    _highlightOnColor = null;
    notifyListeners();
  }

  /// Highlight Text Modification
  void setHighlightText(final String text) {
    _highlightText = text;
    notifyListeners();
  }

  void clearHighlightText() {
    setHighlightText('');
  }

  void setHighlightColor(final Color color) {
    _highlightColor = color;
    notifyListeners();
  }

  void setHighlightOnColor(final Color color) {
    _highlightOnColor = color;
    notifyListeners();
  }

  void clearHighlightColorSettings() {
    _highlightColor = null;
    _highlightOnColor = null;
    notifyListeners();
  }

  /// Font Size Modification
  void setFontSize(final double size) {
    _fontSize += size;

    notifyListeners();
  }

  void increaseFontSize([
    final double? size,
  ]) {
    _fontSize += size ?? fontUpdateSize;

    notifyListeners();
  }

  void decreaseFontSize([
    final double? size,
  ]) {
    _fontSize -= size ?? fontUpdateSize;

    notifyListeners();
  }

  void resetFontSize() {
    _fontSize -= _defaultFontSize;

    notifyListeners();
  }
}