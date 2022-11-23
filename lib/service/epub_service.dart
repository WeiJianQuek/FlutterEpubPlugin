import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

import '../model/book/chapter_book_model.dart';
import '../model/book_model.dart';
import '../model/epub/manifest_epub_model.dart';
import '../model/epub/metadata_epub_model.dart';
import '../model/epub/spine_epub_model.dart';
import '../utility/file_utility.dart';

const _tag = 'epub_plugin';

class EpubService {
  static BookModel? decode(final Uint8List epubData) {
    return EpubService._(
      epubArchive: ZipDecoder().decodeBytes(epubData),
    ).initialise();
  }

  final Archive epubArchive;

  List<ArchiveFile> get epubArchiveFileList => epubArchive.files;

  const EpubService._({
    required this.epubArchive,
  });

  BookModel initialise() {
    if (epubArchiveFileList.isEmpty) throw Exception('$_tag Missing Error: The epub file is empty');

    final epubDirectoryFilePath = getEpubFilePath();

    final epubDirectoryPath = FileUtility.getDirectoryPath(epubDirectoryFilePath);

    final indexArchiveFile = _getArchiveFile(epubDirectoryFilePath);

    if (indexArchiveFile == null) throw Exception('$_tag Missing Error: The epub opf file is missing');

    final xmlDocument = XmlDocument.parse(utf8.decode(indexArchiveFile.content));

    final packageXmlElement = xmlDocument.getElement('package');

    if (packageXmlElement == null) throw Exception('$_tag Missing Error: Package Tag not found.');

    final metadataEpubModel = getMetadataEpubModel(packageXmlElement);

    final spineEpubModelList = getSpineEpubModelList(packageXmlElement);

    final manifestEpubModelList = getManifestEpubModelList(packageXmlElement, epubDirectoryPath);

    final bookModel = MutableBookModel(
      title: metadataEpubModel.title,
      author: metadataEpubModel.author,
      source: metadataEpubModel.source,
      identifier: metadataEpubModel.identifier,
      publisher: metadataEpubModel.publisher,
      language: metadataEpubModel.language,
      copyright: metadataEpubModel.copyright,
    );

    for (final manifestEpubModel in manifestEpubModelList) {
      if (manifestEpubModel.data != null) {
        if (manifestEpubModel.id == 'ncx') {

        } else {
          switch(manifestEpubModel.mediaType) {
            case 'application/xhtml+xml':
              /// Record Chapter & Paragraph
              for (int i = 0; i < spineEpubModelList.length; i++) {
                if (manifestEpubModel.id == spineEpubModelList[i].id) {
                  final xmlDocument = XmlDocument.parse(utf8.decode(manifestEpubModel.data ?? []));

                  final htmlXmlElement = xmlDocument.getElement('html')?.getElement('body');

                  if (htmlXmlElement != null) {
                    final paragraphList = <String> [];

                    for (final xmlElement in htmlXmlElement.childElements) {
                      paragraphList.add(xmlElement.outerXml);
                    }

                    bookModel.chapterModelMap[i] = ChapterBookModel(
                      paragraphList: paragraphList,
                    );
                  }
                  break;
                }
              }
              break;
            case 'image/gif':
            case 'image/jpeg':
            case 'image/png':
            case 'image/svg+xml':
              bookModel.imageMapList[manifestEpubModel.filePath] = manifestEpubModel.data;
              break;
            case 'font/truetype':
            case 'font/opentype':
            case 'application/vnd.ms-opentype':

              break;
            case 'text/css':
              bookModel.cssStyleList.add(utf8.decode(manifestEpubModel.data ?? []));
              break;
          }
        }
      }
    }

    return bookModel.toImmutable();
  }

  String getEpubFilePath() {
    final containerArchiveFile = _getArchiveFile('META-INF/container.xml');

    if (containerArchiveFile == null) throw Exception('$_tag Missing Error: The epub container file is not found');

    final xmlDocument = XmlDocument.parse(utf8.decode(containerArchiveFile.content));

    final containerXmlElementList = xmlDocument.findAllElements(
      'container',
      namespace: 'urn:oasis:names:tc:opendocument:xmlns:container',
    );

    if (containerXmlElementList.isEmpty) throw Exception('$_tag Error: Missing container');

    for (final descendantElement in containerXmlElementList.first.descendants) {
      if (descendantElement is XmlElement) {
        if (descendantElement.name.local == 'rootfile') {
          return descendantElement.getAttribute("full-path") ?? '';
        }
      }
    }

    throw Exception('$_tag Error: Missing container root file path');
  }

  MetadataEpubModel getMetadataEpubModel(final XmlElement indexXmlElement) {
    final model = MutableMetadataEpubModel();

    final metadataXmlElement = indexXmlElement.getElement('metadata');

    if (metadataXmlElement == null) throw Exception('$_tag Missing Error: Metadata Tag not found.');

    for (final xmlElement in metadataXmlElement.childElements) {
      switch(xmlElement.name.local) {
        case 'title':
          model.title = xmlElement.innerText;
          break;
        case 'creator':
          model.author = xmlElement.innerText;
          break;
        case 'source':
          model.source = xmlElement.innerText;
          break;
        case 'identifier':
          model.identifier = xmlElement.innerText;
          break;
        case 'publisher':
          model.publisher = xmlElement.innerText;
          break;
        case 'language':
          model.language = xmlElement.innerText;
          break;
        case 'rights':
          model.copyright = xmlElement.innerText;
          break;
      }
    }

    return model.toImmutable();
  }

  List<SpineEpubModel> getSpineEpubModelList(final XmlElement indexXmlElement) {
    final modelList = <SpineEpubModel> [];

    final spineXmlElement = indexXmlElement.getElement('spine');

    if (spineXmlElement == null) throw Exception('$_tag Missing Error: Spine Tag not found.');

    for (final xmlElement in spineXmlElement.childElements) {
      final model = MutableSpineEpubModel();
      for (final xmlAttribute in xmlElement.attributes) {
        switch(xmlAttribute.name.local) {
          case 'idref':
            model.id = xmlAttribute.value;
            break;
        }
      }

      modelList.add(model.toImmutable());
    }

    return modelList;
  }

  List<ManifestEpubModel> getManifestEpubModelList(final XmlElement indexXmlElement, final String epubDirectoryPath) {
    final modelList = <ManifestEpubModel> [];

    final manifestXmlElement = indexXmlElement.getElement('manifest');

    if (manifestXmlElement == null) throw Exception('$_tag Not Found Error: Manifest tag is not found.');

    for (final xmlElement in manifestXmlElement.childElements) {
      final model = MutableManifestEpubModel();

      for (final xmlAttribute in xmlElement.attributes) {
        switch(xmlAttribute.name.local) {
          case 'id':
            model.id = xmlAttribute.value;
            break;
          case 'href':
            model.filePath = xmlAttribute.value;
            break;
          case 'media-type':
            model.mediaType = xmlAttribute.value;
            break;
        }
      }

      model.data = _getArchiveFile('${epubDirectoryPath.isEmpty ? '' : '$epubDirectoryPath/'}${model.filePath}')?.content;

      if (model.data != null) {
        modelList.add(model.toImmutable());
      }
    }

    return modelList;
  }

  /// Directory File Path Eg. images/cover.png
  ArchiveFile? _getArchiveFile(final String directoryFilePath) {
    for (final file in epubArchiveFileList) {
      if (file.name == directoryFilePath) {
        return file;
      }
    }

    return null;
  }
}