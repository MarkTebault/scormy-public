import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:scormy/util/course_package_util.dart';
import 'package:scormy/widgets/embed_button.dart';
import 'package:scormy/widgets/youtube_button.dart';

import '../widgets/url_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var copyYouTubeFiles = CoursePackageUtility().copyFiles("youtube");
  var copyEmbedFiles = CoursePackageUtility().copyFiles("embed");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // SCORMY Title
            Text(AppLocalizations.of(context)!.titleSCORMY,
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center),
            // spacer
            const SizedBox(
              height: 20,
            ),
            // Intro Text
            Text(AppLocalizations.of(context)!.textIntro,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center),
            // Buttons
            const SizedBox(
              height: 20,
            ),
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              YouTubeButton(futureMethod: copyYouTubeFiles),
              // Embed Button
              EmbedButton(futureMethod: copyEmbedFiles),
              UrlButton(futureMethod: copyEmbedFiles),
            ]),
          ],
        ),
      ),
    ));
  }
}
