package com.shortsands.utility;

import android.util.Log;

public class MediaPlayState {

    public static MediaPlayState audio = new MediaPlayState("audio");
    public static MediaPlayState video = new MediaPlayState("video");

    private static String TAG = "MediaPlayState";

    public final String mediaType;
    public String mediaId;
    public String mediaUrl;
    public long position;
    public long timestamp;

    private MediaPlayState(String mediaType) {
        this.mediaType = mediaType;
        this.mediaId = "unknown";
        this.mediaUrl = "";
        this.position = 0L;
        this.timestamp = MediaPlayState.now();
    }

    private void clear() {
        this.clear("unknown");
    }

    private void clear(String mediaId) {
        this.mediaId = mediaId;
        this.mediaUrl = "";
        this.position = 0L;
        this.timestamp = MediaPlayState.now();
    }

    public static long now() {
        return System.currentTimeMillis();
    }

    public void dump(String location) {
        Log.d(TAG, location + ": " + this.toString());
    }

    public String toString() {
        String result = "MediaId: " + this.mediaId + ", MediaUrl: " + this.mediaUrl +
                ", Position: " + this.position + ", Timestamp: " + this.timestamp;
        return result;
    }

    /**********************************************************************************************
     * Adapter Methods
     ***********************************************************************************************/

    public void retrieve(String mediaId) {
        try {
            this.clear(mediaId);
            Sqlite3 db = this.findDB();
            if (db != null) {
                String sql = "SELECT mediaUrl, position, timestamp" +
                        " FROM MediaState WHERE mediaType = ? AND mediaId = ?";
                Object[] values = {this.mediaType, this.mediaId};
                String[][] resultSet = db.queryV1(sql, values);
                if (resultSet.length > 0) {
                    String[] row = resultSet[0];
                    this.mediaUrl = row[0];// ?? "unknown"
                    this.position = Long.parseLong(row[1]);// ?? "0") ?? 0
                    this.timestamp = Long.parseLong(row[2]);// ?? "0") ?? MediaPlayState.now()
                }
            }
        } catch(Exception err) {
            handleError("MediaPlayState.retrieve", err);
        }
        this.dump("retrieve");
    }

    public void update(long position) {
        this.update(this.mediaUrl, position);
    }

    public void update(String mediaUrl, long position) {
        try {
            this.mediaUrl = mediaUrl;
            this.position = position;
            this.timestamp = MediaPlayState.now();
            Sqlite3 db = this.findDB();
            if (db != null) {
                String sql = "REPLACE INTO MediaState(mediaType, mediaId, mediaUrl, position, timestamp)" +
                        " VALUES (?, ?, ?, ?, ?)";
                Object[] values = {this.mediaType, this.mediaId, this.mediaUrl, this.position, this.timestamp};
                int rowCount = db.executeV1(sql, values);
            }
        } catch(Exception err) {
            handleError("MediaPlayState.update", err);
        }
        this.dump("update");
    }

    public void delete() {
        try {
            Sqlite3 db = this.findDB();
            if (db != null) {
                String sql = "DELETE FROM MediaState WHERE mediaType = ? AND mediaId = ?";
                Object[] values = {this.mediaType, this.mediaId};
                int rowCount = db.executeV1(sql, values);
            }
            this.clear();
        } catch(Exception err) {
            handleError("MediaPlayState.delete", err);
        }
        this.dump("delete");
    }

    private void handleError(String caller, Exception error) {
        Log.e(TAG, "ERROR at " + caller + " " + error.toString());
        try {
            Sqlite3 db = this.findDB();
            if (db != null) {
                String sql1 = "SELECT count(*) FROM sqlite_master WHERE type='table' AND name = 'MediaState'";
                Object[] values = {};
                String[][] resultSet = db.queryV1(sql1, values);
                if (resultSet.length > 0) {
                    String[] row = resultSet[0];
                    if (row[0] != null) {
                        int count = Integer.parseInt(row[0]);
                        if (count < 1) {
                            String sql2 = "CREATE TABLE MediaState(" +
                                    " mediaType TEXT NOT NULL," +
                                    " mediaId TEXT NOT NULL," +
                                    " mediaUrl TEXT NOT NULL," +
                                    " position INT default 0," +
                                    " timestamp INT NOT NULL," +
                                    " PRIMARY KEY(mediaType, mediaId)," +
                                    " CHECK (mediaType IN ('audio', 'video')))";
                            int rowCount = db.executeV1(sql2, values);
                        }
                    }
                }
            }
        } catch(Exception err) {
            Log.e(TAG, "ERROR at MediaPlayState.handleError " + err.toString());
        }
    }

    private Sqlite3 findDB() {
        try {
            Sqlite3 db = Sqlite3.findDB("Settings.db");
            return db;
        } catch(Exception err) {
            Log.e(TAG, "Error opening Settings.db " + err.toString());
            return null;
        }
    }
}

