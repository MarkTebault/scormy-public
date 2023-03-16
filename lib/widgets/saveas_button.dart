import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:scormy/util/course_package_util.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart' as p;

class SaveAsButton extends StatefulWidget {
  final String title;
  final String? url;
  final String? embed;
  final double? percent;
  final bool enable;
  final Function callback;

  // used to indicate the values passed are valid

  const SaveAsButton(
      {super.key,
      required this.title,
      this.url,
      this.embed,
      this.percent,
      required this.enable,
      required this.callback});

  @override
  State<SaveAsButton> createState() => _SaveAsButtonState();
}

class _SaveAsButtonState extends State<SaveAsButton> {
// used to prevent double clicking the save button
  bool _savingFile = false;

  // used to let the user know the app is doing something
  String waitMessage = "";

  String saveAsText = "";
  String invalidError = "";

  @override
  void initState() {
    _savingFile = false;
    super.initState();
  }

  // called to save files using the save file dialog
  doSaveFile() async {
    setState(() {
      _savingFile = true;
      waitMessage = AppLocalizations.of(context)!.textPreparingCourse;
    });
    widget.callback(waitMessage);

    final String title = widget.title;
    final double percent = widget.percent ?? 0.0;
    final String urlText = widget.url ?? "";
    final String embedHTML = widget.embed ?? "";
    String coursefolder = "embed";
    String videoId = "";

    try {
      // set the course package name equal to the title name
      CoursePackageUtility().coursePackageName = title;

      var futures = <Future>[];

      if (urlText.isNotEmpty) {
        Uri url = Uri.parse(widget.url ?? "");
        videoId = url.pathSegments.last;
        coursefolder = "youtube";
      }

      String path = await CoursePackageUtility().targetPath;

      // update the course files based on user input
      futures.add(
          CoursePackageUtility().updateManifestFile(path, title, coursefolder));
      futures.add(CoursePackageUtility()
          .updateIndexFile(path, title, embedHTML, coursefolder));
      futures.add(CoursePackageUtility()
          .updateConfigFile(path, videoId, percent, coursefolder));

      await Future.wait(futures);

      // create the zip file

      await CoursePackageUtility().createZipArchive(coursefolder);

      // open the save as dialog

      String? savedFilename =
          await CoursePackageUtility().saveAsDialog(saveAsText);

      // reset the flags when the save process is complete
      setState(() {
        _savingFile = false;
        waitMessage = "";
      });
      widget.callback(p.basename(savedFilename ?? invalidError));
    } catch (e) {
      widget.callback(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      saveAsText = AppLocalizations.of(context)!.textSaveAs;
      invalidError = AppLocalizations.of(context)!.textInvalid;
    });

    // only return the button if on a supported device
    if (defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return Column(children: [
        ElevatedButton.icon(
            icon: const Icon(
              FontAwesomeIcons.floppyDisk,
              size: 16,
            ),
            label: Text(AppLocalizations.of(context)!.btnSave),
            onPressed: (!_savingFile && widget.enable) ? doSaveFile : null),
      ]);
    } else {
      return Container(child: null);
    }
  }
}
