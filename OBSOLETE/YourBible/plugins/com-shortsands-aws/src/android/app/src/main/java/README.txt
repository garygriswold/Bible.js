NOTES ON Use of AWS
GNG 9/8/2017

After making changes to this module.  You much run build_framework.sh in the project directory in order
to promote those changes to other modules.

But it is imported to the Cordova App as a plugin that picks up the source files, not the .jar


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