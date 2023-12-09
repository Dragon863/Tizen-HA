import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:tizenapp/utils/hass.dart';

class ColorPage extends StatefulWidget {
  const ColorPage(
      {super.key,
      required this.currentColor,
      required this.api,
      required this.entityId});

  final Color currentColor;
  final API api;
  final String entityId;

  @override
  State<ColorPage> createState() => _ColorPageState();
}

class _ColorPageState extends State<ColorPage> {
  Color get _initialColor => widget.currentColor;
  String get _entityId => widget.entityId;
  API get api => widget.api;
  late Color _currentColor;

  _ColorPageState();

  void changeColor(Color color) {
    setState(() => _currentColor = color);
  }

  @override
  void initState() {
    _currentColor = _initialColor;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            SlidePicker(
              pickerColor: _currentColor,
              onColorChanged: changeColor,
              enableAlpha: false,
              showIndicator: false,
              showParams: false,
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await api.callService(
                  'light',
                  'turn_on',
                  jsonEncode(
                    {
                      'entity_id': _entityId,
                      "rgb_color": [
                        _currentColor.red,
                        _currentColor.green,
                        _currentColor.blue
                      ]
                    },
                  ),
                );
                print(
                  jsonEncode(
                    {
                      "rgb_color": [
                        _currentColor.red,
                        _currentColor.green,
                        _currentColor.blue
                      ],
                    },
                  ),
                );
                if (success) {
                  Navigator.of(context).pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: _currentColor,
                  fixedSize: const Size(100, 30)),
              child: Text(
                "Set",
                style: TextStyle(
                    color: _currentColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
