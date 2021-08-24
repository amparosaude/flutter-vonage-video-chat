package br.com.mesainc.vonage;

import android.os.Handler;

import io.flutter.plugin.common.EventChannel;

public class HasStreamEvent implements EventChannel.StreamHandler {
    private boolean hasStream = false;
    private EventChannel.EventSink sink;
    private final Handler handler = new Handler();

    private final Runnable runnable = new Runnable() {
        @Override
        public void run() {
            sink.success(hasStream);
        }
    };

    public void changeHasStream(boolean value){
        this.hasStream = value;
        handler.post(runnable);
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        sink = events;
    }

    @Override
    public void onCancel(Object arguments) {
        sink = null;
        handler.removeCallbacks(runnable);
    }
}
