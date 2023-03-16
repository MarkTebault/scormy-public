import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:developer' as developer;

class YoutubeShareTextinput extends StatefulWidget {
  final Function(String) onChange;
  final Function(bool) status;
  const YoutubeShareTextinput(
      {Key? key, required this.onChange, required this.status})
      : super(key: key);

  @override
  State<YoutubeShareTextinput> createState() => _YoutubeShareTextinputState();
}

class _YoutubeShareTextinputState extends State<YoutubeShareTextinput> {
  final TextEditingController _url = TextEditingController();
  final urlPattern = RegExp(r'^https:\/\/youtu.be\/+');

  final youTubePattern = RegExp(r'^https:\/\/www.youtube.com/watch\?v=+');
  final shortsPattern = RegExp(r'https:\/\/youtube.com/shorts\/+');

  // used to notify the URL is invalid
  String? _urlErrorText;

  //// localized text
  String? errorRequired;
  String? errorMaxLength;
  String? errorInvalidYTUrl;

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _url.text = "";
    _urlErrorText = null;
    _url.addListener(_urlListener);
    super.initState();
  }

// clear any error messages whenever the field changes value
  _urlListener() {
    String? errorString;
    String value = _url.text;

    // see if the user copied the URL from the browser address bar
    // example: https://www.youtube.com/watch?v=adQMnD7l06k
    if (youTubePattern.hasMatch(value)) {
      // grab the video Id from the URL and reconstruct the URL
      String videoId = _url.text.substring(32, value.length);
      _url.text = "https://youtu.be/$videoId";
    }

    // see if the user copied a shorts URL
    // example: https://youtube.com/shorts/LYjws5jSNcg?feature=share
    if (shortsPattern.hasMatch(value)) {
      var x = value.indexOf("?");
      String videoId = _url.text.substring(27, x);
      _url.text = "https://youtu.be/$videoId";
    }

    if (urlPattern.hasMatch(_url.text)) {
      errorString = null;
    } else {
      errorString = AppLocalizations.of(context)!.errorInvalidYTUrl;
    }
    setState(() {
      _urlErrorText = errorString;
    });
    doOnchange(_url.text);
  }

  /// called when the Paste button is clicked
  pastFromClipboard() {
    FlutterClipboard.paste().then((value) {
      String fieldlValue = "";
      String? fieldError;

      // see if the user copied the URL from the browser address bar
      // example: https://www.youtube.com/watch?v=adQMnD7l06k
      if (youTubePattern.hasMatch(value)) {
        // grab the video Id from the URL and reconstruct the URL
        String videoId = value.substring(32, value.length);
        value = "https://youtu.be/$videoId";
      }

      // see if the user copied a shorts URL
      // example: https://youtube.com/shorts/LYjws5jSNcg?feature=share
      if (shortsPattern.hasMatch(value)) {
        var x = value.indexOf("?");
        String videoId = value.substring(27, x);
        value = "https://youtu.be/$videoId";
      }

      if (urlPattern.hasMatch(value)) {
        fieldlValue = value;
        fieldError = null;
      } else {
        fieldlValue = "";
        fieldError = errorInvalidYTUrl;
      }
      setState(() {
        _url.text = fieldlValue;
        _urlErrorText = fieldError;
      });
      // calling this since the widget onChange is not triggered
      widget.onChange(_url.text);
    }).onError((error, stackTrace) {
      setState(() {
        _url.text = "";
        _urlErrorText = error.toString();
      });
    });
  }

  doOnchange(value) {
    widget.onChange(value);
    widget.status(_urlErrorText == null);
    developer.log("doOnChange yt Called");
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _url,
      keyboardType: TextInputType.url,
      autocorrect: false,
      textCapitalization: TextCapitalization.none,
      decoration: InputDecoration(
        errorText: _urlErrorText,
        border: const OutlineInputBorder(),
        labelText: AppLocalizations.of(context)!.labelYTUrlField,
        hintText: AppLocalizations.of(context)!.hintYTUrlField,
        suffixIcon: IconButton(
          icon: const Icon(Icons.paste),
          onPressed: pastFromClipboard,
        ),
      ),
      onChanged: doOnchange,
    );
  }
}
