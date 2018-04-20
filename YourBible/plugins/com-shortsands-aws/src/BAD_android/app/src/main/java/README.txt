NOTES ON Use of AWS
GNG 9/8/2017

When using AWS.jar be sure to put the necessary entries into the AndroidManifest.xml file.
The includes:
1. INTERNET permission
2. ACCESS_NETWORK_STATE permission
3. TransferService service

<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="com.shortsands.whatever">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    .....
    <application
        ...
        <activity
            ...
        </activity>
        <service android:enabled="true" android:name="com.amazonaws.mobileconnectors.s3.transferutility.TransferService" />
    </application>
</manifest>