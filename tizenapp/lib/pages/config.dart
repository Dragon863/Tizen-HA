import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tizenapp/utils/hass.dart';
import 'package:tizenapp/utils/proxy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupPage extends StatefulWidget {
  final API api;

  const SetupPage({Key? key, required this.api}) : super(key: key);

  @override
  _SetupPageState createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final PageController _pageController = PageController();
  bool miniButton = false;
  Future<String>? _codeFuture;
  String displayedCode = 'placeholder';

  @override
  void initState() {
    super.initState();
    _codeFuture = generateCode();
  }

  Future<String> generateCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final code =
        await requestHTTP("https://setup.danieldb.uk/generate_code", "GET");
    final dataJson = jsonDecode(code);
    prefs.setString('code', dataJson['code']);
    return dataJson['code'];
  }

  Future<Map> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String code = prefs.getString('code')!;
    print(code);
    Map result = {};
    do {
      final response = await requestHTTP(
          "https://setup.danieldb.uk/get_token", "POST",
          headers: {"content-type": 'application/json'},
          body: jsonEncode({'code': code}));
      result = jsonDecode(response);
      await Future.delayed(const Duration(seconds: 1));
      print(result);
    } while (result['token'] == 'placeholder' || result.isEmpty);
    prefs.setString('token', result['token']);
    prefs.setString('server', result['server']);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          CodePage(codeFuture: _codeFuture!),
          TokenPage(code: displayedCode, getToken: getToken),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: miniButton
            ? FloatingActionButton(
                isExtended: true,
                onPressed: () {
                  print(_pageController.page);
                  if (_pageController.page!.round() < 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  } else {
                    Navigator.of(context).pop(context);
                  }
                  if (_pageController.page == 0.0) {
                    setState(() {
                      miniButton = true;
                    });
                  }
                },
                mini: miniButton,
                child: const Icon(Icons.arrow_forward),
              )
            : FloatingActionButton(
                onPressed: () {
                  print(_pageController.page!);
                  if (_pageController.page!.round() < 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  } else {
                    Navigator.of(context).pop(context);
                  }
                  if (_pageController.page == 0.0) {
                    setState(() {
                      miniButton = true;
                    });
                  }
                },
                mini: miniButton,
                child: const Icon(Icons.arrow_forward),
              ),
      ),
    );
  }
}

class CodePage extends StatelessWidget {
  final Future<String> codeFuture;

  CodePage({super.key, required this.codeFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: codeFuture,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('1. Visit setup.danieldb.uk'),
                  const Text('2. Input the following code:'),
                  Text(
                    snapshot.data!,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }
        }
      },
    );
  }
}

class TokenPage extends StatelessWidget {
  final String code;
  final Future<Map> Function() getToken;

  const TokenPage({super.key, required this.code, required this.getToken});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder<Map>(
            future: getToken(),
            builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Waiting for code on site...'),
                    SizedBox(height: 5),
                    CircularProgressIndicator()
                  ],
                ));
              } else {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Tap below if you entered this:'),
                        Text('${snapshot.data!['server']}'),
                      ],
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
