package com.shortsands.audioplayer;

/**
 * Created by garygriswold on 8/30/17.
 */
import android.util.Log;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import java.util.HashMap;

class AudioTOCTestament {

    private static String TAG = "TOCAudioTestament";

    final String mediaSource;
    final String damId;
    final String languageCode;
    final String mediaType;
    final String versionCode;
    final String versionName;
    final String versionEnglish;
    final String collectionCode;
    final HashMap<String, AudioTOCBook> booksById;
    final HashMap<Integer, AudioTOCBook> booksBySeq;

    AudioTOCTestament(String source, JSONObject jsonObject) {
        this.mediaSource = source;
        this.booksById = new HashMap<String, AudioTOCBook>();
        this.booksBySeq = new HashMap<Integer, AudioTOCBook>();
        String temp;
        try { temp = jsonObject.getString("dam_id"); } catch (JSONException je) { temp = ""; }
        this.damId = temp;
        try { temp = jsonObject.getString("language_code"); } catch (JSONException je) { temp = ""; } // Not attr damid
        this.languageCode = temp;
        try { temp = jsonObject.getString("media"); } catch (JSONException je) { temp = ""; }// Not an attr of damid
        this.mediaType = temp;
        try { temp = jsonObject.getString("version_code"); } catch (JSONException je) { temp = ""; }
        this.versionCode = temp;
        try { temp = jsonObject.getString("version_name"); } catch (JSONException je) { temp = ""; }
        this.versionName = temp;
        try { temp = jsonObject.getString("version_english"); } catch (JSONException je) { temp = ""; }
        this.versionEnglish = temp;
        try { temp = jsonObject.getString("collection_code"); } catch (JSONException je) { temp = ""; }
        this.collectionCode = temp;
        try {
            JSONArray books = jsonObject.getJSONArray("books");
                for (int i=0; i<books.length(); i++) {
                    JSONObject jsonBook = books.getJSONObject(i);
                    AudioTOCBook book = new AudioTOCBook(jsonBook);
                    Log.d(TAG, "BOOK " + book.toString());
                    this.booksById.put(book.bookId, book);
                    this.booksBySeq.put(book.sequenceNum, book);
                }
        } catch(JSONException je) {
            Log.e(TAG, "Could not determine type of JSON Object in MetaDataItem");
        }
    }

    AudioReference nextChapter(AudioReference ref) {
        if (this.booksById.containsKey(ref.book)) {
            AudioTOCBook book = this.booksById.get(ref.book);
            if (ref.chapterNum() < book.numberOfChapters) {
                int next = ref.chapterNum() + 1;
                String nextStr = String.valueOf(next);
                switch(nextStr.length()) {
                    case 1: return new AudioReference(ref.damId, ref.sequence, ref.book, "00" + nextStr, ref.fileType);
                    case 2: return new AudioReference(ref.damId, ref.sequence, ref.book, "0" + nextStr, ref.fileType);
                    default: return new AudioReference(ref.damId, ref.sequence, ref.book, nextStr, ref.fileType);
                }
            } else {
                if (this.booksBySeq.containsKey(ref.sequenceNum() + 1)) {
                    AudioTOCBook nextBook = this.booksBySeq.get(ref.sequenceNum() + 1);
                    return new AudioReference(ref.damId, nextBook.sequence, nextBook.bookId, "001", ref.fileType);
                }
            }
        }
        return null;
    }

    public String toString() {
        StringBuilder str = new StringBuilder();
        str.append("damId=");
        str.append(this.damId);
        str.append("\n languageCode=");
        str.append(this.languageCode);
        str.append("\n mediaType=");
        str.append(this.mediaType);
        str.append("\n versionCode=");
        str.append(this.versionCode);
        str.append("\n versionName=");
        str.append(this.versionName);
        str.append("\n versionEnglish=");
        str.append(this.versionEnglish);
        str.append("\n collectionCode=");
        str.append(this.collectionCode);
        return str.toString();
    }
}
