package com.shortsands.io;

/**
 * Created by garygriswold on 5/22/17.
 */
import android.util.Log;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.InputStream;
import java.io.OutputStream;

public class FileManager {

    private static String TAG = "FileManager";

    /**
     * Method to read a TextFile
     */
    public static String readTextFully(File file) {
        BufferedReader reader = null;
        String output = null;
        try {
            reader = new BufferedReader(new FileReader(file));
            StringBuilder sb = new StringBuilder();
            String line = reader.readLine();

            while (line != null) {
                if (sb.length() > 0) {
                    sb.append("\n");
                }
                sb.append(line);
                line = reader.readLine();
            }
            output = sb.toString();
        } catch(Exception err) {
            Log.e(TAG, "Error in readTextFileFully " + file.getAbsolutePath() + " " + err.toString());
        } finally {
            if (reader != null) try { reader.close(); } catch(Exception err) {}
        }
        return(output);
    }
    /**
     * Method to write a Text File
     */
    public static void writeTextFully(File file, String data) {
        BufferedWriter writer = null;
        try {
            writer = new BufferedWriter(new FileWriter(file));
            writer.write(data, 0, data.length());
        } catch(Exception err) {
            Log.e(TAG, "Error in writeTextFileFully " + file.getAbsolutePath() + " " + err.toString());
        } finally {
            if (writer != null) try { writer.close(); } catch(Exception err) {}
        }
    }
    /**
     * Method to read a binary file
     */
    public static byte[] readBinaryFully(File file) {
        DataInputStream input = null;
        byte[] output = null;
        try {
            output = new byte[(int) file.length()];
            input = new DataInputStream(new FileInputStream(file));
            input.readFully(output);
        } catch(Exception err) {
            Log.e(TAG, "Error in readBinaryFileFully " + file.getAbsolutePath() + " " + err.toString());
        } finally {
            if (input != null) try { input.close(); } catch(Exception err) {}
        }
        return(output);
    }
    /**
     * Method to write a binary File
     */
    public static void writeBinaryFully(File file, byte[] data) {
        DataOutputStream output = null;
        try {
            output = new DataOutputStream(new FileOutputStream(file));
            output.write(data, 0, data.length);
        } catch(Exception err) {
            Log.e(TAG, "Error in writeBinaryFileFully " + file.getAbsolutePath() + " " + err.toString());
        } finally {
            if (output != null) try { output.close(); } catch(Exception err) {}
        }
    }
    /**
     * Copy File
     */
    public static void copy(File src, File dst) {
        InputStream in = null;
        OutputStream out = null;
        try {
            in = new FileInputStream(src);
            out = new FileOutputStream(dst);

            // Transfer bytes from in to out
            byte[] buf = new byte[1024];
            int len;
            while ((len = in.read(buf)) > 0) {
                out.write(buf, 0, len);
            }
        } catch(Exception err) {
            Log.e(TAG, "Error in copy " + src.getAbsolutePath() + " " + err.toString());
        } finally {
            if (in != null) try { in.close(); } catch(Exception e) {}
            if (out != null) try { out.close(); } catch(Exception e) {}
        }
    }
}
