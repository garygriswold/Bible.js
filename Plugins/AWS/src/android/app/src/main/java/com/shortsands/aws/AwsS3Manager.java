package com.shortsands.aws;

/**
 * Created by garygriswold on 4/18/18.
 */
import android.content.Context;
import android.util.Log;

import com.amazonaws.regions.Region;
import com.shortsands.utility.Sqlite3;

import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

public class AwsS3Manager {

    private static String TAG = "AwsS3Manager";

    static Context context = null;

    public static void initialize(Context ctx) {
        AwsS3Manager.context = ctx;
    }

    private static AwsS3Manager instance;
    public static AwsS3Manager getSingleton() {
        if (AwsS3Manager.instance == null) {
            AwsS3Manager.instance = new AwsS3Manager();
            AwsS3Manager.instance.initialize();
        }
        return AwsS3Manager.instance;
    }

    public static AwsS3 findSS() {
        AwsS3Manager manager = getSingleton();
        return manager.findFor(manager.ssRegion, Credentials.AWS_BIBLE_APP);
    }
    public static AwsS3 findDbp() {
        AwsS3Manager manager = getSingleton();
        return manager.findFor(manager.dbpRegion, Credentials.DBP_BIBLE_APP);
    }
    public static AwsS3 findTest() {
        AwsS3Manager manager = getSingleton();
        return manager.findFor(manager.testRegion, Credentials.AWS_BIBLE_APP);
    }

    private String countryCode;
    private AwsS3Region ssRegion;
    private AwsS3Region dbpRegion;
    private AwsS3Region testRegion;
    private Map<String, AwsS3> awsS3Map;

    private AwsS3Manager() {
        String country = Locale.getDefault().getCountry();
        if (country != null) {
            this.countryCode = country;
        } else {
            this.countryCode = "US";
        }
        //this.countryCode = "AU"; // Uncomment for testing regions
        Log.d(TAG, "Country Code " + this.countryCode);

        this.ssRegion = new AwsS3Region("us-east-1");
        this.dbpRegion = new AwsS3Region("us-west-2");
        this.testRegion = new AwsS3Region("us-west-2");
        this.awsS3Map = new HashMap<String, AwsS3>();
    }
    private void initialize() {
        Sqlite3 db = new Sqlite3(AwsS3Manager.context);
        String sql = "SELECT awsRegion FROM Region WHERE countryCode=?";
        String[] values = new String[1];
        values[0] = this.countryCode;
        try {
            db.open("Versions.db", true);
            String[][] resultSet = db.queryV1(sql, values);
            if (resultSet.length > 0) {
                String[] row = resultSet[0];
                String awsRegion = row[0];
                if (awsRegion != null) {
                    this.ssRegion = new AwsS3Region(awsRegion);
                }
            }
        } catch (Exception err) {
            Log.d(TAG, "Unable to set regions " + Sqlite3.errorDescription(err));
        } finally {
            db.close();
        }
    }

    private AwsS3 findFor(AwsS3Region region, Credentials credential) {
        String key = credential.name + region.name;
        AwsS3 awsS3 = this.awsS3Map.get(key);
        if (awsS3 == null) {
            awsS3 = new AwsS3(region, credential, this.context);
            this.awsS3Map.put(key, awsS3);
        }
        return(awsS3);
    }
}
