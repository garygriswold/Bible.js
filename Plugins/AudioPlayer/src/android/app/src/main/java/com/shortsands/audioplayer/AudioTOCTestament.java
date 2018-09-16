package com.shortsands.audioplayer;

/**
 * Created by garygriswold on 8/30/17.
 */
import android.database.Cursor;
import android.util.Log;
import com.shortsands.utility.Sqlite3;
import java.util.HashMap;
import java.util.Iterator;

class AudioTOCTestament {

    private static String TAG = "AudioTOCTestament";

    AudioTOCBible bible;
    String damId;
    String dbpLanguageCode;
    String dbpVersionCode;
    private String collectionCode;
    private String mediaType;
    HashMap<String, AudioTOCBook> booksById;
    private HashMap<Integer, AudioTOCBook> booksBySeq;

    AudioTOCTestament(AudioTOCBible bible, Sqlite3 database, Cursor cursor) {
        this.bible = bible;
        this.booksById = new HashMap<String, AudioTOCBook>();
        this.booksBySeq = new HashMap<Integer, AudioTOCBook>();
        this.damId = cursor.getString(0);
        this.collectionCode = cursor.getString(1);
        this.mediaType = cursor.getString(2);
        this.dbpLanguageCode = cursor.getString(3);
        this.dbpVersionCode = cursor.getString(4);

        String query = "SELECT bookId, bookOrder, bookName, numberOfChapters" +
            " FROM AudioBook" +
            " WHERE damId = ?" +
            " ORDER BY bookOrder";
        Object[] values = new Object[1];
        values[0] = this.damId;
        try {
            Cursor cursor2 = database.queryV0(query, values);
            int rowNum = 0;
            while(cursor2.moveToNext()) {
                AudioTOCBook book = new AudioTOCBook(this, rowNum, cursor2);
                this.booksById.put(book.bookId, book);
                this.booksBySeq.put(book.sequence, book);
                rowNum++;
            }
        } catch (Exception err) {
            Log.d(TAG,"ERROR " + Sqlite3.errorDescription(err));
        }
    }

    //deinit {
    //    print("***** Deinit TOCAudioTOCBible *****")
    //}

    AudioReference nextChapter(AudioReference ref) {
        AudioTOCBook book = ref.tocAudioBook;
        if (ref.chapterNum() < book.numberOfChapters) {
            int next = ref.chapterNum() + 1;
            return AudioReference.factory(ref.tocAudioBook, next, ref.fileType);
        } else {
            AudioTOCBook nextBook = this.booksBySeq.get(ref.sequenceNum() + 1);
            if (nextBook != null) {
                return AudioReference.factory(nextBook, 1, ref.fileType);
            }
        }
        return null;
    }

    AudioReference priorChapter(AudioReference ref) {
        int prior = ref.chapterNum() - 1;
        if (prior > 0) {
            return AudioReference.factory(ref.tocAudioBook, prior, ref.fileType);
        } else {
            AudioTOCBook priorBook = this.booksBySeq.get(ref.sequenceNum() - 1);
            if (priorBook != null) {
                return AudioReference.factory(priorBook, priorBook.numberOfChapters, ref.fileType);
            }
        }
        return null;
    }

    String getBookList() {
        StringBuffer array = new StringBuffer();
        Iterator<AudioTOCBook> it = this.booksBySeq.values().iterator();
        while(it.hasNext()) {
            array.append(",");
            array.append(it.next().bookId);
        }
        return array.toString();
    }

    public String toString() {
        String str = "damId=" + this.damId +
                "\n languageCode=" + this.dbpLanguageCode +
                "\n versionCode=" + this.dbpVersionCode +
                "\n mediaType=" + this.mediaType +
                "\n collectionCode=" + this.collectionCode;
        return str;
    }
}

