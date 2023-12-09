import 'package:flutter/material.dart';
import 'package:tizenapp/rotary_lib/src/rotary_base.dart';
import 'package:tizenapp/rotary_lib/src/smooth_scroll.dart';
import 'package:tizenapp/utils/hass.dart';

class PeoplePage extends StatefulWidget {
  final API api;

  const PeoplePage({Key? key, required this.api}) : super(key: key);

  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  API get api => widget.api;
  late Future<List<dynamic>> entitiesFuture;

  @override
  void initState() {
    super.initState();
    rotaryEvents.listen((RotaryEvent event) {});
    refreshEntities();
  }

  void refreshEntities() {
    entitiesFuture = api.listEntities(type: "person.");
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
              padding: const EdgeInsets.only(bottom: 15),
              controller: SmoothRotaryScrollController(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 12,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 12,
                ),
                FutureBuilder(
                  future: api.listEntities(type: "person."),
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
                                    "People",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              );
                            }
                            var iconColor = const Color.fromRGBO(90, 90, 90, 1);
                            var switchIcon = Icons.person_outline;
                            if (snapshot.data![index - 1]
                                .containsKey('attributes')) {
                              if (snapshot.data![index - 1]['attributes']
                                      ['state'] ==
                                  "home") {
                                iconColor = Colors.white;
                                switchIcon = Icons.person;
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
