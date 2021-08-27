import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:vonage/vonage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _tokboxSessionId = 'sessionID';
  String _tokboxToken = 'publisherToken';
  String _tokboxApiKey = '47301794';
  String _publishId = 'PublishId';

  bool _sessionInited = false;
  bool _isPublishing = false;
  bool _camareEnabled = true;
  bool _microphoneEnabled = true;

  int _pluginViewId = -1;

  @override
  void initState() {
    super.initState();
    _startAll();
  }

  Future<void> _startAll() async{
    await _initSession();
    await Future.delayed(Duration(seconds: 2));
    await _publishStream();
  }

  Future<void> _initSession() async {
    final session = Session(id: _tokboxSessionId, token: _tokboxToken, apiKey: _tokboxApiKey);
    var result = await VonageVideoChat.initSession(session);
    setState(() {
      _sessionInited = true;
      _isPublishing = false;
    });
    print(result.status);
  }

  Future<void> _publishStream() async {
    var ret = await VonageVideoChat.publishStream("Jõao");
    setState(() {
      _isPublishing = true;
    });
  }

  Future<void> _unpublishStream() async {
    String ret = await VonageVideoChat.unpublishStream();
    setState(() {
      _isPublishing = false;
    });
  }


  Future _changeMicrophoneStatus() async{
    bool result = false;
    if(_microphoneEnabled){
      result = await VonageVideoChat.disableMicrophone();
    } else {
      result = await VonageVideoChat.enableMicrophone();
    }
    if(result){
      setState(() {
        _microphoneEnabled = !_microphoneEnabled;
      });
    }
  }

  Future _changeCameraStatus() async {
    bool result = false;
    if(_camareEnabled){
      result = await VonageVideoChat.disableCamera();
    } else {
      result = await VonageVideoChat.enableCamera();
    }
    if(result){
      setState(() {
        _camareEnabled = !_camareEnabled;
      });
    }
  }

  @override
  void dispose() {
    if (_isPublishing) {
      _unpublishStream();
    }
    if (_sessionInited) {
      VonageVideoChat.endSession();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context,_){
        var size = MediaQuery.of(context).size;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Vonage Video chat example app'),
          ),
          body: Container(
            width: size.width,
            height: size.height,
            // child: VonageVideoChatScreen(),
            child: Stack(
              children: [
                VonageVideoChatScreen(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: renderButtons(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget renderButtons(){
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(                
              color: Colors.blueGrey,
              borderRadius: BorderRadius.circular(8)
            ),
            child: IconButton(
              icon: Icon(
                _microphoneEnabled ? Icons.mic_rounded : Icons.mic_off_rounded,
                size: 32,
              ),
              onPressed: _changeMicrophoneStatus,
              // color: Colors.blueGrey,
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(                
              color: Colors.red,
              borderRadius: BorderRadius.circular(8)
            ),
            child: IconButton(
              icon: Icon(
                Icons.phone,
                size: 32,
              ),
              onPressed: (){

              },
              // color: Colors.blueGrey,
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(                
              color: Colors.blueGrey,
              borderRadius: BorderRadius.circular(8)
            ),
            child: IconButton(
              icon: Icon(
                _camareEnabled ? Icons.videocam : Icons.videocam_off,
                size: 32,
              ),
              onPressed: _changeCameraStatus,
              // color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }
}