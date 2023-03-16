import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:scormy/util/course_package_util.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SendEmailButton extends StatefulWidget {
  final String title;
  final String? url;
  final String? embed;
  final double? percent;
  final bool enable;
  final Function callback;

  const SendEmailButton(
      {super.key,
      required this.title,
      this.url,
      this.embed,
      this.percent,
      required this.enable,
      required this.callback});

  @override
  State<SendEmailButton> createState() => _SendEmailButtonState();
}

class _SendEmailButtonState extends State<SendEmailButton> {
  // used to prevent double clicking the  button
  bool _sendingEmail = false;

  String? localizedBodyText;
  String? localizedSubjectText;
  String? localizedEmailError;
  String? localizedEmailSent;

  /// function that creates and sends the email attachment
  sendEmail() async {
    setState(() {
      _sendingEmail = true;
    });

    final bool isYouTube = (widget.url?.isNotEmpty ?? false);
    final String title = widget.title;
    final double percent = widget.percent ?? 0.0;
    final String urlText = widget.url ?? "";
    final String embedHTML = widget.embed ?? "";
    String coursefolder = "embed";
    String videoId = "";

    String srcfolder = isYouTube ? "youtube" : "embed";

    // to keep track of futures that need to complete before proceeding
    var futures = <Future>[];

    if (urlText.isNotEmpty) {
      Uri url = Uri.parse(widget.url ?? "");
      videoId = url.pathSegments.last;
      coursefolder = "youtube";
    }

    // set the course package name equal to the title name
    CoursePackageUtility().coursePackageName = title;

    // get target path
    String path = await CoursePackageUtility().targetPath;

    //update the course files based on user input
    futures.add(
        CoursePackageUtility().updateManifestFile(path, title, coursefolder));
    futures.add(CoursePackageUtility()
        .updateIndexFile(path, title, embedHTML, coursefolder));
    futures.add(CoursePackageUtility()
        .updateConfigFile(path, videoId, percent, coursefolder));

    await Future.wait(futures);

    // create the zip file
    await CoursePackageUtility().createZipArchive(srcfolder);

    //now send the email
    List<String> attachments = [];
    List<String> recipients = [];

    // set the body
    String body = localizedBodyText ?? "";

    // set the subject
    String subject = localizedSubjectText ?? "";

    String errorMessage = localizedEmailError ?? "";

    // set the attachement
    String zipFilename = await CoursePackageUtility().zipFilename;
    attachments.add(zipFilename);

    final Email email = Email(
      body: body,
      subject: subject,
      recipients: recipients,
      attachmentPaths: attachments,
      isHTML: true,
    );

    FlutterEmailSender.send(email).then((value) {
      widget.callback(localizedEmailSent);
    }).onError((error, stackTrace) {
      widget.callback(errorMessage);
    }).whenComplete(() {
      if (!mounted) return;
      setState(() {
        _sendingEmail = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      localizedBodyText = AppLocalizations.of(context)!.emailBody;
      localizedSubjectText = AppLocalizations.of(context)!.emailSubject;
      localizedEmailError = AppLocalizations.of(context)!.emailError;
      localizedEmailSent = AppLocalizations.of(context)!.emailSent;
    });

    // only return the button if on a supported device
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      return Column(children: [
        ElevatedButton.icon(
            icon: const Icon(
              Icons.email,
              size: 16,
            ),
            label: Text(AppLocalizations.of(context)!.btnEmail),
            onPressed: (!_sendingEmail && widget.enable) ? sendEmail : null),
      ]);
    } else {
      return Container(child: null);
    }
  }
}
