package com.shortsands.aws;

/**
 * Created by garygriswold on 5/19/17.
 */
import android.content.Context;
import android.util.Log;

import com.amazonaws.HttpMethod;
import com.amazonaws.regions.Region;
import com.amazonaws.regions.RegionUtils;
import com.amazonaws.services.s3.S3ClientOptions;
import com.amazonaws.services.s3.model.GeneratePresignedUrlRequest;

import com.amazonaws.mobileconnectors.s3.transferutility.TransferObserver;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferUtility;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3Client;

import com.shortsands.io.FileManager;

import java.io.File;
import java.net.URL;
import java.util.Date;

public class AwsS3 {

    static String TAG = "AwsS3";

    // AwsS3.regionName and Context should be set early in an App
    private static String region = "us-east-1";
    private static Context context = null;
    public static void initialize(String regionName, Context ctx) {
        AwsS3.region = regionName;
        AwsS3.context = ctx;
    }

    // Do not instantiate AwsS3, use AwsS3.shared
    private static AwsS3 instance = null;
    public static AwsS3 shared() {
        if (AwsS3.instance == null) {
            AwsS3.instance = new AwsS3(AwsS3.region, AwsS3.context);
        }
        return AwsS3.instance;
    }

    AmazonS3 amazonS3;
    TransferUtility transferUtility;

    public AwsS3(String regionName, Context context) {
        super();
        Log.d(TAG, "regionName input = " + regionName);
        Region region = RegionUtils.getRegion(regionName);
        if (region == null) {
            region = RegionUtils.getRegion("us-east-1");
        }
        this.amazonS3 = new AmazonS3Client(Credentials.AWS_BIBLE_APP);
        this.amazonS3.setRegion(region);
        S3ClientOptions options = new S3ClientOptions();
        options.withPathStyleAccess(true);
		this.amazonS3.setS3ClientOptions(options);
        this.transferUtility = new TransferUtility(this.amazonS3, context);
    }
    public String echo3(String msg) {
	    return(msg);
    }
    /////////////////////////////////////////////////////////////////////////
    // URL signing Functions
    /////////////////////////////////////////////////////////////////////////
    /**
     * This method produces a presigned URL for a GET from an AWS S3 bucket
     */
    public URL preSignedUrlGET(String s3Bucket, String s3Key, int expires) {
        GeneratePresignedUrlRequest request =
            new GeneratePresignedUrlRequest(s3Bucket, s3Key, HttpMethod.GET);
        Date expiration = new Date(new Date().getTime() + expires);
        request.withExpiration(expiration);

        URL url = this.amazonS3.generatePresignedUrl(request);
        Log.d(TAG, url.toExternalForm());
        return url;
    }
    /**
     * This method produces a presigned URL for a PUT to an AWS S3 bucket
     */
    public URL preSignedUrlPUT(String s3Bucket, String s3Key, int expires, String contentType) {
        GeneratePresignedUrlRequest request =
                new GeneratePresignedUrlRequest(s3Bucket, s3Key, HttpMethod.PUT);
        Date expiration = new Date(new Date().getTime() + expires);
        request.withExpiration(expiration);
        request.withContentType(contentType);

        URL url = this.amazonS3.generatePresignedUrl(request);
        Log.d(TAG, url.toExternalForm());
        return url;
    }
    /////////////////////////////////////////////////////////////////////////
    // Download Functions
    /////////////////////////////////////////////////////////////////////////
    /**
     * Download Text to String object
     * Is there any reason why this is different than binary.  Do I need to handle encoding?
     */
    public void downloadText(String s3Bucket, String s3Key, DownloadTextListener listener) {
        try {
            File tempFile = File.createTempFile("downloadText", null);
            Log.d(TAG, "temp file created " + tempFile.getAbsolutePath());
            System.out.println("temp file created " + tempFile.getAbsolutePath());
            listener.setFile(tempFile);
            TransferObserver observer = this.transferUtility.download(s3Bucket, s3Key, tempFile);
            observer.setTransferListener(listener);
        } catch(Exception err) {
            Log.e(TAG, "Error in downloadText " + s3Bucket + "." + s3Key + "  " + err.toString());
        }
    }
    /**
     * Download Binary object to Data, receiving code might need to convert it needed form
     */
    public void downloadData(String s3Bucket, String s3Key, DownloadDataListener listener) {
        File tempFile = null;
        try {
            tempFile = File.createTempFile("downloadData", null);
            listener.setFile(tempFile);
            TransferObserver observer = this.transferUtility.download(s3Bucket, s3Key, tempFile);
            observer.setTransferListener(listener);
        } catch(Exception err) {
            Log.e(TAG, "Error in downloadData " + s3Bucket + "." + s3Key + "  " + err.toString());
        }
    }
    /**
     * Download File.  This works for binary and text files.
     */
    public void downloadFile(String s3Bucket, String s3Key, File file, DownloadFileListener listener) {
	    listener.setFile(file);
        TransferObserver observer = this.transferUtility.download(s3Bucket, s3Key, file);
        observer.setTransferListener(listener);
    }
    /**
     * Download zip file that contains one file, unzips and extracts file.
     * If there is ever a need to download and unzip an archive a separate method should be written
     * rather than modify this one.
     */
    public void downloadZipFile(String s3Bucket, String s3Key, File file, DownloadZipFileListener listener) {
        File zipFile = null;
        try {
	        listener.setFile(file);
            zipFile = File.createTempFile("downloadZip", "");
            listener.setZipFile(zipFile);
            TransferObserver observer = this.transferUtility.download(s3Bucket, s3Key, zipFile);
            observer.setTransferListener(listener);
        } catch (Exception err) {
            Log.e(TAG, "Error in downloadZipFile " + err.toString());
        }
    }
    /////////////////////////////////////////////////////////////////////////
    // Upload Functions
    /////////////////////////////////////////////////////////////////////////
    /**
     * Upload Analytics in Text form, such as JSON to analytics bucket
     * The ios version also has a method to upload a Dictionary, which is converts to json
     */
    public void uploadAnalytics(String sessionId, String timestamp, String prefix, String data, UploadDataListener listener) {
        String regionName = this.amazonS3.getRegion().name();
        String s3Bucket = "analytics-" + regionName + "-shortsands";
        String s3Key = sessionId + "-" + timestamp;
        String jsonPrefix = "{\"" + prefix + "\": ";
        String jsonSuffix = "}";
        String message = jsonPrefix + data + jsonSuffix;
        uploadText(s3Bucket, s3Key, data, listener);
    }
    /**
     * Upload string object to bucket
     */
    public void uploadText(String s3Bucket, String s3Key, String data, UploadDataListener listener) {
        File tempFile = null;
        try {
            tempFile = File.createTempFile("uploadText", "");
            listener.setFile(tempFile);
            FileManager.writeTextFully(tempFile, data);
            TransferObserver observer = this.transferUtility.upload(s3Bucket, s3Key, tempFile);
            observer.setTransferListener(listener);
        } catch(Exception err) {
            Log.e(TAG, "Error in uploadText " + err.toString());
        }
    }
    /**
     * Upload object in Data form to bucket.  Data must be prepared to correct form
     * before calling this function.
     */
    public void uploadData(String s3Bucket, String s3Key, byte[] data, UploadDataListener listener) {
        File tempFile = null;
        try {
            tempFile = File.createTempFile("uploadData", "");
            listener.setFile(tempFile);
            FileManager.writeBinaryFully(tempFile, data);
            TransferObserver observer = this.transferUtility.upload(s3Bucket, s3Key, tempFile);
            observer.setTransferListener(listener);
        } catch(Exception err) {
            Log.e(TAG, "Error in uploadData " + err.toString());
        }
    }
    /**
     * Upload file to bucket, this works for text or binary files
     */
    public void uploadFile(String s3Bucket, String s3Key, File file, UploadFileListener listener) {
        if (file.exists() && file.isFile()) {
	        listener.setFile(file);
            TransferObserver observer = this.transferUtility.upload(s3Bucket, s3Key, file);
            observer.setTransferListener(listener);
        } else {
            Log.e(TAG, "Error: File does not exist: " + file.getAbsolutePath());
        }
    }
}