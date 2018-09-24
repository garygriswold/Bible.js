package com.shortsands.io;

import android.util.Log;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;


/**
 * Created by garygriswold on 4/9/18.
 */

public class Zip {

    private static String TAG = "Zip";

    public static List<File> unzipFile(File zipFile, File targetDirectory) throws IOException {
        final int BUFFER_LEN = 8192;
        ArrayList<File> files = new ArrayList<File>();
        BufferedOutputStream output = null;
        BufferedInputStream input = null;
        int count;
        byte buffer[] = new byte[BUFFER_LEN];
        ZipFile zipfile = new ZipFile(zipFile);
        Enumeration e = zipfile.entries();
        while(e.hasMoreElements()) {
            ZipEntry entry = (ZipEntry) e.nextElement();
            Log.d(TAG, "Extracting: " + entry);
            File outputFile = new File(targetDirectory, entry.getName());
            if (entry.isDirectory()) {
                if (! outputFile.exists()) {
                    outputFile.mkdirs();
                }
            } else {
                try {
                    input = new BufferedInputStream(zipfile.getInputStream(entry));
                    FileOutputStream fos = new FileOutputStream(outputFile);
                    output = new BufferedOutputStream(fos, BUFFER_LEN);
                    while ((count = input.read(buffer, 0, BUFFER_LEN)) != -1) {
                        output.write(buffer, 0, count);
                    }
                } finally {
                    if (input != null) input.close();
                    if (output != null) output.close();
                    files.add(outputFile);
                }
            }
        }
        return files;
    }
}
