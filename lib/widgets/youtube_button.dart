import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class YouTubeButton extends StatelessWidget {
  final Future futureMethod;
  const YouTubeButton({super.key, required this.futureMethod});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: FutureBuilder<void>(
        future: futureMethod,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Text(AppLocalizations.of(context)!.btnLoading);
            case ConnectionState.done:
            default:
              if (snapshot.hasError) {
                return Text(
                    '${AppLocalizations.of(context)!.textError} ${snapshot.error}');
              } else if (snapshot.hasData) {
                return ElevatedButton.icon(
                    icon: const Icon(
                      FontAwesomeIcons.youtube,
                      color: Colors.red,
                      size: 24,
                    ),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(28),
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(250.0, 50.0)),
                    label: Text(AppLocalizations.of(context)!.youtubeCourse,
                        style: const TextStyle(fontSize: 18)),
                    onPressed: () => context.go('/youtube'));
              } else {
                return Text(AppLocalizations.of(context)!.textError);
              }
          }
        },
      ),
    );
  }
}
