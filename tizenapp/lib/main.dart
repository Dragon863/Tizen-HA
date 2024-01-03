import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tizenapp/pages/automations.dart';
import 'package:tizenapp/pages/config.dart';
import 'package:tizenapp/pages/lights.dart';
import 'package:tizenapp/pages/locks.dart';
import 'package:tizenapp/pages/people.dart';
import 'package:tizenapp/pages/scenes.dart';
import 'package:tizenapp/pages/switches.dart';
import 'package:tizenapp/utils/hass.dart';
import 'rotary_lib/src/smooth_scroll.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Assistant',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.lightBlue,
              background: Colors.black,
              brightness: Brightness.dark),
          useMaterial3: true,
          brightness: Brightness.dark),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  API? api;

  Future<API> getAPIFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    String url = prefs.getString('server') ?? '';
    return API(token, url);
  }

  @override
  void initState() {
    getAPIFromSharedPreferences().then((value) {
      setState(() {
        api = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.95,
          child: ListView(
            controller: SmoothRotaryScrollController(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 12,
              ),
              const Center(
                child: Text(
                  "Welcome!",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 12,
              ),
              ListTile(
                leading: const Icon(Icons.lightbulb),
                title: const Text('Lights'),
                subtitle: const Text('Colour & state'),
                tileColor: const Color.fromARGB(66, 82, 82, 82),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 2),
                  borderRadius: BorderRadius.circular(50),
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LightsPage(api: api!),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.toggle_on),
                title: const Text('Switches'),
                subtitle: const Text('On/Off'),
                tileColor: const Color.fromARGB(66, 82, 82, 82),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 2),
                  borderRadius: BorderRadius.circular(50),
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SwitchesPage(api: api!),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('People'),
                subtitle: const Text('View status'),
                tileColor: const Color.fromARGB(66, 82, 82, 82),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 2),
                  borderRadius: BorderRadius.circular(50),
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PeoplePage(api: api!),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.smart_toy_outlined),
                title: const Text('Automations'),
                subtitle: const Text('Trigger & start'),
                tileColor: const Color.fromARGB(66, 82, 82, 82),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 2),
                  borderRadius: BorderRadius.circular(50),
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AutomationPage(api: api!),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Scenes'),
                subtitle: const Text('Run scene'),
                tileColor: const Color.fromARGB(66, 82, 82, 82),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 2),
                  borderRadius: BorderRadius.circular(50),
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ScenePage(api: api!),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.lock_open),
                title: const Text('Locks'),
                subtitle: const Text('Lock/Unlock'),
                tileColor: const Color.fromARGB(66, 82, 82, 82),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 2),
                  borderRadius: BorderRadius.circular(50),
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LocksPage(api: api!),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Config'),
                subtitle: const Text('Set token'),
                tileColor: const Color.fromARGB(66, 82, 82, 82),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 2),
                  borderRadius: BorderRadius.circular(50),
                ),
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SetupPage(api: api!),
                    ),
                  ).then((value) async {
                    final newApi = await getAPIFromSharedPreferences();
                    setState(() {
                      api = newApi;
                    });
                  });
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 4,
              )
            ],
          ),
        ),
      ),
    );
  }
}
