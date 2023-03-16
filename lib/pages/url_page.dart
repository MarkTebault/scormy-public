import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:scormy/widgets/done_button.dart';
import 'package:scormy/widgets/saveas_button.dart';
import 'package:scormy/widgets/send_email_button.dart';
import 'package:scormy/widgets/page_title.dart';
import 'package:scormy/widgets/title_textfield.dart';
import 'package:scormy/widgets/url_textinput.dart';

class UrlPage extends StatefulWidget {
  const UrlPage({super.key});

  @override
  State<UrlPage> createState() => _UrlPageState();
}

class _UrlPageState extends State<UrlPage> {
  String _courseTitle = "";
  String _embed = "";
  String _status = "";
  bool _isTitleOkay = false;
  bool _isUrlOkay = false;

  // callback function
  updateStatus(String status) {
    // if the widget is no longer in the widget tree, then do not set State
    if (!mounted) return;
    setState(() {
      _status = status;
    });
  }

  @override
  void initState() {
    _courseTitle = "";
    _embed = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // render the view
    return Scaffold(
        body: SafeArea(
            child: SingleChildScrollView(
                child: SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 60.0, 14.0, 0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageTitle(text: AppLocalizations.of(context)!.textCourseProps),
              // course title field
              TitleTextfield(
                  status: (val) => setState(() {
                        _isTitleOkay = val;
                      }),
                  onChange: (val) => setState(() {
                        _courseTitle = val;
                      })),
              UrlTextInput(
                  status: (val) => setState(() {
                        _isUrlOkay = val;
                      }),
                  onChange: (val) => setState(() {
                        _embed = val;
                      })),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SaveAsButton(
                        title: _courseTitle,
                        embed: _embed,
                        enable: _isTitleOkay && _isUrlOkay,
                        callback: updateStatus),
                    SendEmailButton(
                        title: _courseTitle,
                        embed: _embed,
                        enable: _isTitleOkay && _isUrlOkay,
                        callback: updateStatus),
                    const DoneButton(),
                  ]),
              const SizedBox(height: 20),
              Text(_status),
            ]),
      ),
    ))));
  }
}
