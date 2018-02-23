//
//  main.swift
//  ValidateAudio
//  This program reads the Audio meta data that is stored in Versions.db
//  and compares it to the actual Audio files that are available in AWS S3.
//  It verifies that all of the audio data that is described in Versions.db
//  is actually available in AWS S3.
//
//  Created by Gary Griswold on 2/21/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import Foundation

//print("Hello, World!")


/** Read TextVersions available through App, get code and language */
func lookupTextVersions(dbPath: String, outFilename: String) {
    var output = [[String]]()
    let db = AudioSqlite3()
    do {
        try db.openLocal(dbPath: dbPath)
        defer { db.close() }
        let sql = "SELECT versionCode, silCode, scope FROM Version WHERE versionCode IN" +
        " (select versionCode from CountryVersion);"
        try db.queryV1(sql: sql, values: [], complete: { results in
            for row in results {
                if row[0] != nil && row[1] != nil && row[2] != nil {
                    print("Version: \(row[0]!)  Lang: \(row[1]!)")
                    lookupAudioVersion(database: db, versionCode: row[0]!, silLang: row[1]!, scope: row[2]!,
                                       complete: { array in
                                        //for item in array {
                                        //    output.append(item)
                                        //}
                                        print("IN LOOKUP TEXT VERSION: \(row[0]!) -> \(array.count)")
                                        output.append(array)
                    })
                } else {
                    //// Must throw error or terminate
                    print("ERROR: Version: \(row[0])  Lang: \(row[1])  Scope: \(row[2])")
                }
            }
            //sleep(20) // very crude race condition prevention
            writeArray(outFilename: outFilename, array: output)
        })
    } catch let err {
        print("Database ERROR \(err)")
    }
}

/** Read AudioVersions using MetaDataReader.read, similar to AudioMetaDataReader */
func lookupAudioVersion(database: AudioSqlite3, versionCode: String, silLang: String, scope: String,
                        complete: @escaping (_ output:[String]) -> Void){
    let reader = MetaDataReader()
    reader.read(database: database, versionCode: versionCode, silLang: silLang, complete: {
        oldTestament, newTestament in
        let oldArray = reviewTestament(versionCode: versionCode, testament: oldTestament, type: "Old")
        let newArray = reviewTestament(versionCode: versionCode, testament: newTestament, type: "New")
        print("IN LOOKUP AUDIO VERSION: \(versionCode) -> \(oldArray.count + newArray.count)")
        complete(oldArray + newArray)
    })
}

/** Iterate over all of the chapters of all of the books of an audio Bible */
func reviewTestament(versionCode: String, testament: AudioTOCBible?, type: String) -> [String] {
    var output = [String]()
    if let bible = testament {
        for index in 1...100 {
            if let book = bible.booksBySeq[index] {
                for chapter in 1...book.numberOfChapters {
                    let awsKey = computeAWSKey(book: book, chapter: chapter)
                    output.append(awsKey)
                }
            }
        }
    } else {
        print("Version: \(versionCode)  \(type) Testament is empty")
    }
    print("IN REVIEW TESTAMENT: \(versionCode) \(type) -> \(output.count)")
    return output
}

/** Compute the AWS S3 Key for the object */
func computeAWSKey(book: AudioTOCBook, chapter: Int) -> String {
    let bucket = book.bible.damId.lowercased()
    var chapterStr = String(chapter)
    if chapterStr.count == 1 { chapterStr = "00" + chapterStr }
    else if chapterStr.count == 2 { chapterStr = "0" + chapterStr }
    let key = book.bookOrder + "_" + book.bookId + "_" + chapterStr + ".mp3"
    return bucket + "|" + key
}

/** Write list of files into local file. */
func writeArray(outFilename: String, array: [[String]]) {
    var oneDim = [String]()
    for outer in array {
        for inner in outer {
            oneDim.append(inner)
        }
    }
    let contents = oneDim.joined(separator: "\n")
    let url = URL(fileURLWithPath: outFilename)
    do {
        try contents.write(to: url, atomically: true, encoding: String.Encoding.utf8)
    } catch let err {
        print("ERROR: \(err)")
    }
}


lookupTextVersions(dbPath: "/Users/garygriswold/ShortSands/BibleApp/Versions/Versions.db",
                   outFilename: "/Users/garygriswold/Downloads/test.txt")





