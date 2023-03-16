import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UrlTextInput extends StatefulWidget {
  final Function(String) onChange;
  final Function(bool) status;
  const UrlTextInput({Key? key, required this.onChange, required this.status})
      : super(key: key);

  @override
  State<UrlTextInput> createState() => _UrlTextInputState();
}

class _UrlTextInputState extends State<UrlTextInput> {
  final TextEditingController _url = TextEditingController();
  final urlPattern = RegExp(r'^https?:\/\/(.*)');

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
    String value = _url.text;
    String? error = urlPattern.hasMatch(value)
        ? null
        : AppLocalizations.of(context)!.errorInvalidUrl;

    setState(() {
      _urlErrorText = error;
    });
    doOnchange(_url.text);
  }

  /// called when the Paste button is clicked
  pastFromClipboard() {
    FlutterClipboard.paste().then((value) {
      setState(() {
        _url.text = value;
        _urlErrorText = urlPattern.hasMatch(value)
            ? null
            : AppLocalizations.of(context)!.errorInvalidUrl;
      });
    }).onError((error, stackTrace) {
      setState(() {
        _url.text = "";
        _urlErrorText = error.toString();
      });
    });
    doOnchange(_url.text);
  }

  doOnchange(value) {
    widget.onChange(value);
    widget.status(_urlErrorText == null);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: _url,
        keyboardType: TextInputType.url,
        autocorrect: false,
        textCapitalization: TextCapitalization.none,
        decoration: InputDecoration(
          errorText: _urlErrorText,
          labelText: AppLocalizations.of(context)!.labelUrlField,
          hintText: AppLocalizations.of(context)!.hintUrlField,
          suffixIcon: IconButton(
            icon: const Icon(Icons.paste),
            onPressed: pastFromClipboard,
          ),
        ),
        onChanged: widget.onChange,
      ),
    );
  }
}
