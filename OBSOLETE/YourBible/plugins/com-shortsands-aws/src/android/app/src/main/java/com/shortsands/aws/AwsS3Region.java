package com.shortsands.aws;

/**
 * Created by garygriswold on 4/18/18.
 */
import com.amazonaws.regions.Region;
import com.amazonaws.regions.RegionUtils;

public class AwsS3Region {

    private static String TAG = "AwsS3Region";

    public final Region type;
    public final String name;

    public AwsS3Region(Region type) {
        this.type = type;
        this.name = type.getName();
    }

    public AwsS3Region(String name) {
        Region ty = RegionUtils.getRegion(name);
        if (ty != null) {
            this.type = ty;
            this.name = name;
        } else {
            this.type = RegionUtils.getRegion("us-east-1");
            this.name = "us-east-1";
        }
    }
}
