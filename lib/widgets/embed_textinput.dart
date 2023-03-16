import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EmbedTextInput extends StatefulWidget {
  final Function(String) onChange;
  final Function(bool) status;
  const EmbedTextInput({Key? key, required this.onChange, required this.status})
      : super(key: key);

  @override
  State<EmbedTextInput> createState() => _EmbedTextInputState();
}

class _EmbedTextInputState extends State<EmbedTextInput> {
  final TextEditingController _embed = TextEditingController();
  //final urlPattern = RegExp(r'^<iframe*');
  final urlPattern = RegExp(r'^<iframe*', caseSensitive: false);

  // used to notify the URL is invalid
  String? _embedErrorText;

  //// localized text
  String? errorRequired;
  String? errorMaxLength;
  String? errorInvalidYTUrl;

  @override
  void dispose() {
    _embed.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _embed.text = "";
    _embedErrorText = null;
    _embed.addListener(_urlListener);
    super.initState();
  }

// clear any error messages whenever the field changes value
  _urlListener() {
    String value = _embed.text;

    setState(() {
      _embedErrorText = urlPattern.hasMatch(value.toLowerCase())
          ? null
          : AppLocalizations.of(context)!.errorInvalidEmbed;
    });
    doOnchange(_embed.text);
  }

  /// called when the Paste button is clicked
  pastFromClipboard() {
    FlutterClipboard.paste().then((value) {
      String? error = urlPattern.hasMatch(value)
          ? null
          : AppLocalizations.of(context)!.errorInvalidEmbed;
      setState(() {
        _embed.text = value;
        _embedErrorText = error;
      });
      doOnchange(_embed.text);
    }).onError((error, stackTrace) {
      setState(() {
        _embed.text = "";
        _embedErrorText = error.toString();
      });
    });
    doOnchange(_embed.text);
  }

  doOnchange(value) {
    widget.onChange(value);
    widget.status(_embedErrorText == null);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: _embed,
        keyboardType: TextInputType.url,
        autocorrect: false,
        maxLines: null, // this allows multiple lines of text to be entered
        textCapitalization: TextCapitalization.none,
        decoration: InputDecoration(
          errorText: _embedErrorText,
          labelText: AppLocalizations.of(context)!.labelEmbedField,
          hintText: AppLocalizations.of(context)!.hintEmbedField,
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
