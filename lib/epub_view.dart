import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'epub_controller.dart';

class EpubView extends StatelessWidget {
  final EpubController controller;

  const EpubView({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final allChapterParagraphList = controller.bookModel?.allChapterParagraphList ?? [];

        final bookStyleMap = <String, Style> {};
        for (final String cssStyle in controller.bookModel?.cssStyleList ?? []) {
          bookStyleMap.addAll(Style.fromCss(cssStyle, (css, errors) {
            debugPrint('Invalid Css ${errors.join(', ')}');

            return;
          }));
        }

        return ListView.builder(
          itemCount: allChapterParagraphList.length,
          itemBuilder: (context, indexPosition) {
            final String htmlDocument;
            if (controller.highlightText.isEmpty) {
              htmlDocument = allChapterParagraphList[indexPosition];
            } else {
              htmlDocument = allChapterParagraphList[indexPosition].replaceAllMapped(RegExp(
                controller.highlightText,
                caseSensitive: false,
              ), (match) {
                return '<mark>${match.group(0)}</mark>';
              });
            }

            return Html(
              data: htmlDocument,
              style: {
                ...bookStyleMap,
                'html': Style(
                  fontSize: FontSize(controller.fontSize),
                ),
                'mark': Style(
                  backgroundColor: controller.highlightColor ?? Theme.of(context).colorScheme.primary,
                  color: controller.highlightOnColor ?? Theme.of(context).colorScheme.onPrimary,
                ),
              },
              customRenders: {
                tagMatcher('img'): CustomRender.widget(
                  widget: (context, buildChildren) {
                    final url = context.tree.element?.attributes['src']?.replaceAll('../', '') ?? '';

                    final imageData = controller.bookModel?.imageMap[url];

                    if (imageData == null) return const SizedBox();

                    return GestureDetector(
                      onTap: () {

                      },
                      child: Image.memory(
                        imageData,
                      ),
                    );
                  },
                ),
              },
            );
          },
        );
      },
    );
  }
}
