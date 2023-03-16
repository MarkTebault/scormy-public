import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PercentSlider extends StatefulWidget {
  final Function(String) onChange;
  const PercentSlider({Key? key, required this.onChange}) : super(key: key);

  @override
  State<PercentSlider> createState() => _PercentSliderState();
}

class _PercentSliderState extends State<PercentSlider> {
  double _percent = 00.0;

  @override
  void initState() {
    _percent = 90.0;
    super.initState();
  }

  doOnchange(value) {
    setState(() {
      _percent = value;
    });
    widget.onChange(value.toString());
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
              flex: 1,
              fit: FlexFit.loose,
              child: Text(
                  style: Theme.of(context).textTheme.bodyMedium,
                  AppLocalizations.of(context)!.textSetPercent)),
          Flexible(
              flex: 3,
              fit: FlexFit.loose,
              child: Slider(
                activeColor: Colors.blue,
                inactiveColor: Colors.blue[900],
                min: 0.0,
                max: 100.0,
                divisions: 100,
                value: _percent,
                onChanged: doOnchange,
              )),
          Flexible(
              flex: 1,
              fit: FlexFit.loose,
              child: Text("${_percent.round().toString()}%")),
        ],
      ),
    );
  }
}
