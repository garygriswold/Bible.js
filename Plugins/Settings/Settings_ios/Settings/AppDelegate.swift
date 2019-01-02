//
//  AppDelegate.swift
//  Settings
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
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
        //print("Start App from URL \(url) with options \(options)")
        if let dbname = NotesDB.shared.importNotesDB(source: url) {
            let message = "\(dbname) has been saved. Use the new notes file now?"
            let alert = UIAlertController(title: "Notes", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
                NotesDB.shared.currentDB = dbname
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            let controller = UIApplication.shared.keyWindow?.rootViewController
            controller?.present(alert, animated: true, completion: nil)
        }
        //print("NOTES DATABASES: \(NotesDB.shared.listDB())")
        return true
    }
}

