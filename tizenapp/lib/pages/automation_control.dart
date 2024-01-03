import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tizenapp/utils/hass.dart';

class AutomationControlPage extends StatefulWidget {
  const AutomationControlPage(
      {super.key,
      required this.currentState,
      required this.api,
      required this.entityId,
      required this.friendlyName});

  final bool currentState;
  final API api;
  final String entityId;
  final String friendlyName;

  @override
  State<AutomationControlPage> createState() => _AutomationControlPageState();
}

class _AutomationControlPageState extends State<AutomationControlPage> {
  bool get _initialState => widget.currentState;
  String get _entityId => widget.entityId;
  API get api => widget.api;
  String get _friendlyName => widget.friendlyName;
  late bool _currentState;
  Widget faviconChild = const Icon(Icons.play_arrow_outlined);

  _AutomationControlPageState();

  void changeState(bool state) {
    setState(() => _currentState = state);
  }

  @override
  void initState() {
    _currentState = _initialState;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            _friendlyName,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 25),
              const Text('Enable/Disable'),
              const SizedBox(height: 5),
              Switch(
                  value: _currentState,
                  onChanged: (bool newState) async {
                    await api.callService(
                      'automation',
                      'toggle',
                      jsonEncode({
                        'entity_id': _entityId,
                      }),
                    );
                    changeState(newState);
                  })
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            setState(() {
              faviconChild = const CircularProgressIndicator();
            });
            final success = await api.callService(
              'automation',
              'trigger',
              jsonEncode({
                'entity_id': _entityId,
              }),
            );
            if (success) {
              setState(() {
                faviconChild = const Icon(Icons.check);
              });
            } else {
              setState(() {
                faviconChild = const Icon(Icons.error_outline);
              });
            }
            await Future.delayed(const Duration(seconds: 1));
            setState(() {
              faviconChild = const Icon(Icons.play_arrow_outlined);
            });
          },
          child: faviconChild,
        ));
  }
}
