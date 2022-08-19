import 'dart:async';

import 'package:flutter/services.dart';
import 'classes/session.dart';
import 'package:permission_handler/permission_handler.dart';

class VonageVideoChat {
  static const MethodChannel _channel = const MethodChannel('vonage');

  static const EventChannel _event = const EventChannel('vonage-video-chat-session');
  static const EventChannel _hasStream = const EventChannel('vonage-video-chat-hasStream');

  /// Listinner from session status, the type of return is [bool].
  /// 
  /// ```dart
  /// StreamBuilder(
  ///   stream: sessionStream
  ///   builder: (ctx,hasSession){
  ///     ...
  ///     if(hasSession){
  ///        // Session has initialize
  ///     } else {
  ///        // Session not initialize  
  ///     }
  ///     ...
  ///   }
  /// )
  /// ```
  Stream get sessionStream => _event.receiveBroadcastStream();
  /// Listinner from subscriber status, the type of return is [bool].
  /// 
  /// ```dart
  /// StreamBuilder(
  ///   stream: sessionStream
  ///   builder: (ctx,subscriberStatus){
  ///     ...
  ///     if(subscriberStatus){
  ///        // Subscriber has connected
  ///     } else {
  ///        // Subscriber disconected 
  ///     }
  ///     ...
  ///   }
  /// )
  /// ```
  Stream get hasStream => _hasStream.receiveBroadcastStream();
  /// Use a [Session] to use initialized session to OpenTok.
  /// 
  /// Return a [SessionResponse] value.
  static Future<SessionResponse> initSession(Session session, String patientName) async {
    print ('initSession');
    bool havePermissions = await checkPermissions();
    if (havePermissions) {
      try {
        final result = await _channel.invokeMethod('initSession', { "sessionId": session.id, "token": session.token,
          "apiKey": session.apiKey, 'patientName': patientName });
        return SessionResponse.fromJson(result);
      } on PlatformException {
        return SessionResponse(false);
      }
    }
    print("permissions not granted");
    return SessionResponse(false);
  }
  /// Close the OpenTok session.
  static Future<String> endSession() async {
    print ('endSession');
    try {
      return await _channel.invokeMethod('endSession', {});
    } on PlatformException {
      return "error";
    }
  }
  /// Initialized the publisher from OpenTok session.
  /// 
  /// Use this function after call [initSession] function.
  /// 
  /// Case this session is not initialized, results in false.
  static Future<bool> publishStream(String publisherName) async {
    try {
      final result = await _channel.invokeMethod('publishStream', { "name": publisherName });
      return result["success"] == true;
    } on PlatformException catch (err) {
      print(err);
      return false;
    }
  }

  static Future<String> unpublishStream() async {
    try {
      return await _channel.invokeMethod('unpublishStream', {});
    } on PlatformException {
      return "error";
    }
  }

  static Future<bool> checkPermissions() async {
    bool cameraGranted = await Permission.camera.request().isGranted;
    bool cameraDenied = false;
    if (!cameraGranted) {
      cameraDenied = await Permission.camera.isPermanentlyDenied;
    }
    bool microphoneGranted = await Permission.microphone.request().isGranted;
    bool microphoneDenied = false;
    if (!microphoneGranted) {
      microphoneDenied = await Permission.microphone.isPermanentlyDenied;
    }

    if (cameraDenied || microphoneDenied) {
      openAppSettings();
    }
    if (cameraGranted && microphoneGranted) {
      return true;
    }
    return false;
  }

  static Future<bool> enableMicrophone() async{
    bool result = false;
    try{
      await _channel.invokeMethod('enableMicrophone');
      result = true;
    } catch(err){
      result = false;
    }
    return result;
  }
  static Future<bool> disableMicrophone() async{
    bool result = false;
    try{
      await _channel.invokeMethod('disableMicrophone');
      result = true;
    } catch(err){
      print(err);
    }
    return result;
  }
  static Future<bool> enableCamera() async{
    bool result = false;
    try{
      await _channel.invokeMethod('enableCamera');
      result = true;
    } catch(err){
      print(err);
    }
    return result;
  }
  static Future<bool> disableCamera() async{
    bool result = false;
    try{
      await _channel.invokeMethod('disableCamera');
      result = true;
    } catch(err){
      print(err);
    }
    return result;
  }
  /// Enable and disabled the subscriber audio, if subscriber is connected
  /// ```dart
  /// setSubscriberAudioStatus(true);// enable audio
  /// setSubscriberAudioStatus(false);// disabled audio
  /// ```
  static Future<void> setSubscriberAudioStatus(bool status) async{
    try {
      await _channel.invokeMethod('setSubscriberAudio',{ 'status' : status});
    } catch (err){
      print(err);
    }
  } 
}

