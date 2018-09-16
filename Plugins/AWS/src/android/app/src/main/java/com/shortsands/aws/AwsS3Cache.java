package com.shortsands.aws;

//
//  AwsS3Cache.java
//  AudioPlayer
//
//  Created by Gary Griswold on 8/9/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//
// The read function will read cache and return it if present and unexpired, then it will access online
// And return the result, saving it in cache after it is returned.
//
//
import android.content.Context;
import android.util.Log;
import com.shortsands.io.FileManager;
import java.io.File;
import java.util.Date;

public class AwsS3Cache {

    private static final String TAG = "AwsS3Cache";
    private static final boolean DEBUG = true;

    // Do not instantiate AwsS3Cache, use AwsS3Cache.shared
    private static AwsS3Cache instance = null;
    public static AwsS3Cache shared() {
        if (AwsS3Cache.instance == null) {
            AwsS3Cache.instance = new AwsS3Cache(AwsS3Manager.context);
        }
        return AwsS3Cache.instance;
    }

    private final Context context;
    private final File cacheDir;

    private AwsS3Cache(Context context) {
        super();
        this.context = context;
        this.cacheDir = context.getCacheDir();
    }

    public void readText(String s3Bucket, String s3Key, int expireInterval, CompletionHandler handler) {
        long startTime = System.currentTimeMillis();
        File filePath = this.getPath(s3Bucket, s3Key);
        String data = this.readCache(filePath, expireInterval);
        if (data != null) {
            reportTimeCompleted(startTime, true, true, filePath);
            handler.completed(data);
        } else {
            CacheDownloadTextListener listener = new CacheDownloadTextListener(startTime, filePath, handler);
            AwsS3Manager.findDbp().downloadFile(s3Bucket, s3Key, filePath, listener);
            Log.d(TAG, "**** AWSS3Cache performed downloadFile");
        }
    }

    class CacheDownloadTextListener extends DownloadFileListener {
        private long startTime;
        private File path;
        private CompletionHandler handler;

        CacheDownloadTextListener(long startTime, File path, CompletionHandler handler) {
            this.startTime = startTime;
            this.path = path;
            this.handler = handler;
        }
        @Override
        protected void onComplete(int id) {
            Log.d(TAG, "**** Inside AWSS3Cache.onComplete");
            super.onComplete(id);
            String data = FileManager.readTextFully(this.results);
            reportTimeCompleted(startTime, true, false, path);
            this.handler.completed(data);
        }
        @Override
        public void onError(int id, Exception e) {
            Log.d(TAG, "**** Inside AWSS3Cache.onError");
            super.onError(id, e);
            reportTimeCompleted(startTime, false, false, path);
            this.handler.failed(e);
        }
    }

    public void readFile(String s3Bucket, String s3Key, int expireInterval, CompletionHandler handler) {
        long startTime = System.currentTimeMillis();
        File filePath = this.getPath(s3Bucket, s3Key);
        if (filePath.exists() && filePath.isFile() && !this.isFileExpired(filePath, expireInterval)) {
            reportTimeCompleted(startTime, true, true, filePath);
            handler.completed(filePath);
        } else {
            CacheDownloadFileListener listener = new CacheDownloadFileListener(startTime, filePath, handler);
            AwsS3Manager.findDbp().downloadFile(s3Bucket, s3Key, filePath, listener);
            Log.d(TAG, "**** AWSS3Cache performed downloadFile");
        }
    }

    class CacheDownloadFileListener extends DownloadFileListener {
        private long startTime;
        private File path;
        private CompletionHandler handler;

        CacheDownloadFileListener(long startTime, File path, CompletionHandler handler) {
            this.startTime = startTime;
            this.path = path;
            this.handler = handler;
        }
        @Override
        protected void onComplete(int id) {
            Log.d(TAG, "**** Inside AWSS3Cache.onComplete");
            super.onComplete(id);
            reportTimeCompleted(startTime, true, false, path);
            Log.d(TAG, "##### Will Play File from Download: " + this.results);
            this.handler.completed(this.results);
        }
        @Override
        public void onError(int id, Exception e) {
            Log.d(TAG, "**** Inside AWSS3Cache.onError");
            super.onError(id, e);
            reportTimeCompleted(startTime, false, false, path);
            this.handler.failed(e);
        }
    }

    private String readCache(File path, int expireInterval) {
        Log.d(TAG, "Path to read " + path.toString());
        if (expireInterval >= 0) {
            if (path.exists() && path.isFile()) {
                if (! this.isFileExpired(path, expireInterval)) {
                    return FileManager.readTextFully(path); // does not throw, returns null on failure
                }
            }
        }
        return null;
    }

    private File getPath(String s3Bucket, String s3Key) {
        String localKey = s3Key.replace("/", "_");
        File filePath = new File(this.cacheDir, localKey);
        return filePath;
    }

    /**
     * expire
     * @param filePath
     * @param expireInterval seconds till expiration
     * @return
     */
    private boolean isFileExpired(File filePath, int expireInterval) {
        if (expireInterval >= Integer.MAX_VALUE) {
            return false;
        } else {
            long modificationDate = filePath.lastModified();
            Log.d(TAG, "modification date " + modificationDate);
            long now = new Date().getTime();
            Log.d(TAG, "now date " + now);
            long interval = Math.abs(now - modificationDate);
            Log.d(TAG, "interval " + interval);
            return (interval > expireInterval * 1000);
        }
    }

    private void reportTimeCompleted(long start, boolean success, boolean inCache, File path) {
        if (AwsS3Cache.DEBUG) {
            long duration = System.currentTimeMillis() - start;
            Log.d(TAG, "##### Cache Duration: " + duration + "  isCached: " + inCache + "  Success: " + success + "  Path: " + path.getAbsolutePath());
        }
    }
}
