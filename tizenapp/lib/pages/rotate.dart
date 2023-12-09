import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:step_circle_progressbar/step_circle_progressbar.dart';
import 'package:tizenapp/pages/color.dart';
import 'package:tizenapp/utils/hass.dart';
import 'package:wearable_rotary/wearable_rotary.dart';

class RotatePage extends StatefulWidget {
  const RotatePage(
      {super.key,
      required this.onOffState,
      required this.api,
      required this.entityId});

  final bool onOffState;
  final API api;
  final String entityId;

  @override
  State<RotatePage> createState() =>
      _RotatePageState(onOffState, api, entityId);
}

class _RotatePageState extends State<RotatePage> {
  int _counter = 1;
  bool _onOffState = false;
  API api;
  Color _current = Colors.blue;
  String entityId;

  _RotatePageState(this._onOffState, this.api, this.entityId);

  void addCounter() {
    setState(() {
      if (_counter < 50) {
        _counter++;
      }
    });
  }

  void subtractCounter() {
    setState(() {
      if (_counter > 0) {
        _counter--;
      }
    });
  }

  Future<void> initColor() async {
    final entityState = await api.getState(entityId);
    print(entityState);
    if (entityState['attributes'].containsKey("rgb_color")) {
      if (entityState['attributes']['rgb_color'] != null) {
        setState(() {
          _current = Color.fromRGBO(
            entityState['attributes']['rgb_color'][0]!,
            entityState['attributes']['rgb_color'][1]!,
            entityState['attributes']['rgb_color'][2]!,
            1,
          );
        });
      }
    }
    if (entityState['attributes'].containsKey("brightness")) {
      if (entityState['attributes']['brightness'] != null) {
        setState(() {
          _onOffState = true; // If we know the brightness the light must be on
          _counter =
              ((entityState['attributes']['brightness'] / 255) * 50).round();
        });
      }
    }
    if (entityState['attributes']['state'] == "off" ||
        entityState['attributes']['state'] == "unavailable") {
      _onOffState = false;
    }
  }

  @override
  void initState() {
    rotaryEvents.listen(
      (RotaryEvent event) {
        if (event.direction == RotaryDirection.clockwise) {
          addCounter();
        } else if (event.direction == RotaryDirection.counterClockwise) {
          subtractCounter();
        }
      },
    );
    _onOffState = widget.onOffState;
    super.initState();
    initColor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StepCircleProgressBar(
          circleSize: MediaQuery.of(context).size.height,
          fillSize: 10,
          progressType: ProgressType.FILLED,
          currentSteps: _counter,
          totalSteps: 50,
          progressColor: _current,
          stepColor: Color.fromARGB(255, 0, 0, 0),
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () async {
                  final success = await api.callService(
                    'light',
                    'toggle',
                    jsonEncode({'entity_id': entityId}),
                  );
                  if (success) {
                    setState(() {
                      if (_onOffState == true) {
                        _onOffState = false;
                        _counter = 0;
                      } else {
                        _onOffState = true;
                        initColor();
                      }
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Center(
                          child: Text("Error."),
                        ),
                      ),
                    );
                  }
                },
                icon: Icon(
                  _onOffState == true
                      ? Icons.lightbulb
                      : Icons.lightbulb_outline,
                  size: 60,
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ColorPage(
                          currentColor: Colors.white,
                          api: api,
                          entityId: "light.led_strip_bedroom_light"),
                    ),
                  );
                  initColor();
                  setState(() {});
                },
                child: const Text("Colour"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
