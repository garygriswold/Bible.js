package plugin;

/**
 * Created by garygriswold on 1/9/18.
 */

import android.content.Context;
import android.provider.Settings;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaInterface;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import com.shortsands.utility.Sqlite3;

public class Utility extends CordovaPlugin {

    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("platform")) {
            callbackContext.success("Android");
        } else if (action.equals("modelType")) {
            callbackContext.success(android.os.Build.BRAND);
        } else if (action.equals("modelName")) {
            callbackContext.success(android.os.Build.MODEL);
        } else if (action.equals("open")) {
	        // what about threading each of these database calls
	        try {
		        Context context = this.cordova.getActivity();
	        	String dbname = args.getString(0);
				boolean copyIfAbsent = args.getBoolean(1);
				Sqlite3.openDB(context, dbname, copyIfAbsent);
				callbackContext.success();
			} catch(Exception error) {
				callbackContext.error(error.toString() + " on database open");
			}
	    } else if (action.equals("queryJS")) {
		    try {
		    	Sqlite3 database = Sqlite3.findDB(args.getString(0));
				String sql = args.getString(1);
				JSONArray values = args.getJSONArray(2);
				JSONArray resultSet = database.queryJS(sql, values);
				callbackContext.success(resultSet.toString());
		    } catch(Exception error) {
				callbackContext.error(error.toString() + " on database queryJS");
			}
		} else if (action.equals("executeJS")) {
			try {
				Sqlite3 database = Sqlite3.findDB(args.getString(0));
				String sql = args.getString(1);
				JSONArray values = args.getJSONArray(2);
				int rowCount = database.executeJS(sql, values);
				callbackContext.success(rowCount);
			} catch (Exception error) {
				callbackContext.error(error.toString() + " on database executeJS");
			}
		} else if (action.equals("bulkExecuteJS")) {
        	try {
				Sqlite3 database = Sqlite3.findDB(args.getString(0));
				String sql = args.getString(1);
				JSONArray values = args.getJSONArray(2);
				int rowCount = database.bulkExecuteJS(sql, values);
				callbackContext.success(rowCount);
			} catch (Exception error) {
				callbackContext.error(error.toString() + " on database bulkExecuteJS");
			}
		} else if (action.equals("close")) {
			try {
				Sqlite3 database = Sqlite3.findDB(args.getString(0));
				database.close();
				callbackContext.success();
			} catch(Exception error) {
				callbackContext.error(error.toString() + " on database close");
			}			
        } else {
            return false;
        }
        return true;
    }
}

