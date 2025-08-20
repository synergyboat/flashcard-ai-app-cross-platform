package com.anonymous.flashcardaiapp;

import android.app.ActivityManager;
import android.content.Context;
import android.os.Debug;
import android.os.Process;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Promise;

public class MemoryProfilerModule extends ReactContextBaseJavaModule {
    private final ReactApplicationContext reactContext;

    public MemoryProfilerModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @NonNull
    @Override
    public String getName() {
        return "MemoryProfiler";
    }

    @ReactMethod
    public void getCurrentMemoryUsage(Promise promise) {
        try {
            // Use PSS as the closest Android equivalent to RSS
            // PSS = Private memory + (Shared memory / # of processes using it)
            Debug.MemoryInfo memoryInfo = new Debug.MemoryInfo();
            Debug.getMemoryInfo(memoryInfo);
            
            // PSS in KB, convert to bytes for consistency with iOS
            double totalPssBytes = memoryInfo.getTotalPss() * 1024.0;
            double totalPssMB = totalPssBytes / (1024.0 * 1024.0);

            WritableMap map = Arguments.createMap();
            
            // Primary metrics for benchmarking (matches iOS structure)
            map.putDouble("totalAppMemoryBytes", totalPssBytes);
            map.putDouble("totalAppMemoryMB", totalPssMB);
            
            // Raw PSS for debugging
            map.putDouble("totalPSS", totalPssBytes);
            map.putLong("timestamp", System.currentTimeMillis());

            promise.resolve(map);
        } catch (Exception e) {
            promise.reject("MEMORY_ERROR", "Failed to get memory usage: " + e.getMessage());
        }
    }
    
    @ReactMethod
    public void getDetailedMemoryInfo(Promise promise) {
        try {
            // Detailed memory breakdown for analysis (not used in benchmarks)
            Debug.MemoryInfo memoryInfo = new Debug.MemoryInfo();
            Debug.getMemoryInfo(memoryInfo);
            
            // Native heap info
            long nativeHeapSize = Debug.getNativeHeapSize();
            long nativeHeapAllocated = Debug.getNativeHeapAllocatedSize();
            long nativeHeapFree = Debug.getNativeHeapFreeSize();
            
            // Java heap info
            Runtime runtime = Runtime.getRuntime();
            long javaHeapUsed = runtime.totalMemory() - runtime.freeMemory();
            long javaHeapTotal = runtime.totalMemory();
            long javaHeapMax = runtime.maxMemory();

            WritableMap map = Arguments.createMap();
            
            // Primary benchmark metric
            double totalPssBytes = memoryInfo.getTotalPss() * 1024.0;
            map.putDouble("totalAppMemoryBytes", totalPssBytes);
            map.putDouble("totalAppMemoryMB", totalPssBytes / (1024.0 * 1024.0));
            
            // Detailed PSS breakdown (all in bytes for consistency)
            map.putDouble("totalPSS", totalPssBytes);
            map.putDouble("dalvikPSS", memoryInfo.dalvikPss * 1024.0);
            map.putDouble("nativePSS", memoryInfo.nativePss * 1024.0);
            map.putDouble("otherPSS", memoryInfo.otherPss * 1024.0);
            
            // Native heap
            map.putDouble("nativeHeapSize", nativeHeapSize);
            map.putDouble("nativeHeapAllocated", nativeHeapAllocated);
            map.putDouble("nativeHeapFree", nativeHeapFree);
            
            // Java heap
            map.putDouble("javaHeapUsed", javaHeapUsed);
            map.putDouble("javaHeapTotal", javaHeapTotal);
            map.putDouble("javaHeapMax", javaHeapMax);
            
            map.putLong("timestamp", System.currentTimeMillis());

            promise.resolve(map);
        } catch (Exception e) {
            promise.reject("MEMORY_ERROR", "Failed to get detailed memory info: " + e.getMessage());
        }
    }
    
    @ReactMethod
    public void getSystemMemoryInfo(Promise promise) {
        try {
            // System-wide memory info (separate from app memory)
            ActivityManager activityManager = (ActivityManager) reactContext.getSystemService(Context.ACTIVITY_SERVICE);
            ActivityManager.MemoryInfo memoryInfo = new ActivityManager.MemoryInfo();
            activityManager.getMemoryInfo(memoryInfo);

            WritableMap map = Arguments.createMap();
            map.putDouble("availMem", memoryInfo.availMem);
            map.putDouble("totalMem", memoryInfo.totalMem);
            map.putBoolean("lowMemory", memoryInfo.lowMemory);
            map.putDouble("threshold", memoryInfo.threshold);
            map.putLong("timestamp", System.currentTimeMillis());

            promise.resolve(map);
        } catch (Exception e) {
            promise.reject("MEMORY_ERROR", "Failed to get system memory info: " + e.getMessage());
        }
    }
}