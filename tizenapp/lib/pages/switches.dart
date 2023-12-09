import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tizenapp/rotary_lib/src/rotary_base.dart';
import 'package:tizenapp/rotary_lib/src/smooth_scroll.dart';
import 'package:tizenapp/utils/hass.dart';

class SwitchesPage extends StatefulWidget {
  final API api;

  const SwitchesPage({Key? key, required this.api}) : super(key: key);

  @override
  State<SwitchesPage> createState() => _SwitchesPageState();
}

class _SwitchesPageState extends State<SwitchesPage> {
  API get api => widget.api;
  late Future<List<dynamic>> entitiesFuture;

  @override
  void initState() {
    super.initState();
    rotaryEvents.listen((RotaryEvent event) {});
    refreshEntities();
  }

  void refreshEntities() {
    entitiesFuture = api.listEntities(type: "switch.");
  }

  Future<void> handleRefresh() async {
    refreshEntities();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          alignment: Alignment.topCenter,
          width: MediaQuery.of(context).size.width * 0.95,
          child: RefreshIndicator(
            onRefresh: () => handleRefresh(),
            child: ListView(
              controller: SmoothRotaryScrollController(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 12,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 12,
                ),
                FutureBuilder(
                  future: api.listEntities(type: "switch."),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: ListView.builder(
                          clipBehavior: Clip.none,
                          itemCount: snapshot.data!.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              // Hacky workaround to add text to the top of the list
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 20.0),
                                  child: Text(
                                    "Switches",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              );
                            }
                            var iconColor = const Color.fromRGBO(90, 90, 90, 1);
                            var switchIcon = Icons.toggle_off;
                            if (snapshot.data![index - 1]
                                .containsKey('attributes')) {
                              if (snapshot.data![index - 1]['attributes']
                                      ['state'] ==
                                  "on") {
                                iconColor = Colors.white;
                                switchIcon = Icons.toggle_on;
                              }
                            }

                            return snapshot.data![index - 1]
                                        ['friendly_name']! ==
                                    'spacerItem'
                                ? const Column(
                                    children: [
                                      ListTile(
                                        tileColor: Colors.black,
                                      ),
                                      ListTile(
                                        tileColor: Colors.black,
                                      ),
                                      ListTile(
                                        tileColor: Colors.black,
                                      ),
                                    ],
                                  )
                                : ListTile(
                                    leading: Icon(
                                      switchIcon,
                                      color: iconColor,
                                    ),
                                    title: Text(
                                      snapshot.data![index - 1]
                                          ['friendly_name']!,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      snapshot.data![index - 1]['attributes']
                                          ['state']!,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    tileColor:
                                        const Color.fromARGB(66, 82, 82, 82),
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(width: 2),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    onTap: () async {
                                      final success = await api.callService(
                                        'switch',
                                        'toggle',
                                        jsonEncode({
                                          'entity_id': snapshot.data![index - 1]
                                              ['attributes']['entity_id']
                                        }),
                                      );
                                      if (success) {
                                        // Toggle icon between on and off toggle
                                        setState(() {
                                          if (snapshot.data![index - 1]
                                                  ['attributes']['state'] ==
                                              "on") {
                                            snapshot.data![index - 1]
                                                ['attributes']['state'] = "off";
                                            iconColor = const Color.fromRGBO(
                                                90, 90, 90, 1);
                                            switchIcon = Icons.toggle_off;
                                          } else {
                                            snapshot.data![index - 1]
                                                ['attributes']['state'] = "on";
                                            iconColor = Colors.white;
                                            switchIcon = Icons.toggle_on;
                                          }
                                        });
                                      }
                                    },
                                  );
                          },
                        ),
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: CircularProgressIndicator(),
                          ),
                          SizedBox(height: 15),
                          Text('Loading...')
                        ],
                      );
                    } else {
                      return const Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Error"),
                          Text("Check network and setup config"),
                        ],
                      );
                    }
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 4,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
