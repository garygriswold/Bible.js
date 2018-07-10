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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Pattern;
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
    public static ArrayList<String> listDB(Context context) throws IOException {
        ArrayList<String> results = new ArrayList<String>();
        Sqlite3 db = new Sqlite3(context);
        String[] files = db.context.databaseList();
        for (int i=0; i<files.length; i++) {
            String file = files[i];
            if (file.endsWith(".db")) {
                results.add(file);
            }
        }
        return results;
    }
    public static void deleteDB(Context context, String dbname) throws IOException {
        Sqlite3 db = new Sqlite3(context);
        db.context.deleteDatabase(dbname);
        File fullPath = db.context.getDatabasePath(dbname);
        boolean done = fullPath.delete();
    }


    private Context context;
    private SQLiteDatabase database;

    public Sqlite3(Context context) {
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
            this.database.execSQL(sql, bindObjects(values));
            return 1;
        } else {
            throw new SQLiteException("Database is not open.");
        }
    }

    public int bulkExecuteJS(String sql, JSONArray values) throws Exception {
        if (this.isOpen()) {
            int len = values.length();
            for (int i = 0; i < len; i++) {
                JSONArray row = values.getJSONArray(i);
                this.database.execSQL(sql, bindJSONArray(row));
            }
            return len;
        } else {
            throw new SQLiteException("Database is not open.");
        }
    }

    public int bulkExecuteV1(String sql, Object[][] values) throws SQLiteException {
        if (this.isOpen()) {
            for (int i = 0; i < values.length; i++) {
                Object[] row = values[i];
                this.database.execSQL(sql, bindObjects(row));
            }
            return values.length;
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
            Cursor cursor = null;
            try {
                JSONArray resultSet = new JSONArray();
                cursor = this.database.rawQuery(sql, bindJSONArray(values));
                int colCount = cursor.getColumnCount();
                int rowNum = 0;
                while (cursor.moveToNext()) {
                    JSONObject row = new JSONObject();
                    for (int col = 0; col < colCount; col++) {
                        String name = cursor.getColumnName(col);
                        int type = cursor.getType(col);
                        switch (type) {
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
                return (resultSet);
            } finally {
                if (cursor != null) cursor.close();
            }
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
            return this.database.rawQuery(sql, bindObjects(values));
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
            Cursor cursor = null;
            try {
                cursor = this.database.rawQuery(sql, bindObjects(values));
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
            } finally {
                if (cursor != null) cursor.close();
            }
        } else {
            throw new SQLiteCantOpenDatabaseException("Database must be opened before query.");
        }
    }

    /**
     * This one returns its result as a single string.  It was specifically designed for returning
     * HTML rows that should be displayed consequtively, so that concatentation of the rows returns
     * a correct result.
     */
    public String queryHTMLv0(String sql, JSONArray values) throws SQLiteException, JSONException {
        if (this.isOpen()) {
            Cursor cursor = null;
            try {
                String resultSet = "";
                cursor = this.database.rawQuery(sql, bindJSONArray(values));
                while (cursor.moveToNext()) {
                    resultSet += cursor.getString(0);
                }
                return (resultSet);
            } finally {
                if (cursor != null) cursor.close();
            }
        } else {
            throw new SQLiteCantOpenDatabaseException("Database must be opened before query.");
        }
    }

    /**
     * This query method returns its result in a proprietary format named SSIF (Short Sands Interchange Format),
     * or, Super Simple Interchange Format.  It is intended to provide the same capabilities as JSON for data
     * interchange without the process of first creating objects that must be serialized, and then desearialized
     * when received in JS.
     *
     * The format is for records that have the same number of fields in each record,
     * and each field has the same type in each record.
     * The Field delimiter is |
     * The Record delimiter is ~
     * There is no Field delimiter before the first field or after the last field in a record
     * e.g. ~ abc | def | ghi ~, because this will enable efficient splitting using JS string.split
     * There is no Record delimiter at the beginning and end of the data
     * Before adding any String to SSIF, any | and ~ character must be escaped using HTML entities.
     * These are ~ becomes &#126; and | becomes &#124;
     * Note, that \| and |~ are not used, because this would prevent the use of a simple string.split in JS
     * The first row always contains the field name for each field.
     * The second row always contains the type for each field. The types are S, I, D, B, R
     * These types are (String, Integer, Double, Boolean, Raw (which is sqlite Blob)
     * Strings are not quoted with either single or double quotes, because their type defines them as strings.
     * On the Javascript side it is expected that these would be converted using
     * parseInt(v), parseFloat(v), (v === 'true'), strings are not converted, and I am not sure how to handle blob.
     * When the string data that is returned is going to be displayed in an HTML view, there is no need to
     * unescape the HTML entity, the webview will do that.
     * Null is represented by the string null, not by a zero length string.  Unfortunately, this means that we
     * cannot distinguish between a null in the database and the string "null" in the database, but this might be
     * a good thing.
     *
     * When this data is received on the JS side, it could be processed by a function that knows what it is expecting,
     * for type and field and skips the first two rows.  This would be the more efficient thing to do.
     * However, it is also possible for a generic SSIF.parse method to return an array of objects.
     * Consider JS classes ResultSet and ResultItem.  The ResultSet constructor would split the data into rows
     * using the ~ delimiter, and it would split the first two rows (field names and field types) using the |
     * delimiter.  The split rows would also be passed into a ResultItem constructor.  The ResultItem class has a
     * property length, that will return the number of rows split, less the names and type row.  It also has an items(i)
     * method that returns a zero relative data row.  When called on a row, it splits the row into fields and
     * creates an object with the correct field names, and with data correctly typed, using parseInt(v), parseFloat(v)
     * and (v === 'true').
     */
    public String querySSIFv0(String sql, JSONArray values) throws SQLiteException, JSONException {
        if (this.isOpen()) {
            Cursor cursor = null;
            try {
                ArrayList<String> resultSet = new ArrayList<String>();
                cursor = this.database.rawQuery(sql, bindJSONArray(values));
                int colCount = cursor.getColumnCount();
                String[] names = new String[colCount];
                String[] types = new String[colCount];
                while (cursor.moveToNext()) {
                    if (cursor.isFirst()) {
                        for (int col=0; col<colCount; col++) {
                            names[col] = cursor.getColumnName(col);
                            int type = cursor.getType(col);
                            switch(type) {
                            case Cursor.FIELD_TYPE_INTEGER:
                                types[col] = "I";
                                break;
                            case Cursor.FIELD_TYPE_FLOAT:
                                types[col] = "D";
                                break;
                            case Cursor.FIELD_TYPE_STRING:
                                types[col] = "S";
                                break;
                            case Cursor.FIELD_TYPE_BLOB:
                                types[col] = "R";
                                break;
                                // The Cursor doc said there was a type FIELD_TYPE_NULL, but what to do
                            default:
                                throw new SQLiteException("Column " + names[col] + " has unknown type " + type);
                            }
                        }
                        resultSet.add(this.join("|", names));
                        resultSet.add(this.join("|", types));
                    }
                    String[] row = new String[colCount];
                    for (int col=0; col<colCount; col++) {
                        row[col] = cursor.getString(col);
                        if (row[col] != null) {
                            if (types[col] == "S" && row[col].matches("|~\n\r")) {
                                String str2 = row[col].replace("|", "&#124");
                                String str3 = str2.replace("~", "&#126");
                                String str4 = str3.replace("\r", "\\r");
                                row[col] = str4.replace("\n", "\\n");
                            }
                        } else{
                            row[col] = "null";
                        }
                    }
                    resultSet.add(this.join("|", row));
                }
                String[] rows = new String[resultSet.size()];
                rows = resultSet.toArray(rows);
                return this.join("~", rows);
            } finally {
                if (cursor != null) cursor.close();
            }
        } else {
            throw new SQLiteCantOpenDatabaseException("Database must be opened before query.");
        }
    }

    /**
     * This can be replaced with Java 8 String.join when available.
     */
    private String join(String delim, String[] array) {
        StringBuilder result = new StringBuilder();
        for (int i=0; i<array.length; i++) {
            if (i > 0) {
                result.append(delim);
            }
            result.append(array[i]);
        }
        return(result.toString());
    }

    /*
    Statement binding was tried, but I had more trouble with double and floating point equivalence.
    private void bindStatement(SQLiteStatement statement, Object[] values) throws SQLiteException {
        for (int i=0; i<values.length; i++) {
            int col = i + 1;
            Object value = values[i];
            if (value instanceof String) {
                statement.bindString(col, (String)value);
            } else if (value instanceof Integer) {
                statement.bindLong(col, (Integer)value);
            } else if (value instanceof Long) {
                statement.bindLong(col, (Long)value);
            } else if ((value instanceof Double) || (value instanceof Float)) {
                statement.bindDouble(col, (Double)value);
            } else if (value == null) {
                statement.bindNull(col);
            } else {
                throw new SQLiteException("Unable to bind " + (value.getClass().getName()));
            }
        }
    }
*/
    private String[] bindObjects(Object[] values) {
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
