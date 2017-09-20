package com.shortsands.audioplayer;

/**
 * Created by garygriswold on 8/30/17.
 */

import com.shortsands.aws.AwsS3;
import java.net.URL;

class Reference {

    final String damId;
    final String sequence;
    final String book;
    final String chapter;
    final String fileType;
    final URL url;
    TOCAudioChapter audioChapter;

    Reference(String damId, String sequence, String book, String chapter, String fileType) {
        this.damId = damId;
        this.sequence = sequence;
        this.book = book;
        this.chapter = chapter;
        this.fileType = fileType;
        this.url = AwsS3.shared().preSignedUrlGET(getS3Bucket(), getS3Key(), 3600);
        this.audioChapter = null;
    }

    int sequenceNum() {
        return(Integer.parseInt(this.sequence));
    }

    int chapterNum() {
        return (Integer.parseInt(this.chapter));
    }

    String getS3Bucket() {
        switch (this.fileType) {
            case "mp3": return "audio-" + AwsS3.region + "-shortsands";
            default: return "unknown";
        }
    }

    String getS3Key() {
        return (this.damId + "_" + this.sequence + "_" + this.book + "_" + this.chapter + "." + this.fileType);
    }

    boolean isEqual(Reference reference) {
        if (this.chapter != reference.chapter) { return false; }
        if (this.book != reference.book) { return false; }
        if (this.sequence != reference.sequence) { return false; }
        if (this.damId != reference.damId) { return false; }
        if (this.fileType != reference.fileType) { return false; }
        return true;
    }

    public String toString() {
        return (this.damId + "_" + this.sequence + "_" + this.book + "_" + this.chapter + "." + this.fileType);
    }
}
