package com.shortsands.audioplayer;

import android.content.Context;
//import android.content.res.AssetManager;

import android.database.Cursor;


import android.database.sqlite.SQLiteCantOpenDatabaseException;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;

//import android.os.Bundle;
import android.util.Log;

import com.shortsands.io.FileManager;

import java.io.File;
import java.io.IOException;
import java.util.Locale;


/**
 * Created by garygriswold on 3/13/18.
 * AudioSqlite3.java
 *  AudioPlayer
 *
 *  Created by Gary Griswold on 3/14/18
 *
 * https://developer.android.com/reference/android/database/sqlite/package-summary.html
 */

//import Foundation
//import SQLite3

//enum Sqlite3Error: Error {
//        case directoryCreateError(name: String, srcError: Error)
//        case databaseNotFound(name: String)
//        case databaseNotInBundle(name: String)
//        case databaseCopyError(name: String, srcError: Error)
//        case databaseOpenError(name: String, sqliteError: String)
//        case statementPrepareFailed(sql: String, sqliteError: String)
//        case statementExecuteFailed(sql: String, sqliteError: String)
//        }

public class AudioSqlite3 {

    private static String TAG = "AudioSqlite3";
    private File databaseDir;
    private File appResourceDir;
    private SQLiteDatabase database;

    AudioSqlite3(Context context) {
        Log.d(TAG,"****** Init AudioSqlite3 ******");
        //File dataDir = context.getDataDir(); required minimum 24.  Try it
        File dbDir = context.getDatabasePath("mydb.db");
        Log.d(TAG, "Database Path: " + dbDir.getAbsolutePath());
        //let homeDir: URL = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
        //let libDir: URL = homeDir.appendingPathComponent("Library")
        //let dbDir: URL = libDir.appendingPathComponent("LocalDatabase") // Is this the correct name?

        this.databaseDir = dbDir;
        this.database = null;

        String codePath = context.getPackageCodePath();
        String resPath = context.getPackageResourcePath();
        this.appResourceDir = new File(resPath, "www");
        //AssetManager ass = context.getAssets();


    }
    // Could introduce alternate init that introduces different databaseDir

    //void finalize() {
    //    Log.d(TAG,"****** Deinit AudioSqlite ******");
    //}

    public boolean isOpen() {
        return this.database != null && this.database.isOpen();
    }

    public void open(String dbPath, boolean copyIfAbsent) throws Exception {
        //this.database = null;
        this.ensureDirectory();
        File fullPath = this.ensureDatabase(dbPath, copyIfAbsent);
        int flags = SQLiteDatabase.OPEN_READWRITE | SQLiteDatabase.CONFLICT_ROLLBACK
                | SQLiteDatabase.NO_LOCALIZED_COLLATORS;
        this.database = SQLiteDatabase.openDatabase(fullPath.getPath(), null, flags);

        //var db: OpaquePointer? = nil
        //let result = sqlite3_open(fullPath.path, &db)
        //if result == SQLITE_OK {
        //if (this.isOpen()) {
        Log.d(TAG,"Successfully opened connection to database at " + fullPath);
            //self.database = db!
        //} else {
            //print("SQLITE Result Code = \(result)")
            //let openMsg = String.init(cString: sqlite3_errmsg(database))
            //throw Sqlite3Error.databaseOpenError(name: dbPath, sqliteError: openMsg)
        //    throw
        //}
    }

    /** This open method is used by command line or other programs that open the database at a
     * specified path, not in the bundle.
     */
 //   public void openLocal(String dbPath) throws {
 //       this.database = null;
        //var db: OpaquePointer? = nil
        //let result = sqlite3_open(dbPath, &db)
        //if result == SQLITE_OK {
        //    print("Successfully opened connection to database at \(dbPath)")
        //    self.database = db!
        //} else {
        //    print("SQLITE Result Code = \(result)")
        //    let openMsg = String.init(cString: sqlite3_errmsg(database))
        //    throw Sqlite3Error.databaseOpenError(name: dbPath, sqliteError: openMsg)
        //}
 //   }

    private File ensureDatabase(String dbPath, boolean copyIfAbsent) throws IOException {
        File fullPath = new File(this.databaseDir, dbPath);
        //let fullPath: URL = this.databaseDir.appendingPathComponent(dbPath)
        Log.d(TAG, "Opening Database as " + fullPath.getAbsolutePath());
        //print("Opening Database at \(fullPath.path)")
        if (fullPath.exists()) {
        //if FileManager.default.isReadableFile(atPath: fullPath.path) {
            return fullPath;
        } else if (copyIfAbsent) {
            Log.d(TAG,"Copy Bundle at " + fullPath);
            //print("Copy Bundle at \(dbPath)")
            //String[] parts = dbPath.split(".", 2);
            //String name = parts[0];
            //String ext = parts[1];
            //let bundle = Bundle.main
            File appPath = new File(this.appResourceDir, dbPath);
            //let bundlePath = bundle.url(forResource: name, withExtension: ext)
            if (appPath.exists()) {
            //if bundlePath != nil {
                //try {
                FileManager.copy(appPath, fullPath);
                return fullPath;
                    //try FileManager.default.copyItem(at: bundlePath!, to: fullPath)
                    //    return fullPath
                //} catch {
                //    //throw Sqlite3Error.databaseCopyError(name: dbPath, srcError: err)
                //    throw new IOException("AudioSqlite3.ensureDatabase failed to copy database " + dbPath);
                //}
            } else {
                //throw Sqlite3Error.databaseNotInBundle(name: dbPath)
                throw new IOException("ensureDatabase did not find database in app " + dbPath);
            }
        } else {
            //throw Sqlite3Error.databaseNotFound(name: dbPath)
            throw new IOException("ensureDatabase did not find database in data " + dbPath);
        }
    }

    private void ensureDirectory() throws IOException {
        //let file = FileManager.default
        if (!this.databaseDir.exists()) {
        //if !file.fileExists(atPath: self.databaseDir.path) {
            //try {
            this.databaseDir.mkdirs();
                //try file.createDirectory(at: self.databaseDir, withIntermediateDirectories: true, attributes: nil)
                //} catch let err {
            //} catch {
            //    //throw Sqlite3Error.directoryCreateError(name: self.databaseDir.path, srcError: err)
            //    throw new IOException("Could not create " + this.databaseDir.getPath());
            //}
        }
    }

    public void close() {
        if (this.database != null) {
            this.database.close();
            //sqlite3_close(database)
            this.database = null;
        }
    }

    /**
     * This execute accepts only strings on the understanding that sqlite will convert data into the type
     * that is correct based on the affinity of the type in the database.
     */
//    public func executeV1(sql: String, values: [String?]?, complete: @escaping (_ count: Int) -> Void) throws {
    public void executeV1(String sql, String[] values) throws SQLiteException {
        if (this.isOpen()) {
            this.database.execSQL(sql, values);
        } else {
            throw new SQLiteCantOpenDatabaseException("Database must be opened before execute statement.");
        }
    }
        //if database != nil {
        //    var statement: OpaquePointer? = nil
        //    let prepareOut = sqlite3_prepare_v2(database, sql, -1, &statement, nil)
        //    defer { sqlite3_finalize(statement) }
        //    if prepareOut == SQLITE_OK {
        //        self.bindStatement(statement: statement!, values: values)
        //        let stepOut = sqlite3_step(statement)
        //        if stepOut == SQLITE_DONE {
        //            let rowCount = Int(sqlite3_changes(database))
        //            complete(rowCount)
//
        //        } else {
        //            let execMsg = String.init(cString: sqlite3_errmsg(database))
        //            throw Sqlite3Error.statementExecuteFailed(sql: sql, sqliteError: execMsg)
        //        }
        //    } else {
        //        let prepareMsg = String.init(cString: sqlite3_errmsg(database))
        //        throw Sqlite3Error.statementPrepareFailed(sql: sql, sqliteError: prepareMsg)
        //    }
        //} else {
        //    throw Sqlite3Error.databaseNotFound(name: "unknown")
        //}
    //}

    /**
     * This execute accepts only strings on the understanding that sqlite will convert data into the type
     * that is correct based on the affinity of the type in the database.
     *
     * Also, this query method returns a resultset that is an array of an array of Strings.
     */
    //public func queryV1(sql: String, values: [String?]?, complete: @escaping (_ results:[[String?]]) -> Void) throws
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
//        if database != nil {
//            var resultSet: [[String?]] = []
//            var statement: OpaquePointer? = nil
//            let prepareOut = sqlite3_prepare_v2(database, sql, -1, &statement, nil)
//            defer { sqlite3_finalize(statement) }
//            if prepareOut == SQLITE_OK {
//                self.bindStatement(statement: statement!, values: values)
//                let colCount = Int(sqlite3_column_count(statement))
//                while (sqlite3_step(statement) == SQLITE_ROW) {
//                    var row: [String?] = [String?] (repeating: nil, count: colCount)
//                    for i in 0..<colCount {
//                        if let cValue = sqlite3_column_text(statement, Int32(i)) {
//                            row[i] = String(cString: cValue)
//                        } else {
//                            row[i] = nil
//                        }
//                    }
//                    resultSet.append(row)
//                }
//                complete(resultSet)
//            } else {
//                let prepareMsg = String.init(cString: sqlite3_errmsg(database))
//                throw Sqlite3Error.statementPrepareFailed(sql: sql, sqliteError: prepareMsg)
//            }
//        } else {
//            throw Sqlite3Error.databaseNotFound(name: "unknown")
//        }
//    }

//    private void bindStatement(statement: OpaquePointer, values: [String?]?) {
//        if let params = values {
//            for i in 0..<params.count {
//                let col = Int32(i + 1)
//                if let param = params[i] {
//                    sqlite3_bind_text(statement, col, (param as NSString).utf8String, -1, nil)
//                } else {
//                    sqlite3_bind_null(statement, col)
//                }
//            }
//        }
//    }

    public static String errorDescription(Exception error) {
        return ("AudioSqlite3 " + error.getMessage());
    }
//        if error is Sqlite3Error {
//            switch error {
//                case Sqlite3Error.directoryCreateError(let name, let srcError) :
//                    return "DirectoryCreateError \(srcError)  at \(name)"
//                case Sqlite3Error.databaseNotFound(let name) :
//                    return "DatabaseNotFound: \(name)"
//                case Sqlite3Error.databaseNotInBundle(let name) :
//                    return "DatabaseNotInBundle: \(name)"
//                case Sqlite3Error.databaseCopyError(let name, let srcError) :
//                    return "DatabaseCopyError: \(srcError.localizedDescription)  \(name)"
//                case Sqlite3Error.databaseOpenError(let name, let sqliteError) :
//                    return "SqliteOpenError: \(sqliteError)  on database: \(name)"
//                case Sqlite3Error.statementPrepareFailed(let sql, let sqliteError) :
//                    return "StatementPrepareFailed: \(sqliteError)  on stmt: \(sql)"
//                case Sqlite3Error.statementExecuteFailed(let sql, let sqliteError) :
//                    return "StatementExecuteFailed: \(sqliteError)  on stmt: \(sql)"
//                default:
//                    return "Unknown Sqlite3Error"
//            }
//        } else {
//            return "Unknown Error Type"
//        }
//    }
}
