package plugin;

import android.util.Log;
import java.io.File;
import com.shortsands.aws.DownloadZipFileListener;
import com.shortsands.zip.Zip;
import org.apache.cordova.CallbackContext;
/**
 * Created by garygriswold on 5/22/17.
 */

public class DownloadPluginZipFileListener extends DownloadZipFileListener {

    private static String TAG = "DownloadPluginZipFileListener";
    protected CallbackContext callbackContext;
    
    private File unzipped = null;

    public DownloadPluginZipFileListener(CallbackContext callbackContext) {
        super();
	    this.callbackContext = callbackContext;
    }

    //public void setZipFile(File zipFile) {
    //    this.unzipped = this.file; // This will be the final result file.
    //    this.file = zipFile; // this will be the downloaded file.
    //}
    @Override
    protected void onComplete(int id) {
        super.onComplete(id);
        this.callbackContext.success();
    }
    
    @Override
    public void onError(int id, Exception error) {
	    super.onError(id, error);
        this.callbackContext.error(error.toString() + " on " + this.file.getAbsolutePath());
    }    
}

