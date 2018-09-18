package com.shortsands.aws;

/**
 * Created by garygriswold on 5/19/17.
 */
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager.NameNotFoundException;
import android.os.Build;
import android.util.Log;

import com.amazonaws.ClientConfiguration;
import com.amazonaws.HttpMethod;
import com.amazonaws.regions.Region;
import com.amazonaws.regions.RegionUtils;
import com.amazonaws.services.s3.S3ClientOptions;
import com.amazonaws.services.s3.model.GeneratePresignedUrlRequest;

import com.amazonaws.mobileconnectors.s3.transferutility.TransferObserver;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferUtility;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.ObjectMetadata;

import com.shortsands.io.FileManager;

import java.io.File;
import java.net.URL;
import java.util.Date;
import java.util.Locale;

public class AwsS3 {

    static String TAG = "AwsS3";

    AwsS3Region region;
    AmazonS3 amazonS3;
    TransferUtility transferUtility;

    public AwsS3(AwsS3Region region, Credentials credential, Context context) {
        super();
        this.region = region;
        Log.d(TAG, "regionName input = " + region.name);
        ClientConfiguration config = new ClientConfiguration();
        config.setUserAgent(this.getUserAgent());
        this.amazonS3 = new AmazonS3Client(credential.provider, config);
        this.amazonS3.setRegion(region.type);
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
            observer.setTransferListener(listener); // why here
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
            observer.setTransferListener(listener); // why here
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
        observer.setTransferListener(listener); // why here
    }
    /**
     * Download zip file that contains one file, unzips and extracts file.
     * If there is ever a need to download and unzip an archive a separate method should be written
     * rather than modify this one.
     */
    public void downloadZipFile(String s3Bucket, String s3Key, File file, DownloadZipFileListener listener) {
        File zipFile = null;
        String bucket = regionalizeBucket(s3Bucket);
        try {
	        listener.setFile(file);
            zipFile = File.createTempFile("downloadZip", "");
            listener.setZipFile(zipFile);
            TransferObserver observer = this.transferUtility.download(bucket, s3Key, zipFile, listener);
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
        String s3Bucket = "analytics-" + this.region.name + "-shortsands";
        Log.d(TAG, "Bucket " + s3Bucket);
        String s3Key = sessionId + "-" + timestamp;
        Log.d(TAG, "Key " + s3Key);
        String jsonPrefix = "{\"" + prefix + "\": ";
        String jsonSuffix = "}";
        String message = jsonPrefix + data + jsonSuffix;
        Log.d(TAG, "Message " + message);
        uploadText(s3Bucket, s3Key, message, "application/json", listener);
    }
    /**
     * Upload string object to bucket
     */
    public void uploadText(String s3Bucket, String s3Key, String data, String contentType, UploadDataListener listener) {
        File tempFile = null;
        try {
            tempFile = File.createTempFile("uploadText", "");
            Log.d(TAG, "File " + tempFile.toString());
            FileManager.writeTextFully(tempFile, data);
            upload(s3Bucket, s3Key, tempFile, contentType, listener);
        } catch(Exception err) {
            Log.e(TAG, "Error in uploadText " + err.toString());
        }
    }
    /**
     * Upload object in Data form to bucket.  Data must be prepared to correct form
     * before calling this function.
     */
    public void uploadData(String s3Bucket, String s3Key, byte[] data, String contentType, UploadDataListener listener) {
        File tempFile = null;
        try {
            tempFile = File.createTempFile("uploadData", "");
            FileManager.writeBinaryFully(tempFile, data);
            upload(s3Bucket, s3Key, tempFile, contentType, listener);
        } catch(Exception err) {
            Log.e(TAG, "Error in uploadData " + err.toString());
        }
    }
    /**
     * Upload file to bucket, this works for text or binary files
     */
    public void uploadFile(String s3Bucket, String s3Key, File file, String contentType, UploadFileListener listener) {
        if (file.exists() && file.isFile()) {
            upload(s3Bucket, s3Key, file, contentType, listener);
        } else {
            Log.e(TAG, "Error: File does not exist: " + file.getAbsolutePath());
        }
    }
    private void upload(String s3Bucket, String s3Key, File file, String contentType, AwsS3AbstractListener listener) {
        listener.setFile(file);
        ObjectMetadata metadata = new ObjectMetadata();
        metadata.setContentType(contentType);
        TransferObserver observer = this.transferUtility.upload(s3Bucket, s3Key, file, metadata);
        observer.setTransferListener(listener); // why here
    }
    private String getUserAgent() {
        StringBuilder result = new StringBuilder();
        result.append("v1");
        result.append(":");
        String locale = Locale.getDefault().toString();
        result.append(locale);
        result.append(":");
        result.append(locale); // This should be prefLang list, but it does not exist on android.
        result.append(":");
        result.append(Build.MANUFACTURER);
        result.append(":");
        result.append(Build.MODEL);
        result.append(":");
        result.append("android");
        result.append(":");
        result.append(Build.VERSION.RELEASE);
        result.append(":");
        try {
            PackageInfo pInfo = AwsS3Manager.context.getPackageManager().getPackageInfo(AwsS3Manager.context.getPackageName(), 0);
            result.append(pInfo.packageName);
            result.append(":");
            result.append(pInfo.versionName);
        } catch(NameNotFoundException nnfe) {
            result.append("unknown");
            result.append(":");
            result.append(nnfe.toString());
        }
        return(result.toString());
    }
    private String regionalizeBucket(String bucket) {
        if (bucket.contains("oldregion")) {
            String reg = this.region.name;
            if (reg.equals("us-east-1")) {
                return bucket.replace("oldregion", "na-va");
            } else if (reg.equals("eu-west-1")) {
                return bucket.replace("oldregion", "eu-ie");
            } else if (reg.equals("ap-northeast-1")) {
                return bucket.replace("oldregion", "as-jp");
            } else if (reg.equals("ap-southeast-1")) {
                return bucket.replace("oldregion", "as-sg");
            } else if (reg.equals("ap-southeast-2")) {
                return bucket.replace("oldregion", "oc-au");
            } else {
                return bucket.replace("oldregion", "na-va");
            }
        }
        if (bucket.contains("region")) {
            return bucket.replace("region", this.region.name);
        }
        return bucket;
    }
}