package br.com.mesainc.vonage;

import android.os.Handler;
import io.flutter.plugin.common.EventChannel;

public class HasSessionEvent implements EventChannel.StreamHandler {
    private boolean hasSession = false;
    private EventChannel.EventSink sink;
    private final Handler handler = new Handler();

    private final Runnable runnable = new Runnable() {
        @Override
        public void run() {
            sink.success(hasSession);
        }
    };

    public void changeSession(boolean value){
        this.hasSession = value;
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
