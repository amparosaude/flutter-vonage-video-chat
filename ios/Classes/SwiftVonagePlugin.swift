import Flutter
import UIKit
import OpenTok

public class SwiftVonagePlugin: NSObject, FlutterPlugin {
    var nativeView: FlutterPlatformView?
    var nativePublisherViewFactory: FLNativeViewFactory?
    var nativeSubscriberViewFactory: FLNativeViewFactory?
    var session: OTSession?
    var publisher: OTPublisher?
    var subscriber: OTSubscriber?
    var sessionEvent: FlutterEventChannel?
    var hasStreamEvent: FlutterEventChannel?
    var sessionHandler = SessionHandlerStream()
    var hasStreamHandler = HasStreamHandler()
    var subscriberStream: OTStream?
    var subscriberNoCameraImageView: UIView?
    var volumeOnView: UIView?
    var volumeOffView: UIView?
    
    private var subscriberNoCameraViewTag = 100
    private var subscriberVolumeOnTag = 110
    private var subscriberVolumeOffTag = 111
    
    private var pluginCodeLog = "Vonage-video-chat"
    
    private var subscriberAudioStatus : Bool?
    private var subscriberVideoStatus : Bool?
    
    public init(with registrar: FlutterPluginRegistrar) {
        super.init()
        let channel = FlutterMethodChannel(name: "vonage", binaryMessenger: registrar.messenger())
        sessionEvent = FlutterEventChannel(name: "vonage-video-chat-session", binaryMessenger: registrar.messenger())
        hasStreamEvent = FlutterEventChannel(name: "vonage-video-chat-hasStream", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(self, channel: channel)
        initEvents()
        let factory = FLNativeViewFactory(messenger: registrar.messenger())
        nativePublisherViewFactory = factory
        let factorySubscriber = FLNativeViewFactory(messenger: registrar.messenger())
        nativeSubscriberViewFactory = factorySubscriber
        print ("init nativeView", nativePublisherViewFactory)
        registrar.register(factory, withId: "flutter-vonage-publisher-view")
        registrar.register(factorySubscriber, withId: "flutter-vonage-subscriber-view")
        initScreens()
    }
    
    func initScreens(){
        subscriberNoCameraImageView = child.view
        let videoCamOff = UIImage(named: "videocam_off")?
            .withRenderingMode(.alwaysTemplate)
            .withTintColor(.white)
        let soundEnabled = UIImage(named: "volume_on")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.white)
        let soundDisabled = UIImage(named: "volume_off")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.white)
        let videoOffView = UIImageView(image: videoCamOff!)
        videoOffView.tintColor = .white
        videoOffView.frame = UIScreen.main.bounds
        videoOffView.contentMode = .scaleAspectFit
        subscriberNoCameraImageView!.addSubview(videoOffView)
        let volumeOnView = UIImageView(image: soundEnabled!)
        volumeOnView.tintColor = .white
        volumeOnView.frame = CGRect(
            x: volumeOnView.frame.origin.x + 20,
            y: volumeOnView.frame.origin.y + 20,
            width: volumeOnView.frame.width,
            height: volumeOnView.frame.height
            )
        self.volumeOnView = volumeOnView
        
        let volumeOffView = UIImageView(image: soundDisabled!)
        volumeOffView.tintColor = .white
        volumeOffView.frame = CGRect(
            x: volumeOffView.frame.origin.x + 20,
            y: volumeOffView.frame.origin.y + 20,
            width: volumeOffView.frame.width,
            height: volumeOffView.frame.height
            )
        self.volumeOffView = volumeOffView
        
        volumeOnView.tag = subscriberVolumeOnTag
        subscriberNoCameraImageView!.addSubview(volumeOnView)
        
        
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
        var resultDic = ["success" : false]
        do{
          
          let settings = OTPublisherSettings()
          settings.name = name
          publisher = OTPublisher(delegate: self, settings: settings)

          var view: UIView = nativePublisherViewFactory!.getView()
          print ("publishStream", nativePublisherViewFactory, view)

          guard let publisherView = publisher?.view else {
            result(FlutterError(code: pluginCodeLog, message: "Cannot get publisher view", details: nil))
            return
          }

          publisherView.frame = view.bounds

          view.addSubview(publisherView)
            
            var error: OTError?
              session?.publish(publisher!, error: &error)
            guard error == nil else {
              print(error!)
              result(FlutterError(code: pluginCodeLog, message: error!.description, details: nil))
              return
            }

          resultDic["success"] = true
            
          result(resultDic)
        } catch {
            result(FlutterError(
                code: pluginCodeLog, message: "Error in plublisher function", details: nil
            ))
        }
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
          print(pluginCodeLog,"The client connected to the OpenTok session.")
      }

      public func sessionDidDisconnect(_ session: OTSession) {
          print(pluginCodeLog,"The client disconnected from the OpenTok session.")
        nativePublisherViewFactory?.getView().subviews.forEach({ v in
            v.removeFromSuperview()
        })
        nativeSubscriberViewFactory?.getView().subviews.forEach({ v in
            v.removeFromSuperview()
        })
        print(nativePublisherViewFactory?.getView().subviews.count)
        print(nativeSubscriberViewFactory?.getView().subviews.count)
      }

      public func session(_ session: OTSession, didFailWithError error: OTError) {
          print("The client failed to connect to the OpenTok session: \(error).")
      }

      public func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("A stream was created in the session.")
        
        subscriber = OTSubscriber(stream: stream, delegate: self)
        guard let subscriber = subscriber else {
            return
        }
        subscriberStream = stream
        var error: OTError?
        
        session.subscribe(subscriber, error: &error)
        guard error == nil else {
            print(error!)
            return
        }
        
        guard let subscriberView = subscriber.view else {
            return
        }
        subscriberAudioStatus = stream.hasAudio
        subscriberVideoStatus = stream.hasVideo
        var view: UIView = nativeSubscriberViewFactory!.getView()
        subscriberView.frame = UIScreen.main.bounds
        view.addSubview(subscriberView)
        subscriber.audioLevelDelegate = self
        hasStreamHandler.hasStreamChange(value: true)
        if(publisher != nil){
            var error: OTError?
              session.publish(publisher!, error: &error)
            guard error == nil else {
              print(error!)
              return
            }
        }
        
      }

      public func session(_ session: OTSession, streamDestroyed stream: OTStream) {
          print("A stream was destroyed in the session.")
        hasStreamHandler.hasStreamChange(value: false)
      }
    
    
  }
extension SwiftVonagePlugin: OTSubscriberKitAudioLevelDelegate{
    public func subscriber(_ subscriber: OTSubscriberKit, audioLevelUpdated audioLevel: Float) {
        var newStatus : Bool
        
        if audioLevel.isZero {
            newStatus = false
        } else {
            newStatus = true
        }
        if(subscriberAudioStatus != nil && newStatus != subscriberAudioStatus){
            let view: UIView = subscriberNoCameraImageView!
            if let viewToRemove = view.viewWithTag(subscriberAudioStatus! ? subscriberVolumeOnTag : subscriberVolumeOffTag) {
                viewToRemove.removeFromSuperview()
            } else {
                print("volume image not found in view")
            }
            var newView: UIView
            if(newStatus){
                newView = volumeOnView!
                newView.tag = subscriberVolumeOnTag
            } else {
                newView = volumeOffView!
                newView.tag = subscriberVolumeOffTag
            }
            view.addSubview(newView)
            subscriberAudioStatus = newStatus
        }
//        print("Subscriber - Audio - ",audioLevel.isZero ? "disable" : "enable")
    }
    
}

extension SwiftVonagePlugin: OTPublisherDelegate {
    public func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
      print("The publisher failed: \(error)")
    }
    
    public func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        
    }
}

extension SwiftVonagePlugin: OTSubscriberDelegate {
    public func subscriberDidConnect(toStream subscriber: OTSubscriberKit) {
        print("The subscriber did connect to the stream")
    }
    
    public func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("The subscriber failed to connect to the stream")
    }
    
    public func subscriberVideoEnabled(_ subscriber: OTSubscriberKit, reason: OTSubscriberVideoEventReason) {
        print("Subscriber - Video - Enabled")
        let view: UIView = nativeSubscriberViewFactory!.getView()
        if let noCameraView = view.viewWithTag(subscriberNoCameraViewTag) {
            noCameraView.removeFromSuperview()
        } else {
            
        }
        
    }
    
    public func subscriberVideoDisabled(_ subscriber: OTSubscriberKit, reason: OTSubscriberVideoEventReason) {
        print("Subscriber - Video - Disabled")
        let view: UIView = nativeSubscriberViewFactory!.getView()
        subscriberNoCameraImageView?.tag = subscriberNoCameraViewTag
        view.addSubview(subscriberNoCameraImageView!)
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
