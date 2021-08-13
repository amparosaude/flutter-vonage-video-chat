package br.com.mesainc.vonage;

import android.content.Context;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Map;

import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformViewFactory;

// import android.widget.TextView;

class NativeViewFactory extends PlatformViewFactory {
  NativeView platformView;

  NativeViewFactory() {
    super(StandardMessageCodec.INSTANCE);
  }

  @NonNull
  @Override
  public NativeView create(@NonNull Context context, int id, @Nullable Object args) {
    final Map<String, Object> creationParams = (Map<String, Object>) args;
    this.platformView = new NativeView(context, id, creationParams);
    return this.platformView;
  }

  public FrameLayout getView() {
    return this.platformView.getView();
  }
}
