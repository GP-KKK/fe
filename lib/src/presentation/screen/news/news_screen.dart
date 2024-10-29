import 'package:fe/src/presentation/controller/controller.dart';
import 'package:fe/src/presentation/layout/scollable_layout.dart';
import 'package:fe/src/presentation/screen/loading/loading_screen.dart';
import 'package:fe/src/presentation/screen/news/news_article.dart';
import 'package:fe/src/shared/theme/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewsScreenState();
  }

class _NewsScreenState extends ConsumerState<NewsScreen> {
  final List<String> newsTitles = [
    "경부 고속도로에서 다중 추돌사고 발생",
    "빗길 교통사고, 차량 10대 충돌",
    "출근길 교차로 충돌사고, 교통체증 발생",
    "택시와 오토바이 충돌, 운전자 부상",
    "고속도로 졸음운전, 화물차 사고 발생",
    "버스 추락 사고, 승객 다수 부상",
    "보행자 무단횡단으로 차량 충돌",
    "도로 결빙으로 인한 교통사고 증가",
    "고속도로 역주행 사고, 차량 충돌",
    "도시 외곽 도로에서 발생한 교통사고",
  ];
  final List<String> day = [
    "2024/04/12",
    "2024/04/12",
    "2024/04/12",
    "2024/04/11",
    "2024/04/11",
    "2024/04/10",
    "2024/04/10",
    "2024/04/09",
    "2024/04/08",
    "2024/04/08",
  ];
  Future<void> _launchUrl(url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final news = ref.watch(newsControllerProvider);
    return switch (news) {
          AsyncData(:final value) => _buildNewsScreen(value, textTheme),
          _ => const LoadingScreen(),
        };
  }

  Widget _buildNewsScreen(NewsState news, TextTheme textTheme) {
    print(news.newsList);
    return ScrollableLayout(
      isAppBarVisible: true,
      appBarTitle:
      Text(('newsTitle'), style: textTheme.labelMedium),
      backgroundColor: Colors.white,
      innerTopPadding: 0,
      sidePadding: 0,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: news.newsList.map((item) {
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: ColorTheme.slateColor[100]!,
                    width: 1,
                  ),
                ),
              ),
              child: ListTile(
                onTap: () async {
                  await _launchUrl(Uri.parse(item.url));

                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => NewsArticle(url: item.url),
                  //   ),
                  // );
                },
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    item.title,
                    style: textTheme.bodyMedium,
                  ),
                ),
                // subtitle: Text(
                //   DateFormat.yMd(Intl.getCurrentLocale())
                //       .format(item.createdAt),
                //   style: textTheme.bodySmall!.copyWith(
                //     color: ColorTheme.slateColor[500],
                //   ),
                // ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: ColorTheme.slateColor[400],
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                splashColor: ColorTheme.slateColor[50],
                focusColor: ColorTheme.slateColor[50],
              ),
            );
          }).toList(),
        )
      ],
    );
  }


}
