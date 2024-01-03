import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tizenapp/rotary_lib/src/rotary_base.dart';
import 'package:tizenapp/rotary_lib/src/smooth_scroll.dart';
import 'package:tizenapp/utils/hass.dart';

class LocksPage extends StatefulWidget {
  final API api;

  const LocksPage({Key? key, required this.api}) : super(key: key);

  @override
  State<LocksPage> createState() => _LocksPageState();
}

class _LocksPageState extends State<LocksPage> {
  API get api => widget.api;
  late Future<List<dynamic>> entitiesFuture;

  @override
  void initState() {
    super.initState();
    rotaryEvents.listen((RotaryEvent event) {});
    refreshEntities();
  }

  void refreshEntities() {
    entitiesFuture = api.listEntities(type: "lock.");
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
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 12,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 12,
                ),
                FutureBuilder(
                  future: api.listEntities(type: "lock."),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: ListView.builder(
                          controller: SmoothRotaryScrollController(),
                          clipBehavior: Clip.none,
                          itemCount: snapshot.data!.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              // Hacky workaround to add text to the top of the list
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 20.0),
                                  child: Text(
                                    "Locks",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              );
                            }
                            var iconColor = const Color.fromRGBO(90, 90, 90, 1);
                            var switchIcon = Icons.lock_open;
                            if (snapshot.data![index - 1]
                                .containsKey('attributes')) {
                              if (snapshot.data![index - 1]['attributes']
                                      ['state'] ==
                                  "locked") {
                                iconColor = Colors.red;
                                switchIcon = Icons.lock;
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
                                      // Toggle icon between on and off toggle
                                      if (snapshot.data![index - 1]
                                              ['attributes']['state'] ==
                                          "locked") {
                                        setState(() {
                                          snapshot.data![index - 1]
                                                  ['attributes']['state'] =
                                              "Processing...";
                                        });
                                        final success = await api.callService(
                                          'lock',
                                          'unlock',
                                          jsonEncode({
                                            'entity_id':
                                                snapshot.data![index - 1]
                                                    ['attributes']['entity_id']
                                          }),
                                        );
                                        if (success) {
                                          setState(() {
                                            snapshot.data![index - 1]
                                                    ['attributes']['state'] =
                                                "unlocked";
                                            iconColor = const Color.fromRGBO(
                                                90, 90, 90, 1);
                                            switchIcon = Icons.lock_open;
                                          });
                                        } else {
                                          snapshot.data![index - 1]
                                              ['attributes']['state'] = "Error";
                                        }
                                      } else {
                                        setState(() {
                                          snapshot.data![index - 1]
                                                  ['attributes']['state'] =
                                              "Processing...";
                                        });

                                        final success = await api.callService(
                                          'lock',
                                          'lock',
                                          jsonEncode({
                                            'entity_id':
                                                snapshot.data![index - 1]
                                                    ['attributes']['entity_id']
                                          }),
                                        );
                                        if (success) {
                                          setState(() {
                                            snapshot.data![index - 1]
                                                    ['attributes']['state'] =
                                                "unlocked";
                                            iconColor = Colors.red;
                                            switchIcon = Icons.lock;
                                          });
                                        } else {
                                          snapshot.data![index - 1]
                                              ['attributes']['state'] = "Error";
                                        }
                                      }
                                    });
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
