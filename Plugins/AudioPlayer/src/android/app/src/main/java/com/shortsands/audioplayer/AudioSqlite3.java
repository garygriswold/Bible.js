package com.shortsands.audioplayer;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteCantOpenDatabaseException;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;
import android.util.Log;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.IOException;

/**
 * Created by garygriswold on 3/13/18.
 * AudioSqlite3.java
 *  AudioPlayer
 *
 *  Created by Gary Griswold on 3/14/18
 *
 * https://developer.android.com/reference/android/database/sqlite/package-summary.html
 */

public class AudioSqlite3 {

    private static String TAG = "AudioSqlite3";
    private Context context;
    private SQLiteDatabase database;

    AudioSqlite3(Context context) {
        Log.d(TAG,"****** Init AudioSqlite3 ******");
        this.context = context;
        this.database = null;
    }

    //void finalize() {
    //    Log.d(TAG,"****** Deinit AudioSqlite ******");
    //}

    public boolean isOpen() {
        return this.database != null && this.database.isOpen();
    }

    public void open(String dbPath, boolean copyIfAbsent) throws Exception {
        File fullPath = this.ensureDatabase(dbPath, copyIfAbsent);
        int flags = SQLiteDatabase.OPEN_READWRITE | SQLiteDatabase.NO_LOCALIZED_COLLATORS;
        this.database = SQLiteDatabase.openDatabase(fullPath.getPath(), null, flags);
        Log.d(TAG,"Successfully opened connection to database at " + fullPath);
    }

    private File ensureDatabase(String dbPath, boolean copyIfAbsent) throws IOException {
        File fullPath = this.context.getDatabasePath(dbPath);
        Log.d(TAG, "Opening Database as " + fullPath.getAbsolutePath());
        if (fullPath.exists()) {
            return fullPath;
        } else if (copyIfAbsent) {
            Log.d(TAG,"Copy Bundle at " + fullPath);
            this.ensureDirectory(fullPath);
            try {
                this.copyDatabase(dbPath, fullPath);
                return fullPath;
            } catch(IOException ex) {
                throw new IOException("ensureDatabase did not find database in app " + dbPath);
            }
        } else {
            throw new IOException("ensureDatabase did not find database in data " + dbPath);
        }
    }

    private void ensureDirectory(File destFile) throws IOException {
        String destPath = destFile.getAbsolutePath();
        File destDir = new File(destPath.substring(0, destPath.lastIndexOf("/") + 1));
        try {
            if (!destDir.exists()) {
                destDir.mkdirs();
            }
        } catch(Exception ex) {
            throw new IOException("Could not create " + destDir.getPath());
        }
    }

    private void copyDatabase(String dbName, File destFile) throws IOException {
        InputStream in = null;
        FileOutputStream out = null;
        try {
            in = this.context.getAssets().open("www/" + dbName);
            out = new FileOutputStream(destFile);
            byte[] buf = new byte[1024];
            int len;
            while ((len = in.read(buf)) > 0) {
                out.write(buf, 0, len);
            }
        } finally {
            if (in != null) try { in.close(); } catch(Exception e) {}
            if (out != null) try { out.close(); } catch(Exception e) {}
        }
    }

    public void close() {
        if (this.database != null) {
            this.database.close();
            this.database = null;
        }
    }

    /**
     * This execute accepts only strings on the understanding that sqlite will convert data into the type
     * that is correct based on the affinity of the type in the database.
     */
    public void executeV1(String sql, String[] values) throws SQLiteException {
        if (this.isOpen()) {
            this.database.execSQL(sql, values);
        } else {
            throw new SQLiteCantOpenDatabaseException("Database must be opened before execute statement.");
        }
    }

    /**
     * This execute accepts only strings on the understanding that sqlite will convert data into the type
     * that is correct based on the affinity of the type in the database.
     *
     * Also, this query method returns a resultset that is an array of an array of Strings.
     */
    public String[][] queryV1(String sql, String[] values) throws SQLiteException {
        if (this.isOpen()) {
            Cursor cursor = this.database.rawQuery(sql, values);
            int colCount = cursor.getColumnCount();
            String[][] resultSet = new String[cursor.getCount()][colCount];
            int rowNum = 0;
            while (cursor.moveToNext()) {
                String[] row = new String[colCount];
                for (int i = 0; i < colCount; i++) {
                    row[i] = cursor.getString(i);
                }
                resultSet[rowNum] = row;
                rowNum++;
            }
            return (resultSet);
        } else {
            throw new SQLiteCantOpenDatabaseException("Database must be opened before query.");
        }
    }

    public static String errorDescription(Exception error) {
        return ("AudioSqlite3 " + error.getMessage());
    }
}
