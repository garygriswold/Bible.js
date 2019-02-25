//
//  AppDelegate.swift
//  Settings
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private static let YES = NSLocalizedString("Yes", comment: "Yes option on an alert")
    private static let NO = NSLocalizedString("No", comment: "No option on an alert")

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
        self.saveNote(url: url)
        return true
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
}

