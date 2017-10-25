package com.shortsands.aws;

/**
 * Created by garygriswold on 9/6/17.
 */

public interface CompletionHandler {

    void completed(Object result);
    void failed(Throwable exception);
}