import Flutter
import UIKit
import OpenTok

public class SwiftVonagePlugin: NSObject, FlutterPlugin {
    var nativeView: FlutterPlatformView?
    var nativeViewFactory: FLNativeViewFactory?
    var session: OTSession?
    var publisher: OTPublisher?
    var sessionEvent: FlutterEventChannel?
    var hasStreamEvent: FlutterEventChannel?
    var sessionHandler = SessionHandlerStream()
    var hasStreamHandler = HasStreamHandler()
    
    
    public init(with registrar: FlutterPluginRegistrar) {
        super.init()
        let channel = FlutterMethodChannel(name: "vonage", binaryMessenger: registrar.messenger())
        sessionEvent = FlutterEventChannel(name: "vonage-video-chat-session", binaryMessenger: registrar.messenger())
        hasStreamEvent = FlutterEventChannel(name: "vonage-video-chat-hasStream", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(self, channel: channel)
        initEvents()
        let factory = FLNativeViewFactory(messenger: registrar.messenger())
        nativeViewFactory = factory
        print ("init nativeView", nativeViewFactory)
        registrar.register(factory, withId: "flutter-vonage-video-chat")
    }
    
    public func initEvents(){
        sessionEvent?.setStreamHandler(sessionHandler)
        hasStreamEvent?.setStreamHandler(hasStreamHandler)
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        registrar.addApplicationDelegate(SwiftVonagePlugin(with: registrar))
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "initSession" {
            var args = call.arguments as! Dictionary<String, Any>
            var sessionId: String = args["sessionId"] as! String
            var token: String = args["token"] as! String
            var apiKey: String = args["apiKey"] as! String
            initSession(sessionId: sessionId, token: token, apiKey: apiKey, result: result)
        } else if call.method == "endSession" {
            endSession(result: result)
        } else if call.method == "publishStream" {
            var args = call.arguments as! Dictionary<String, Any>
            var name: String = args["name"] as! String
            publishStream(name: name,  result: result)
        } else if call.method == "unpublishStream" {
            unpublishStream(result: result)
        } else if call.method == "enableMicrophone" {
            enableMicrophone(result: result)
        } else if call.method == "disableMicrophone" {
            disableMicrophone(result: result)
        } else if call.method == "enableCamera" {
            enableCamera(result: result)
        } else if call.method == "disableCamera" {
            disableCamera(result: result)
        } else {
          result("iOS " + UIDevice.current.systemVersion)
      }
    }

    func initSession(sessionId: String, token: String, apiKey: String, result: FlutterResult) {
      var resultDic = ["success" : false]
        session = OTSession(apiKey: apiKey, sessionId: sessionId, delegate: self)
      var error: OTError?
      session?.connect(withToken: token, error: &error)
      if error != nil {
         print(error!)
      } else {
          resultDic["success"] = true
      }
      sessionHandler.sessionChange(value: resultDic["success"] ?? false)
      result(resultDic)
    }

    func endSession(result: FlutterResult) {
        session?.disconnect()
        result("")
    }

    func publishStream(name: String, result: FlutterResult) {
        let settings = OTPublisherSettings()
      // settings.name = UIDevice.current.name
      settings.name = name
      publisher = OTPublisher(delegate: self, settings: settings)

      var error: OTError?
        session?.publish(publisher!, error: &error)
      guard error == nil else {
        print(error!)
        return
      }

      // print ("publishStream", SwiftFlutterVonageVideoPlugin.nativeView)
      // var view: UIView = SwiftFlutterVonageVideoPlugin.nativeView!.view()
      var view: UIView = nativeViewFactory!.getView()
      print ("publishStream", nativeViewFactory, view)
      // print ("publishStream", viewId)
      // var view: UIView = nativeView!.view()

        guard let publisherView = publisher?.view else {
        return
      }

      // let screenBounds = UIScreen.main.bounds
      // publisherView.frame = CGRect(x: screenBounds.width - 150 - 20, y: screenBounds.height - 150 - 20, width: 150, height: 150)
      publisherView.frame = view.bounds

      view.addSubview(publisherView)
      // view.backgroundColor = UIColor.red

        result("")
    }

    func unpublishStream(result: FlutterResult) {
        if publisher != nil {
            session?.unpublish(publisher!)
        }

        // TODO - get typing errors..
    //     for view in nativeView!.view()!.subviews {
          //   view.removeFromSuperview()
          // }

        result("")
    }
    
    func enableMicrophone(result: FlutterResult){
        if(publisher != nil){
            publisher!.publishAudio = true
            result(true)
        } else {
            result(FlutterError(code: "Enable Microphone Error", message: "Publisher is not initialized", details: nil))
        }
    }
    
    func disableMicrophone(result: FlutterResult){
        if(publisher != nil){
            publisher!.publishAudio = false
            result(true)
        } else {
            result(FlutterError(code: "Disable Microphone Error", message: "Publisher is not initialized", details: nil))
        }
    }
    
    func enableCamera(result: FlutterResult){
        if(publisher != nil){
            publisher!.publishVideo = true
            result(true)
        } else {
            result(FlutterError(code: "Enable Camera Error", message: "Publisher is not initialized", details: nil))
        }
        
    }
    
    func disableCamera(result: FlutterResult){
        if(publisher != nil){
            publisher!.publishVideo = false
            result(true)
        } else {
            result(FlutterError(code: "Enable Camera Error", message: "Publisher is not initialized", details: nil))
        }
    }
  }

  extension SwiftVonagePlugin: OTSessionDelegate {
      public func sessionDidConnect(_ session: OTSession) {
          print("The client connected to the OpenTok session.")
      }

      public func sessionDidDisconnect(_ session: OTSession) {
          print("The client disconnected from the OpenTok session.")
      }

      public func session(_ session: OTSession, didFailWithError error: OTError) {
          print("The client failed to connect to the OpenTok session: \(error).")
      }

      public func session(_ session: OTSession, streamCreated stream: OTStream) {
          print("A stream was created in the session.")
      }

      public func session(_ session: OTSession, streamDestroyed stream: OTStream) {
          print("A stream was destroyed in the session.")
      }
  }

  extension SwiftVonagePlugin: OTPublisherDelegate {
      public func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
          print("The publisher failed: \(error)")
      }
  }

class SessionHandlerStream: NSObject, FlutterStreamHandler {
    private var _eventSink: FlutterEventSink?
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        _eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        _eventSink = nil
        return nil
    }
    
    func sessionChange(value: Bool){
        _eventSink?(value)
    }
}

class HasStreamHandler: NSObject, FlutterStreamHandler {
    private var _eventSink: FlutterEventSink?
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        _eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        _eventSink = nil
        return nil
    }
    
    func hasStreamChange(value : Bool){
        _eventSink?(value)
    }
}
