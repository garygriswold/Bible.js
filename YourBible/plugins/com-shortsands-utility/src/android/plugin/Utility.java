package plugin;

/**
 * Created by garygriswold on 1/9/18.
 */

import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaInterface;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.provider.Settings;

public class Utility extends CordovaPlugin {

    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("platform")) {
            callbackContext.success("Android");
        } else if (action.equals("modelType")) {
            callbackContext.success(android.os.Build.BRAND);
        } else if (action.equals("modelName")) {
            callbackContext.success(android.os.Build.MODEL);
        } else {
            return false;
        }
        return true;
    }
}
