package br.com.mesainc.vonage;

import android.content.Context;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

// import android.widget.TextView;

class NativeViewFactory extends PlatformViewFactory {
  NativeView platformView;

  NativeViewFactory(){
    super(StandardMessageCodec.INSTANCE);
  }

  @NonNull
  @Override
  public PlatformView create(@NonNull Context context, int id, @Nullable Object args) {
    Log.d("NativeViewFactory - Vonage","Create factory");
    final Map<String, Object> creationParams = (Map<String, Object>) args;
    if(this.platformView == null) {
      this.platformView = new NativeView(context, id, creationParams);
    }
    return this.platformView;
  }

  public FrameLayout getView() {
    return this.platformView.getView();
  }
}
