import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:scormy/widgets/done_button.dart';
import 'package:scormy/widgets/saveas_button.dart';
import 'package:scormy/widgets/send_email_button.dart';
import 'package:scormy/widgets/page_title.dart';
import 'package:scormy/widgets/title_textfield.dart';
import 'package:scormy/widgets/youtubeshare_textinput.dart';
import 'package:scormy/widgets/percent_slider.dart';

class YouTubePage extends StatefulWidget {
  const YouTubePage({super.key});

  @override
  State<YouTubePage> createState() => _YouTubePageState();
}

class _YouTubePageState extends State<YouTubePage> {
  String _courseTitle = "";
  String _youTubeShareUrl = "";
  double _percent = 00.0;
  String _status = "";
  late bool _isTitleOkay;
  late bool _isUrlOkay;

  // callback function
  updateStatus(String status) {
    // if the widget is no longer in the widget tree, then do not set State
    if (!mounted) return;

    setState(() {
      _status = status;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    _courseTitle = "";
    _youTubeShareUrl = "";
    _isTitleOkay = false;
    _isUrlOkay = false;
    _percent = 90.0;

    super.initState();
  }

// video showing the action button https://www.youtube.com/watch?v=YHNCYfqGrBY
// watch it.

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
              YoutubeShareTextinput(
                  status: (val) => setState(() {
                        _isUrlOkay = val;
                      }),
                  onChange: (val) => setState(() {
                        _youTubeShareUrl = val;
                      })),
              PercentSlider(
                  onChange: (val) => setState(() {
                        _percent = double.parse(val);
                      })),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SaveAsButton(
                        title: _courseTitle,
                        url: _youTubeShareUrl,
                        percent: _percent,
                        enable: (_isTitleOkay && _isUrlOkay),
                        callback: updateStatus),
                    SendEmailButton(
                        title: _courseTitle,
                        url: _youTubeShareUrl,
                        percent: _percent,
                        enable: (_isTitleOkay && _isUrlOkay),
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
