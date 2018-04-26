package com.shortsands.utility;

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
import java.util.HashMap;
import java.util.Map;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by garygriswold on 4/18/18.
 * Sqlite3.java
 * Utility
 *
 *  Created by Gary Griswold on 4/24/18
 *
 * https://developer.android.com/reference/android/database/sqlite/package-summary.html
 */

public class Sqlite3 {

    private static String TAG = "Sqlite3";

    private static Map<String, Sqlite3> openDatabases = new HashMap<String, Sqlite3>();
    public static Sqlite3 findDB(String dbname) throws SQLiteException {
        Sqlite3 openDB = openDatabases.get(dbname);
        if (openDB != null) {
            return openDB;
        } else {
            throw new SQLiteException("Database " + dbname + " is not open.");
        }
    }
    public static Sqlite3 openDB(Context context, String dbname, boolean copyIfAbsent) throws Exception {
        Sqlite3 openDB = openDatabases.get(dbname);
        if (openDB != null) {
            return openDB;
        } else {
            Sqlite3 newDB = new Sqlite3(context);
            newDB.open(dbname, copyIfAbsent);
            openDatabases.put(dbname, newDB);
            return newDB;
        }
    }
    public static void closeDB(String dbname) {
        Sqlite3 openDB = openDatabases.get(dbname);
        if (openDB != null) {
            openDB.close();
            openDatabases.remove(dbname);
        }
    }


    private Context context;
    private SQLiteDatabase database;

    Sqlite3(Context context) {
        Log.d(TAG,"****** Init AudioSqlite3 ******");
        this.context = context;
        this.database = null;
    }

    public boolean isOpen() {
        return this.database != null && this.database.isOpen();
    }

    public void open(String dbname, boolean copyIfAbsent) throws Exception {
        File fullPath = this.ensureDatabase(dbname, copyIfAbsent);
        int flags = SQLiteDatabase.OPEN_READWRITE |
                SQLiteDatabase.NO_LOCALIZED_COLLATORS |
                SQLiteDatabase.CREATE_IF_NECESSARY;
        this.database = SQLiteDatabase.openDatabase(fullPath.getPath(), null, flags);
        Log.d(TAG,"Successfully opened connection to database at " + fullPath);
    }

    private File ensureDatabase(String dbname, boolean copyIfAbsent) throws IOException {
        File fullPath = this.context.getDatabasePath(dbname);
        Log.d(TAG, "Opening Database as " + fullPath.getAbsolutePath());
        if (fullPath.exists()) {
            return fullPath;
        } else if (! copyIfAbsent) {
            this.ensureDirectory(fullPath);
            return fullPath;
        } else {
            Log.d(TAG,"Copy Bundle at " + fullPath);
            this.ensureDirectory(fullPath);
            try {
                this.copyDatabase(dbname, fullPath);
                return fullPath;
            } catch(IOException ex) {
                throw new IOException("ensureDatabase did not find database in app " + dbname);
            }
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
     * This execute is intended for calls from Javascript
     */
    public int executeJS(String sql, JSONArray values) throws Exception {
        if (this.isOpen()) {
            this.database.execSQL(sql, bindJSONArray(values));
            return 1;
        } else {
            throw new SQLiteException("Database is not open.");
        }
    }

    /**
     * This execute is intended for use by other native code
     */
    public int executeV1(String sql, Object[] values) throws SQLiteException {
        if (this.isOpen()) {
            this.database.execSQL(sql, values);
            return 1;
        } else {
            throw new SQLiteException("Database is not open.");
        }
    }

    /**
     * This one is written to conform to the query interface of the cordova sqlite plugin.  It returns
     * a JSON array that can be serialized and sent back to Javascript.  It supports both String and Int
     * results, because that is what are used in the current databases.
     */
    public JSONArray queryJS(String sql, JSONArray values) throws Exception {
        if (this.isOpen()) {
            JSONArray resultSet = new JSONArray();
            Cursor cursor = this.database.rawQuery(sql, bindJSONArray(values));
            int colCount = cursor.getColumnCount();
            int rowNum = 0;
            while(cursor.moveToNext()) {
                JSONObject row = new JSONObject();
                for (int col=0; col<colCount; col++) {
                    String name = cursor.getColumnName(col);
                    int type = cursor.getType(col);
                    switch(type) {
                        case 1: // INT
                            row.put(name, cursor.getInt(col));
                            break;
                        case 2: // Double
                            row.put(name, cursor.getDouble(col));
                            break;
                        case 3: // TEXT
                            row.put(name, cursor.getString(col));
                            break;
                        case 5: // NULL
                            row.put(name, null);
                            break;
                        default:
                            row.put(name, cursor.getString(col));
                            break;
                    }
                }
                resultSet.put(row);
            }
            cursor.close();
            return(resultSet);
        } else {
            throw new SQLiteException("Database is not found.");
        }
    }

    /**
     * This returns a classic sql result set as an array of dictionaries.  It is probably not a good choice
     * if a large number of rows are returned.  It returns types: String, Int, Double, and nil because JSON
     * will accept these types.
     */
    public Cursor queryV0(String sql, Object[] values) throws SQLiteException {
        if (this.isOpen()) {
            return this.database.rawQuery(sql, bindStatement(values));
        } else {
            throw new SQLiteCantOpenDatabaseException("Database must be opended before queryV0.");
        }
    }

    /**
     * This execute accepts only strings on the understanding that sqlite will convert data into the type
     * that is correct based on the affinity of the type in the database.
     *
     * Also, this query method returns a resultset that is an array of an array of Strings.
     */
    public String[][] queryV1(String sql, Object[] values) throws SQLiteException {
        if (this.isOpen()) {
            Cursor cursor = this.database.rawQuery(sql, bindStatement(values));
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
            cursor.close();
            return (resultSet);
        } else {
            throw new SQLiteCantOpenDatabaseException("Database must be opened before query.");
        }
    }

    private String[] bindStatement(Object[] values) {
        String[] result = new String[values.length];
        for (int i=0; i<values.length; i++) {
            result[i] = String.valueOf(values[i]);
        }
        return result;
    }

    private String[] bindJSONArray(JSONArray values) throws JSONException {
        String[] result = new String[values.length()];
        for (int i=0; i<result.length; i++) {
            result[i] = values.getString(i);
        }
        return result;
    }

    public static String errorDescription(Exception error) {
        return ("Sqlite3 " + error.getMessage());
    }
}
