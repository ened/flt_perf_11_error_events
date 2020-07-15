import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamSubscription<dynamic> _subscription;

  Map<String, dynamic> _latest;

  /// Adjust this variable to a maximum iteration count.
  /// -1 will let it run indefinitely.
  final int maximum = 900000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Press Start to start generating events'),
            if (_latest != null) Text('latest: $_latest'),
            RaisedButton(
              child: Text('Start generating errors in Plugin'),
              onPressed: () {
                if (_subscription == null) {
                  _subscription =
                      EventChannel('app/events').receiveBroadcastStream({
                    'type': 'error',
                    'maximum': maximum,
                  }).listen((event) {
                    setState(() => _latest = event);
                  });
                }
              },
            ),
            RaisedButton(
              child: Text('Start generating errors in Locally'),
              onPressed: () {
                if (_subscription == null) {
                  _subscription = EventChannel('app/events')
                      .receiveBroadcastStream({
                        'type': 'regular',
                        'maximum': maximum,
                      })
                      .map<Map<dynamic, dynamic>>((event) => event)
                      .listen((event) {
                        setState(() {
                          _latest = event;
                        });
                      });
                }
              },
            ),
            RaisedButton(
              child: Text('Stop'),
              onPressed: () {
                _subscription?.cancel();
                _subscription = null;
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;

    super.dispose();
  }
}
