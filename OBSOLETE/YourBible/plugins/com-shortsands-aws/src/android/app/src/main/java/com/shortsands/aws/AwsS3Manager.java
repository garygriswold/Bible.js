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
        return manager.findFor(manager.ssRegion);
    }
    public static AwsS3 findDbp() {
        AwsS3Manager manager = getSingleton();
        return manager.findFor(manager.dbpRegion);
    }
    public static AwsS3 findTest() {
        AwsS3Manager manager = getSingleton();
        return manager.findFor(manager.testRegion);
    }

    private String countryCode;
    private AwsS3Region ssRegion;
    private AwsS3Region dbpRegion;
    private AwsS3Region testRegion;
    private Map<String, AwsS3> awsS3Map;

    private AwsS3Manager() {
        String country = Locale.getDefault().getCountry();
        if (country != null) {
            Log.d(TAG, "Country Code " + country);
            this.countryCode = country;
        } else {
            this.countryCode = "US";
        }

        this.ssRegion = new AwsS3Region("us-east-1");
        this.dbpRegion = new AwsS3Region("us-east-1");
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
                // The following is here as a reminder that we should pull this from the Region table.
                this.dbpRegion = new AwsS3Region("us-east-1");
            }
        } catch (Exception err) {
            Log.d(TAG, "Unable to set regions " + Sqlite3.errorDescription(err));
        } finally {
            db.close();
        }
    }

    private AwsS3 findFor(AwsS3Region region) {
        AwsS3 awsS3 = this.awsS3Map.get(region.name);
        if (awsS3 == null) {
            awsS3 = new AwsS3(region, this.context);
            this.awsS3Map.put(region.name, awsS3);
        }
        return(awsS3);
    }
}
