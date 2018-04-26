package com.shortsands.utility;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteException;
import android.support.test.InstrumentationRegistry;
import android.support.test.runner.AndroidJUnit4;
import android.util.Log;
import java.io.IOException;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.json.JSONArray;
import org.json.JSONObject;

import static org.junit.Assert.*;

/**
 * Instrumented test, which will execute on an Android device.
 *
 * @see <a href="http://d.android.com/tools/testing">Testing documentation</a>
 */
@RunWith(AndroidJUnit4.class)
public class Sqlite3Test {

    private static String TAG = "Sqlite3Test";

    @Test
    public void useAppContext() throws Exception {
        // Context of the app under test.
        Context appContext = InstrumentationRegistry.getTargetContext();

        assertEquals("com.shortsands.utility", appContext.getPackageName());
    }

    @Test
    public void testCreateNonExistantDB() {
        Context appContext = InstrumentationRegistry.getTargetContext();
        Sqlite3 db = new Sqlite3(appContext);
        try {
            db.open("NonExistant.db", false);
            assertTrue(true);
        } catch (Exception err) {
            assertTrue(err.toString(), false);
        }
    }

    @Test
    public void testNonExistantWithCopy() {
        Context appContext = InstrumentationRegistry.getTargetContext();
        Sqlite3 db = new Sqlite3(appContext);
        try {
            db.open("AnotherNonExistant.db", true);
            assertTrue("Exception Expected", false);
        } catch (IOException ioe) {
            String message = ioe.toString();
            assertTrue(message, (message.indexOf("did not find") > 0));
        } catch (Exception e) {
            assertTrue(e.toString(), false);
        }
    }

    @Test  // This test is not correct, because it did not find Reference.
    public void testNonDBInBundle() {
        Context appContext = InstrumentationRegistry.getTargetContext();
        Sqlite3 db = new Sqlite3(appContext);
        try {
            db.open("../com/shortsands/utility/Sqlite3.java", true);
            db.close();
            assertTrue(false);
        } catch (IOException se) {
            String message = se.toString();
            assertTrue(message, (message.indexOf("did not find database") > 0));
        } catch (Exception e) {
            assertTrue(e.toString(), false);
        }
    }

    @Test
    public void testValidDBInBundle() {
        Context appContext = InstrumentationRegistry.getTargetContext();
        Sqlite3 db = new Sqlite3(appContext);
        try {
            db.open("Versions.db", true);
            db.close();
            assertTrue(true);
        } catch (Exception e) {
            assertTrue(e.toString(), false);
        }
    }

    @Test
    public void testInvalidSelect() {
        Context appContext = InstrumentationRegistry.getTargetContext();
        Sqlite3 db = new Sqlite3(appContext);
        try {
            db.open("Versions.db", true);
            String query = "select * from NonExistantTable";
            String[] values = new String[0];
            String[][] resultSet = db.queryV1(query, values);
            assertTrue("Invalid statment should fail to execute.", false);
        } catch (SQLiteException se) {
            assertTrue(true);
        } catch (Exception e) {
            assertTrue("Invalid statement should get SQLiteException", false);
        } finally {
            db.close();
        }
    }

    @Test
    public void testValidSelectNoRows() {
        Context appContext = InstrumentationRegistry.getTargetContext();
        Sqlite3 db = new Sqlite3(appContext);
        try {
            db.open("Versions.db", true);
            String query = "select * from Video where languageId is null";
            String[] values = new String[0];
            String[][] resultSet = db.queryV1(query, values);
            assertTrue("No rows should be returned", (resultSet.length == 0));
        } catch(Exception e) {
            assertTrue(e.toString(), false);
        } finally {
            db.close();
        }
    }

    @Test
    public void testValidSelectRows() {
        Context appContext = InstrumentationRegistry.getTargetContext();
        Sqlite3 db = new Sqlite3(appContext);
        try {
            db.open("Versions.db", true);
            String query = "select languageId, mediaId, lengthMS from Video";
            String[] values = new String[0];
            String[][] resultSet = db.queryV1(query, values);
            assertTrue("There should be many rows", (resultSet.length > 10));
            String[] row = resultSet[0];
            assertTrue("There should be 3 columns.", (row.length == 3));
        } catch (Exception e) {
            assertTrue(e.toString(), false);
        } finally {
            db.close();
        }
    }

    @Test
    public void testDropTable() {
        Context appContext = InstrumentationRegistry.getTargetContext();
        Sqlite3 db = new Sqlite3(appContext);
        try {
            db.open("Versions.db", true);
            String stmt = "DROP TABLE TEST1";
            JSONArray values = new JSONArray();
            int rowCount = db.executeJS(stmt, values);
            assertTrue("Drop table returns zero rowCount", (rowCount == 1));
        } catch (Exception e) {
            assertTrue(e.toString(), false);
        } finally {
            db.close();
        }
    }

    @Test // Only Once
    public void testValidCreateTable() {
        Context appContext = InstrumentationRegistry.getTargetContext();
        Sqlite3 db = new Sqlite3(appContext);
        try {
            db.open("Versions.db", true);
            String stmt = "CREATE TABLE TEST1(abc TEXT, def INT, ghi REAL, ijk BLOB)";
            String[] values = new String[0];
            int rowCount = db.executeV1(stmt, values);
            assertTrue("Create table returns zero rowCount", (rowCount == 1));
        } catch (Exception e) {
            assertTrue(e.toString(), false);
        } finally {
            db.close();
        }
    }

    @Test
    public void testValidInsertText() {
        Context appContext = InstrumentationRegistry.getTargetContext();
        Sqlite3 db = new Sqlite3(appContext);
        try {
            db.open("Versions.db", true);
            String stmt = "INSERT INTO TEST1 (abc, def, ghi, ijk) VALUES (?, ?, ?, ?)";
            String[] values = {"abc", "def", "ghi", "jkl"};
            int rowCount = db.executeV1(stmt, values);
            assertTrue("Insert Text should return 1 row.", (rowCount == 1));
        } catch(Exception e) {
            assertTrue(e.toString(), false);
        } finally {
            db.close();
        }
    }

    @Test
    public void testValidInsertInt() {
        Context appContext = InstrumentationRegistry.getTargetContext();
        Sqlite3 db = new Sqlite3(appContext);
        try {
            db.open("Versions.db", true);
            String stmt = "INSERT INTO TEST1 (abc, def, ghi, ijk) VALUES (?, ?, ?, ?)";
            JSONArray values = new JSONArray();
            values.put(123);
            values.put(345);
            values.put(678);
            values.put(910);
            int rowCount = db.executeJS(stmt, values);
            assertTrue("Insert Int should return 1 row.", (rowCount == 1));
        } catch (Exception e) {
            assertTrue(e.toString(), false);
        } finally {
            db.close();
        }
    }

    @Test
    public void testValidInsertReal() {
        Context appContext = InstrumentationRegistry.getTargetContext();
        Sqlite3 db = new Sqlite3(appContext);
        try {
            db.open("Versions.db", true);
            String stmt = "INSERT INTO TEST1 (abc, def, ghi, ijk) VALUES (?, ?, ?, ?)";
            JSONArray values = new JSONArray();
            values.put(12.3);
            values.put(34.5);
            values.put(67.8);
            values.put(91.0);
            int rowCount = db.executeJS(stmt, values);
            assertTrue("Insert Real should return 1 row.", (rowCount == 1));
        } catch (Exception e) {
            assertTrue(e.toString(), false);
        } finally {
            db.close();
        }
    }

    @Test
    public void testQueryV0() {
        Context appContext = InstrumentationRegistry.getTargetContext();
        Sqlite3 db = new Sqlite3(appContext);
        try {
            db.open("Versions.db", true);
            String stmt = "SELECT abc, def, ghi FROM TEST1";
            String[] values = {};
            Cursor cursor = db.queryV0(stmt, values);
            while(cursor.moveToNext()) {
                String abc = cursor.getString(0);
                int def = cursor.getInt(1);
                Double ghi = cursor.getDouble(2);
                Log.i(TAG, "ROW " + abc + "  " + def + "  " + ghi);
            }
            cursor.close();
        } catch(Exception e) {
            assertTrue(e.toString(), false);
        } finally {
            db.close();
        }
    }

    @Test
    public void testQueryJS() {
        Context appContext = InstrumentationRegistry.getTargetContext();
        Sqlite3 db = new Sqlite3(appContext);
        try {
            db.open("Versions.db", true);
            String stmt = "SELECT abc, def, ghi FROM TEST1";
            JSONArray values = new JSONArray();
            JSONArray resultSet = db.queryJS(stmt, values);
            String message = resultSet.toString();
            assertTrue("Should contain at least 3 rows", (resultSet.length() >= 3));
            JSONObject row = resultSet.getJSONObject(0);
            String oneCol = row.getString("abc");
            assertTrue("Should contain columns", (oneCol.equals("abc")));
        } catch(Exception e) {
            assertTrue(e.toString(), false);
        } finally {
            db.close();
        }
    }

    @Test
    public void testIntBinding() {
        Context appContext = InstrumentationRegistry.getTargetContext();
        Sqlite3 db = new Sqlite3(appContext);
        try {
            db.open("Versions.db", true);
            String stmt = "SELECT abc, def, ghi FROM TEST1 WHERE abc=?";
            JSONArray values = new JSONArray();
            values.put(123);
            JSONArray resultSet = db.queryJS(stmt, values);
            String message = resultSet.toString();
            assertTrue("Should contain one row", (resultSet.length() == 1));
            JSONObject row = resultSet.getJSONObject(0);
            int oneCol = row.getInt("abc");
            assertTrue("Should contain columns", (oneCol == 123));
        } catch(Exception e) {
            assertTrue(e.toString(), false);
        } finally {
            db.close();
        }
    }

    @Test
    public void testDoubleBinding() {
        Context appContext = InstrumentationRegistry.getTargetContext();
        Sqlite3 db = new Sqlite3(appContext);
        try {
            db.open("Versions.db", true);
            String stmt = "SELECT abc, def, ghi FROM TEST1 WHERE ghi=?";
            JSONArray values = new JSONArray();
            values.put(67.8);
            JSONArray resultSet = db.queryJS(stmt, values);
            String message = resultSet.toString();
            assertTrue("Should contain one row", (resultSet.length() == 1));
            JSONObject row = resultSet.getJSONObject(0);
            double oneCol = row.getDouble("ghi");
            assertTrue("Should contain columns", (oneCol == 67.8));
        } catch(Exception e) {
            assertTrue(e.toString(), false);
        } finally {
            db.close();
        }
    }

}


/*
iOS

executeV1(sql: String, values [Any?]

queryJS(sql: String, values: [Any?]

queryV0(sql: String, values: [Any?]

queryV1(sql: String, values: [Any?]

All ios methods use the same bind


bind allows:
String,
Int
Double
null

In Android select methods use the same implicit bind
 */
