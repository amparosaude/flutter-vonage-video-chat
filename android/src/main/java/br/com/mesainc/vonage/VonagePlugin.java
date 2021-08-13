package br.com.mesainc.vonage;

import android.content.Context;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;

import androidx.annotation.NonNull;

import com.opentok.android.BaseVideoRenderer;
import com.opentok.android.OpentokError;
import com.opentok.android.Publisher;
import com.opentok.android.PublisherKit;
import com.opentok.android.Session;
import com.opentok.android.Stream;
import com.opentok.android.Subscriber;
import com.opentok.android.SubscriberKit;

import java.util.HashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.reactivex.Observable;

/** VonagePlugin.kt */
public class VonagePlugin implements FlutterPlugin, MethodCallHandler,
  Session.SessionListener, PublisherKit.PublisherListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private EventChannel event;
  private EventChannel eventHasStream;
  private NativeViewFactory nativeVonageView;
  private NativeViewFactory nativePublisherView;
  private View vonageView;
  private View noCameraView;
  private View noCameraSubscriberView;
  private ImageView soundEnabledSubscriber;

  private Context mContext;
  private ExecutorService executor
          = Executors.newSingleThreadExecutor();

  private FrameLayout publisherViewContainer;
  private FrameLayout subscriberViewContainer;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    Log.d(LOG_TAG,"onAttachedToEngine");
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "vonage");
    event = new EventChannel(flutterPluginBinding.getBinaryMessenger(),"vonage-video-chat-session");
    eventHasStream = new EventChannel(flutterPluginBinding.getBinaryMessenger(),"vonage-video-chat-hasStream");
    initEvents();
    channel.setMethodCallHandler(this);

    mContext = flutterPluginBinding.getApplicationContext();

    nativeVonageView = new NativeViewFactory();
    nativePublisherView = new NativeViewFactory();
    flutterPluginBinding.getPlatformViewRegistry()
            .registerViewFactory("flutter-vonage-video-chat", nativeVonageView);
    flutterPluginBinding.getPlatformViewRegistry()
            .registerViewFactory("flutter-vonage-publisher-view", nativePublisherView);
    vonageView = View.inflate(mContext, R.layout.vonage_view, null);
    noCameraView = View.inflate(mContext,R.layout.no_camera,null);
    noCameraSubscriberView = View.inflate(mContext,R.layout.no_camera,null);
    soundEnabledSubscriber = noCameraSubscriberView.findViewById(R.id.sound_enable);
    publisherViewContainer = vonageView.findViewById(R.id.publisher_container);
    subscriberViewContainer = vonageView.findViewById(R.id.subscriber_container);


  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("initSession")) {
      result.success(initSession(call.argument("sessionId"), call.argument("token"), call.argument("apiKey")));
    } else if (call.method.equals("endSession")) {
      result.success(endSession());
    } else if (call.method.equals("publishStream")) {
      result.success(publishStream(call.argument("name")));
    } else if (call.method.equals("unpublishStream")) {
      result.success(unpublishStream());
    } else if (call.method.equals("enableMicrophone")) {
      if(enableMicrophone()){
        result.success(true);
      } else {
        result.error("enableMicrophone Error","Publisher not initialized",null);
      }
    } else if (call.method.equals("disableMicrophone")) {
      if(disableMicrophone()){
        result.success(true);
      } else {
        result.error("disableMicrophone Error","Publisher not initialized",null);
      }
    } else if (call.method.equals("enableCamera")) {
      if(enableCamera()){
        result.success(true);
      } else {
        result.error("enableCamera Error","Publisher not initialized",null);
      }
    } else if (call.method.equals("disableCamera")) {
      if(disableCamera()){
        result.success(true);
      } else {
        result.error("disableCamera Error","Publisher not initialized",null);
      }
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    Log.d(LOG_TAG,"onDetachedFromEngine");
  }



  private static final String LOG_TAG = "flutter-vonage-video-log-tag";

  private Session mSession;
  private Publisher mPublisher;
  private Subscriber mSubscriber;

  private boolean hasStream = false;
  private boolean sessionStatus = false;
  private boolean subscriberAudioEnabled = false;

  private String _sessionId;
  private String _token;
  private String _apiKey;

  private void  initEvents(){
    event.setStreamHandler(new EventChannel.StreamHandler() {
      @Override
      public void onListen(Object arguments, EventChannel.EventSink events) {
        events.success(sessionStatus);
      }

      @Override
      public void onCancel(Object arguments) {

      }
    });

    eventHasStream.setStreamHandler(new EventChannel.StreamHandler() {
      @Override
      public void onListen(Object arguments, EventChannel.EventSink events) {
        events.success(hasStream);
      }

      @Override
      public void onCancel(Object arguments) {

      }
    });
  }


  private HashMap<String,Object> initSession(String sessionId, String token, String apiKey){
    HashMap<String,Object> result = new HashMap<String,Object>();
    try{

      _sessionId = sessionId;
      _token = token;
      _apiKey = apiKey;
      Future x = initializeSession();
      while(!x.isDone()){};
      if(nativeVonageView.platformView != null) {
        nativeVonageView.getView().addView(vonageView);
      }
      synchronized (event){
        event.notify();
      }
      result.put("success",true);
    } catch (Exception error){
      Log.d(LOG_TAG,error.toString());
      result.put("success",false);
      throw error;
    }
    renderView();
    return result;

  }

  private String publishStream(String name) {
    try {
      mPublisher = new Publisher.Builder(mContext).name(name).build();
      mPublisher.setPublisherListener(this);
      if(publisherViewContainer != null) {
        if(publisherViewContainer.getParent() != null) {
          ((ViewGroup)publisherViewContainer.getParent()).removeView(mPublisher.getView()); // <- fix
        }
        publisherViewContainer.addView(mPublisher.getView());
      }
      mSession.publish(mPublisher);
    } catch (Exception error){
      Log.e(LOG_TAG,error.toString());
    }
    return "";
  }

  private String unpublishStream() {
    mSession.unpublish(mPublisher);
    if(publisherViewContainer != null) {
      publisherViewContainer.removeAllViews();
    }
    //publisherViewContainer.addView();
    return "";
  }

  private String endSession() {
    mSession.disconnect();
    return "";
  }


  private Future initializeSession() {
    mSession = new Session.Builder(mContext, _apiKey, _sessionId).build();
    mSession.setSessionListener(this);

    return executor.submit(()-> {
      mSession.connect(_token);
    });
  }

  private String subscribingStream(){
    subscriberViewContainer.removeAllViews();
    if(mSubscriber != null && mSubscriber.getView() != null) {
      subscriberViewContainer.addView(mSubscriber.getView());
      mSession.subscribe(mSubscriber);
    } else {
      subscriberViewContainer.addView(View.inflate(mContext,R.layout.progress,null));
    }
    return "";
  }

  private void renderView(){
    subscribingStream();
    if(mPublisher != null && publisherViewContainer != null) {
      publisherViewContainer.removeAllViews();
      publisherViewContainer.addView(mPublisher.getView());
    }
  }

  private boolean enableMicrophone(){
    boolean result = false;
    if(mPublisher != null) {
      mPublisher.setPublishAudio(true);
      result = true;
    }
    return result;
  }

  private boolean disableMicrophone(){
    boolean result = false;
    if(mPublisher != null) {
      mPublisher.setPublishAudio(false);
      result = true;
    }
    return result;
  }

  private boolean enableCamera(){
    boolean result = false;
    if(mPublisher != null) {
      mPublisher.setPublishVideo(true);
      result = true;
      publisherViewContainer.removeView(noCameraView);
    }
    return result;
  }

  private boolean disableCamera(){
    boolean result = false;
    if(mPublisher != null) {
      mPublisher.setPublishVideo(false);
      result = true;
      publisherViewContainer.addView(noCameraView);
    }
    return result;
  }

  // SessionListener methods
  @Override
  public void onConnected(Session session) {
    Log.i(LOG_TAG, "Session Connected");
    sessionStatus = true;

    if(publisherViewContainer == null) {
      publisherViewContainer = vonageView.findViewById(R.id.publisher_container);
    }
    if(subscriberViewContainer == null){
      subscriberViewContainer = vonageView.findViewById(R.id.subscriber_container);
    }
  }

  @Override
  public void onDisconnected(Session session) {
    Log.i(LOG_TAG, "Session Disconnected");
    //vonageView = null;
    sessionStatus = false;
    publisherViewContainer.removeAllViews();
    subscriberViewContainer.removeAllViews();
    nativeVonageView.getView().removeAllViews();
  }

  @Override
  public void onStreamReceived(Session session, Stream stream) {
    Log.d(LOG_TAG, "onStreamReceived: New Stream Received " + stream.getStreamId() + " in session: " + session.getSessionId());

    if (stream != null){

      mSubscriber = new Subscriber.Builder(mContext, stream).build();
      mSubscriber.getRenderer().setStyle(BaseVideoRenderer.STYLE_VIDEO_SCALE, BaseVideoRenderer.STYLE_VIDEO_FILL);
      Log.d(LOG_TAG,mPublisher.toString());
      mSubscriber.setAudioLevelListener(new SubscriberKit.AudioLevelListener() {
        @Override
        public void onAudioLevelUpdated(SubscriberKit subscriberKit, float v) {
          if(v == 0){
            if(subscriberAudioEnabled){
              subscriberAudioEnabled = false;
              soundEnabledSubscriber.setImageResource(R.drawable.ic_baseline_volume_off_24);
            }
          } else {
            if(!subscriberAudioEnabled){
              subscriberAudioEnabled = true;
              soundEnabledSubscriber.setImageResource(R.drawable.ic_baseline_volume_up_24);
            }
          }
        }
      });
      mSubscriber.setVideoListener(new SubscriberKit.VideoListener() {
        @Override
        public void onVideoDataReceived(SubscriberKit subscriberKit) {

        }

        @Override
        public void onVideoDisabled(SubscriberKit subscriberKit, String s) {
          subscriberViewContainer.addView(noCameraSubscriberView);
        }

        @Override
        public void onVideoEnabled(SubscriberKit subscriberKit, String s) {
          subscriberViewContainer.removeView(noCameraSubscriberView);
        }

        @Override
        public void onVideoDisableWarning(SubscriberKit subscriberKit) {

        }

        @Override
        public void onVideoDisableWarningLifted(SubscriberKit subscriberKit) {

        }
      });
      if(mPublisher!=null) {
        mSession.publish(mPublisher);
      }
      renderView();
    }
  }

  @Override
  public void onStreamDropped(Session session, Stream stream) {
    Log.i(LOG_TAG, "Stream Dropped");
    subscriberViewContainer.removeView(mSubscriber.getView());

  }

  @Override
  public void onError(Session session, OpentokError opentokError) {
    Log.e(LOG_TAG, "Session error: " + opentokError.getMessage() + " / code :"+opentokError.getErrorCode().toString());

  }

  // PublisherListener methods
  @Override
  public void onStreamCreated(PublisherKit publisherKit, Stream stream) {
    Log.i(LOG_TAG, "Publisher onStreamCreated");
    renderView();
  }

  @Override
  public void onStreamDestroyed(PublisherKit publisherKit, Stream stream) {
    Log.i(LOG_TAG, "Publisher onStreamDestroyed");
  }

  @Override
  public void onError(PublisherKit publisherKit, OpentokError opentokError) {
    Log.e(LOG_TAG, "Publisher error: " + opentokError.getMessage());
  }

}
