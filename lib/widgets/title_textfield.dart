import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TitleTextfield extends StatefulWidget {
  final Function(String) onChange;
  final Function(bool) status;
  const TitleTextfield({Key? key, required this.onChange, required this.status})
      : super(key: key);

  @override
  State<TitleTextfield> createState() => _TitleTextfieldState();
}

class _TitleTextfieldState extends State<TitleTextfield> {
  final TextEditingController _title = TextEditingController();

  // used to notify the title is required
  String? _titleErrorText;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _title.addListener(_titleListener);
    super.initState();
  }

// clear the title error when something is entered
  _titleListener() {
    String? errorString;

    if (_title.text.isEmpty) {
      errorString = AppLocalizations.of(context)!.errorRequired;
    } else if (_title.text.length > 255) {
      errorString = AppLocalizations.of(context)!.errorMaxLength;
    } else {
      errorString = null;
    }
    setState(() {
      _titleErrorText = errorString;
    });
  }

  doOnchange(value) {
    widget.onChange(value);
    widget.status(_titleErrorText == null);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: _title,
        keyboardType: TextInputType.text,
        autocorrect: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          errorText: _titleErrorText,
          border: const OutlineInputBorder(),
          labelText: AppLocalizations.of(context)!.labelTitlelField,
          hintText: AppLocalizations.of(context)!.hintTitleslField,
          suffixIcon: IconButton(
              icon: const Icon(Icons.clear), onPressed: () => _title.clear()),
        ),
        onChanged: doOnchange,
      ),
    );
  }
}
