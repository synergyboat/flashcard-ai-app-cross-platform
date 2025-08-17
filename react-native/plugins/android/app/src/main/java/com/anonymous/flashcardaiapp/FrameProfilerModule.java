package com.anonymous.flashcardaiapp;

import android.os.Build;
import android.view.Choreographer;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.Promise;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.util.ArrayList;
import java.util.List;

public class FrameProfilerModule extends ReactContextBaseJavaModule {
    private Choreographer.FrameCallback frameCallback;
    private long lastFrameTimeNanos = 0L;
    private boolean profiling = false;
    private List<Double> frameDurations = new ArrayList<>();

    public FrameProfilerModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @NonNull
    @Override
    public String getName() {
        return "FrameProfiler";
    }

    @ReactMethod
    public void startProfiling(Promise promise) {
        try {
            if (profiling) {
                promise.resolve(null);
                return;
            }
            
            profiling = true;
            frameDurations.clear();
            lastFrameTimeNanos = 0L;
            
            frameCallback = new Choreographer.FrameCallback() {
                @Override
                public void doFrame(long frameTimeNanos) {
                    if (lastFrameTimeNanos > 0) {
                        long diffNanos = frameTimeNanos - lastFrameTimeNanos;
                        double diffMs = diffNanos / 1_000_000.0;
                        frameDurations.add(diffMs);

                        // Optional: emit events for real-time monitoring
                        try {
                            WritableMap map = Arguments.createMap();
                            map.putDouble("frameTimeMs", diffMs);
                            getReactApplicationContext()
                                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                                .emit("onFrame", map);
                        } catch (Exception e) {
                            // Ignore event emission errors
                        }
                    }
                    lastFrameTimeNanos = frameTimeNanos;
                    if (profiling) {
                        Choreographer.getInstance().postFrameCallback(this);
                    }
                }
            };
            
            Choreographer.getInstance().postFrameCallback(frameCallback);
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject("PROFILER_ERROR", "Failed to start profiling: " + e.getMessage());
        }
    }

    @ReactMethod
    public void stopProfiling(Promise promise) {
        try {
            profiling = false;
            if (frameCallback != null) {
                Choreographer.getInstance().removeFrameCallback(frameCallback);
                frameCallback = null;
            }
            
            WritableArray result = Arguments.createArray();
            for (Double duration : frameDurations) {
                result.pushDouble(duration);
            }
            
            promise.resolve(result);
        } catch (Exception e) {
            promise.reject("PROFILER_ERROR", "Failed to stop profiling: " + e.getMessage());
        }
    }
}