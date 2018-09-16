package com.shortsands.audioplayer;

/**
 * Created by garygriswold on 8/30/17.
 */
import android.util.Log;

class AudioReference {

    private static String TAG = "AudioReference";

    AudioTOCBook tocAudioBook;
    String chapter;
    String fileType;
    AudioTOCChapter audioChapter;

    AudioReference(AudioTOCBook book, String chapter, String fileType) {
        this.tocAudioBook = book;
        this.chapter = chapter;
        this.fileType = fileType;
        Log.d(TAG, "***** Init AudioReference ***** " + this.toString());
    }

    static AudioReference factory(AudioTOCBook book, int chapterNum, String fileType) {
        String chapter = String.valueOf(chapterNum);
        switch (chapter.length()) {
            case 1:
                return new AudioReference(book, "00" + chapter, fileType);
            case 2:
                return new AudioReference(book, "0" + chapter, fileType);
            default:
                return new AudioReference(book, chapter, fileType);
        }
    }

    //deinit {
    //    print("***** Deinit AudioReference ***** \(self.toString())")
    //}

    String textVersion() {
        return this.tocAudioBook.testament.bible.textVersion;
    }

    String silLang() {
        return this.tocAudioBook.testament.bible.silLang;
    }

    String damId() {
        return this.tocAudioBook.testament.damId;
    }

    String sequence() {
        return this.tocAudioBook.bookOrder;
    }

    Integer sequenceNum() { return this.tocAudioBook.sequence; }

    String bookId() {
        return this.tocAudioBook.bookId;
    }

    int chapterNum() {
        try {
            return Integer.parseInt(this.chapter);
        } catch(NumberFormatException ex) {
            return 1;
        }
    }

    String localName() {
        return this.tocAudioBook.bookName + " " + chapterNum();
    }

    String dbpLanguageCode() {
        return this.tocAudioBook.testament.dbpLanguageCode;
    }

    private String dbpVersionCode() { return this.tocAudioBook.testament.dbpVersionCode; }

    private String dbpBookName() { return this.tocAudioBook.dbpBookName; }

    AudioReference nextChapter() {
        return this.tocAudioBook.testament.nextChapter(this);
    }

    AudioReference priorChapter() {
        return this.tocAudioBook.testament.priorChapter(this);
    }

    String getS3Bucket() {
        if (this.fileType.equals("mp3")) {
            return "dbp-prod";
        } else {
            return "unknown bucket";
        }
    }

    String getS3Key() {
        String abbr = this.dbpLanguageCode() + this.dbpVersionCode();
        String chapNum = this.chapter;
        if (this.bookId() != "PSA") {
            chapNum = "_" + chapNum.substring(1);
        }
        String name = this.dbpBookName().replace(" ", "_");
        name = name + "____________".substring(0, (12 - name.length()));
        String key = String.format("audio/%s/%s/%s__%s_%s%s.%s", abbr, this.damId(), this.sequence(),
                chapNum, name, this.damId(), this.fileType);
        Log.d("TAG", "Key=" + key);
        return key;
    }

    String getNodeId(int verse)  {
        if (verse > 0) {
            return this.bookId() + ":" + String.valueOf(this.chapterNum()) + ":" + String.valueOf(verse);
        } else {
            return this.bookId() + ":" + String.valueOf(this.chapterNum());
        }
    }

    boolean isEqual(AudioReference reference) {
        if (!this.chapter.equals(reference.chapter)) { return false; }
        if (!this.bookId().equals(reference.bookId())) { return false; }
        if (!this.sequence().equals(reference.sequence())) { return false; }
        if (!this.damId().equals(reference.damId())) { return false; }
        if (!this.fileType.equals(reference.fileType)) { return false; }
        return true;
    }

    public String toString()  {
        return this.damId() + "_" + this.sequence() + "_" + this.bookId() + "_" + this.chapter + "." + this.fileType;
    }
}
