import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class DoneButton extends StatelessWidget {
  const DoneButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: ElevatedButton.icon(
          icon: const Icon(
            FontAwesomeIcons.house,
            size: 16,
          ),
          label: Text(AppLocalizations.of(context)!.btnDone),
          onPressed: () {
            context.go("/");
          },
        ));
  }
}
