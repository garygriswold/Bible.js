package com.shortsands.audioplayer;

import android.content.Context;
import android.support.test.InstrumentationRegistry;
import android.support.test.runner.AndroidJUnit4;

import com.shortsands.utility.Sqlite3;

import org.junit.Test;
import org.junit.runner.RunWith;

import static org.junit.Assert.*;

/**
 * Instrumentation test, which will execute on an Android device.
 *
 * @see <a href="http://d.android.com/tools/testing">Testing documentation</a>
 */
@RunWith(AndroidJUnit4.class)
public class ExampleInstrumentedTest {
    @Test
    public void testNonExistantDB() {
        Context context = InstrumentationRegistry.getTargetContext();
        Sqlite3 db = new Sqlite3(context);
        try {
            db.open("NonExistant.db", false);
            assertTrue("ExceptionExpected", false );
        } catch (Exception ioe) {
            if (ioe.getMessage().indexOf("ensureDatabase did not find database in data") >= 0) {
                assert(true);
            } else {
                assertTrue("wrong exception: " + ioe.getMessage(), false);
            }
        }
    }
    @Test
    public void testNonExistantWithCopy() {
        Context context = InstrumentationRegistry.getTargetContext();
        Sqlite3 db = new Sqlite3(context);
        try {
            db.open("NonExistant.db", true);
            assertTrue("Exception Expected", false);
        } catch (Exception ex) {
            if (ex.getMessage().indexOf("ensureDatabase did not find database in app") >= 0) {
                assert(true);
            } else {
                assertTrue("wrong exception: " + ex.getMessage(), false);
            }
        }
    }
    @Test
    public void testNonDBInBundle() {
        Context context = InstrumentationRegistry.getTargetContext();
        Sqlite3 db = new Sqlite3(context);
        try {
            db.open("AudioReference.java", true);
            assertTrue("Exception Expected", false);
        } catch (Exception ex) {
            assert(true);
        }
    }
    @Test
    public void testValidDBInBundle() {
        Context context = InstrumentationRegistry.getTargetContext();
        Sqlite3 db = new Sqlite3(context);
        try {
            db.open("Versions.db", true);
            assert(true);
        } catch (Exception ex) {
            assertTrue(ex.getMessage(), false);
        } finally {
            db.close();
        }
    }
    @Test
    public void testInvalidSelect() {
        Context context = InstrumentationRegistry.getTargetContext();
        Sqlite3 db = new Sqlite3(context);
        try {
            db.open("Versions.db", true);
            String query = "select * from NonExistantTable";
            String [] values = new String[0];
            String[][] resultSet = db.queryV1(query, values);
            assertTrue("Exception Expected", false);
        } catch (Exception ex) {
            if (ex.getMessage().indexOf("no such table:") >= 0) {
                assert (true);
            } else {
                assertTrue("wrong exception: " + ex.getMessage(), false);
            }
        } finally {
            db.close();
        }
    }
    @Test
    public void testValidSelectNoRows() {
        Context context = InstrumentationRegistry.getTargetContext();
        Sqlite3 db = new Sqlite3(context);
        try {
            db.open("Versions.db", true);
            String query = "select * from Video where languageId is null";
            String[] values = new String[0];
            String[][] resultSet = db.queryV1(query, values);
            assertTrue("There should be no rows returned", resultSet.length == 0);
        } catch (Exception ex) {
            assertTrue("unexpected exception " + ex.getMessage(), false);
        } finally {
            db.close();
        }
    }
    @Test
    public void testValidSelectRows() {
        Context context = InstrumentationRegistry.getTargetContext();
        Sqlite3 db = new Sqlite3(context);
        try {
            db.open("Versions.db", true);
            String query = "select languageId, mediaId, lengthMS from Video";
            String[][] resultSet = db.queryV1(query, null);
            assertTrue("There should be many rows", resultSet.length > 10);
            String[] row = resultSet[0];
            assertTrue("There should be 3 columns", row.length == 3);
        } catch (Exception ex) {
            assertTrue("unexpected exception " + ex.getMessage(), false);
        } finally {
            db.close();
        }
    }
    @Test
    public void testValidCreateTable() {
        Context context = InstrumentationRegistry.getTargetContext();
        Sqlite3 db = new Sqlite3(context);
        try {
            String[] empty = new String[0];
            db.open("Versions.db", true);
            String stmt1 = "DROP TABLE IF EXISTS TEST1";
            db.executeV1(stmt1, empty);
            String stmt2 = "CREATE TABLE TEST1(abc TEXT, def INT, ghi REAL, ijk BLOB)";
            db.executeV1(stmt2, empty);
            String stmt3 = "INSERT INTO TEST1 (abc, def, ghi, ijk) VALUES (?, ?, ?, ?)";
            String[] values3 = new String[4];
            values3[0] = "abc";
            values3[1] = "def";
            values3[2] = "ghi";
            values3[3] = "jkl";
            db.executeV1(stmt3, values3);
            String stmt4 = "SELECT count(*) FROM TEST1";
            String[][] resultSet = db.queryV1(stmt4, empty);
            String count = resultSet[0][0];
            String stmt5 = "INSERT INTO TEST1 (abc, def, ghi, ijk) VALUES (?, ?, ?, ?)";
            String[] values5 = new String[4];
            values5[0] = "123";
            values5[1] = "345";
            values5[2] = "678";
            values5[3] = "910";
            db.executeV1(stmt5, values5);
            String stmt6 = "SELECT * FROM TEST1";
            String[][] resultSet6 = db.queryV1(stmt6, empty);
            assertTrue("There should be 2 rows", resultSet6.length == 2);
            assertTrue("There should be 4 columns", resultSet6[0].length == 4);
            assert(true);
        } catch (Exception ex) {
            assertTrue("unexpected exception " + ex.getMessage(), false);
        } finally {
            db.close();
        }
    }
}

