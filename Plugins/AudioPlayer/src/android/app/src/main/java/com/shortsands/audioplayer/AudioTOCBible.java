package com.shortsands.audioplayer;

/**
 * Created by garygriswold on 8/30/17.
 */
import android.content.Context;
import android.database.Cursor;
import android.util.Log;

class AudioTOCBible {

    private static final String TAG = "AudioTOCBible";

    private Context context;
    // which of these should be private, none of them are in ios
    String textVersion;
    String silLang;
    String mediaSource;
    AudioTOCTestament oldTestament;
    AudioTOCTestament newTestament;
    AudioSqlite3 database;

    AudioTOCBible(Context context, String versionCode, String silLang) {
        this.context = context;
        this.textVersion = versionCode;
        this.silLang = silLang;
        this.mediaSource = "FCBH";
        this.oldTestament = null;
        this.newTestament = null;
        this.database = new AudioSqlite3(context);
        try {
            this.database.open("Versions.db", true);
        } catch (Exception err) {
            Log.d(TAG,"ERROR " + AudioSqlite3.errorDescription(err));
        }
    }

    //deinit {
    //    print("***** Deinit AudioMetaDataReader *****")
    //}

    void read() {
        String query = "SELECT a.damId, a.collectionCode, a.mediaType, a.dbpLanguageCode, a.dbpVersionCode" +
                " FROM audio a, audioVersion v" +
                " WHERE a.dbpLanguageCode = v.dbpLanguageCode" +
                " AND a.dbpVersionCode = v.dbpVersionCode" +
                " AND v.versionCode = ?" +
                " ORDER BY mediaType ASC, collectionCode ASC";
        // mediaType sequence Drama, NonDrama
        // collectionCode sequence NT, ON, OT
        try {
            String[] values = new String[1];
            values[0] = this.textVersion;
            Cursor cursor = this.database.queryV2(query, values);
            Log.d(TAG, "LENGTH " + cursor.getCount());
            while (cursor.moveToNext()) {
                // Because of the sort sequence, the following logic prefers Drama over Non-Drama
                // Because of the sequence of IF's, it prefers OT and NT over ON
                String collectionCode = cursor.getString(1);
                if (this.newTestament == null && collectionCode.equals("NT")) {
                    this.newTestament = new AudioTOCTestament(this, this.database, cursor);
                }
                if (this.oldTestament == null && collectionCode.equals("OT")) {
                    this.oldTestament = new AudioTOCTestament(this, this.database, cursor);
                }
            }
            this.readBookNames(); // This is not necessary on Android
        } catch (Exception err) {
            Log.d(TAG,"ERROR " + AudioSqlite3.errorDescription(err));
        }
    }
    /**
     * This function will only return results after read has been called.
     */
    AudioTOCBook findBook(String bookId) {
        AudioTOCBook result = null;
        if (this.oldTestament != null) {
            result = this.oldTestament.booksById.get(bookId);
        }
        if (result == null) {
            if (this.newTestament != null) {
                result = this.newTestament.booksById.get(bookId);
            }
        }
        return result;
    }

    AudioTOCChapter readVerseAudio(String damid, String bookId, int chapter) {
        AudioTOCChapter tocChapter = null;
        String query = "SELECT versePositions FROM AudioChapter WHERE damId = ? AND bookId = ? AND chapter = ?";
        try {
            String[] values = new String[3];
            values[0] = damid;
            values[1] = bookId;
            values[2] = String.valueOf(chapter);
            Cursor cursor = this.database.queryV2(query, values);
            while(cursor.moveToNext()) {
                String positions = cursor.getString(0);
                if (positions != null) {
                    tocChapter = new AudioTOCChapter(positions);
                }
            }
        } catch (Exception err) {
            Log.d(TAG,"ERROR " + AudioSqlite3.errorDescription(err));
        } finally {
            return(tocChapter);
        }
    }

    private void readBookNames() {
        String query = "SELECT code, heading FROM tableContents";
        String[] values = new String[0];
        AudioSqlite3 db = new AudioSqlite3(this.context);
        try {
            String dbName = this.textVersion + ".db";
            db.open(dbName, true);
            String[][] resultSet = db.queryV1(query, values);
            for (int i=0; i<resultSet.length; i++) {
                String[] row = resultSet[i];
                String bookId = row[0];
                if (this.oldTestament != null && this.oldTestament.booksById.containsKey(bookId)) {
                    this.oldTestament.booksById.get(bookId).bookName = row[1];
                } else if (this.newTestament != null && this.newTestament.booksById.containsKey(bookId)) {
                    this.newTestament.booksById.get(bookId).bookName = row[1];
                }
            }
        } catch (Exception err) {
            Log.d(TAG, "ERROR: " + AudioSqlite3.errorDescription(err));
        } finally {
            db.close();
        }
    }
}
