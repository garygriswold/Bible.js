package com.shortsands.audioplayer;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import java.util.UUID;
/**
 *  AudioAnalyticsSessionId.java
 *  AnalyticsProto
 *
 *  Created by Gary Griswold on 6/29/17.
 *  Copyright © 2017 ShortSands. All rights reserved.
 */

class AudioAnalyticsSessionId {

    private static final String SESSION_KEY = "ShortSandsSessionId";

    private final Context context;

    AudioAnalyticsSessionId(Context context) {
        this.context = context;
    }

    String getSessionId() {
        String sessionId = this.retrieveSessionId();
        if (sessionId != null) {
            return sessionId;
        } else {
            String newSessionId = UUID.randomUUID().toString();
            this.saveSessionId(newSessionId);
            return newSessionId;
        }
    }

    private String retrieveSessionId() {
        SharedPreferences savedState = this.context.getSharedPreferences(SESSION_KEY, Context.MODE_PRIVATE);
        return (savedState != null) ? savedState.getString(SESSION_KEY, null) : null;
    }

    private void saveSessionId(String sessionId) {
        SharedPreferences savedState = this.context.getSharedPreferences(SESSION_KEY, Context.MODE_PRIVATE);
        Editor editor = savedState.edit();
        editor.putString(SESSION_KEY, sessionId);
        editor.commit();
    }
}

