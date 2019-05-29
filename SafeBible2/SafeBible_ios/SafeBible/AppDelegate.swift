//
//  AppDelegate.swift
//  Settings
//

import UIKit
import AWS
import Utility
import AudioPlayer
import Foundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private static let YES = NSLocalizedString("Yes", comment: "Yes option on an alert")
    private static let NO = NSLocalizedString("No", comment: "No option on an alert")

    var window: UIWindow?
    private var bibleDownloadTask: UIBackgroundTaskIdentifier = .invalid

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Setup CarPlay
        CarPlayManager.setUp()
        
        let readerNavigator = ReaderViewNavigator()
        let navController = readerNavigator.present()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.rootViewController = navController
        self.window!.rootViewController!.view.backgroundColor = AppFont.backgroundColor
        self.window!.makeKeyAndVisible()
        
        return true
    }
    
    // Respond to App starts from click on .notes database files.
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        self.saveNote(url: url)
        return true
    }
    
    // Respond to moving into background
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.doBibleDownloadIfNeeded()
    }
    
    private func saveNote(url: URL) {
        let dbname = String(url.lastPathComponent.split(separator: ".")[0])
        let alert = UIAlertController(title: "Save Notes?", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.text = dbname
        }
        alert.addAction(UIAlertAction(title: AppDelegate.YES, style: .default, handler: { _ in
            let renamed: String = alert.textFields![0].text!
            if let final = NotesDB.shared.importDB(source: url, dbname: renamed) {
                self.useNote(dbname: final)
            }
        }))
        alert.addAction(UIAlertAction(title: AppDelegate.NO, style: .cancel, handler: nil))
        let controller = UIApplication.shared.keyWindow?.rootViewController
        controller?.present(alert, animated: true, completion: nil)
    }
    
    private func useNote(dbname: String) {
        let alert = UIAlertController(title: "Saved \(dbname).\nUse it now?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: AppDelegate.YES, style: .default, handler: { _ in
            NotesDB.shared.currentDB = dbname
        }))
        alert.addAction(UIAlertAction(title: AppDelegate.NO, style: .cancel, handler: nil))
        let controller = UIApplication.shared.keyWindow?.rootViewController
        controller?.present(alert, animated: true, completion: nil)
    }
    
    // This is placed here, because it looks fragile and could be effected by OS changes.
    static func findRootController(controller: UIViewController) -> UIViewController? {
        if let nav = controller.parent as? UINavigationController {
            return nav.viewControllers[0]
        } else {
            return nil
        }
    }
    
    /** This method is called when entering background.  It downloads the current Bible if needed */
    private func doBibleDownloadIfNeeded() {
        if self.bibleDownloadTask != .invalid {
            return
        }
        let reference = HistoryModel.shared.current()
        let bible = reference.bible
        if !bible.textBucket.contains("shortsands") {
            return
        }
        if reference.isDownloaded {
            return
        }
        if !BibleDB.shared.shouldDownload(bible: bible) {
            return
        }
        self.bibleDownloadTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            // Do cleanup here for when task does not complete
            UIApplication.shared.endBackgroundTask(self.bibleDownloadTask)
            self.bibleDownloadTask = .invalid
        })
        let s3 = AwsS3Manager.findSS()
        let bucket = "shortsands-oldregion"
        let databaseName = bible.bibleId // There should be a database property?
        let key = databaseName + ".zip"
        
        let temporaryDirectory: URL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let tempURL = temporaryDirectory.appendingPathComponent(NSUUID().uuidString + ".db")
        
        s3.downloadZipFile(s3Bucket: bucket, s3Key: key, filePath: tempURL, view: nil, complete: {
            error in
            if let err = error {
                print("ERROR: \(err)")
            } else {
                Sqlite3.closeAllDB()
                do {
                    let filePath = Sqlite3.pathDB(dbname: databaseName)
                    _ = try FileManager.default.replaceItemAt(filePath, withItemAt: tempURL,
                                                              backupItemName: nil, options: [])
                    print("SUCCESS in s3.downloadZipFile \(bucket) \(key)")
                } catch let err {
                    print("ERROR: \(err)")
                }
            }
            UIApplication.shared.endBackgroundTask(self.bibleDownloadTask)
            self.bibleDownloadTask = .invalid
        })
    }
}

