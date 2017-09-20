package com.shortsands.audioplayer;

/**
 * Created by garygriswold on 9/6/17.
 */

public interface CompletionHandler {

    void completed(Object result, Object attachment);
    void failed(Throwable exception, Object attachment);
}
