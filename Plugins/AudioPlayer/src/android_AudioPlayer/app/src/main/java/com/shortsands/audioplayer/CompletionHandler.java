package com.shortsands.audioplayer;

/**
 * Created by garygriswold on 9/6/17.
 */

public interface CompletionHandler {

    public void completed(Object result, Object attachment);
    public void failed(Throwable exception, Object attachment);
}
