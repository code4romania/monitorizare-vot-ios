//  Created by Code4Romania

import Foundation
import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
        
    var window: UIWindow?
    
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        CoreData.containerName = "s"
        
        if !PreferencesManager.shared.wasAppStartedBefore {
            handleFirstAppStart()
        }
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        // preload remote config
        _ = RemoteConfigManager.shared
        
        // preload the reachability manager
        _ = ReachabilityManager.shared
        
        // preload the notifications manager
        _ = NotificationsManager.shared
        
        configureAppearance()
        
        #if DEBUG
        DebugLog("\(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0])")
        #endif
        
        setRootViewController()
        window?.makeKeyAndVisible()

        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        RemoteSyncer.shared.syncUnsyncedData { error in
            DebugLog("Tried to sync any unsynced data. Error? \(error?.localizedDescription ?? "None")")
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        CoreData.saveContext()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NotificationsManager.shared.didFailToRegisterForRemoteNotifications(withError: error)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationsManager.shared.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: deviceToken)
    }
}

// MARK: - Appearance

extension AppDelegate {
    
    fileprivate func handleFirstAppStart() {
        DebugLog("App is started for the first time. Handling...")
        
        // delete all previous data (this is in case the user has updated from an older version, this way we won't have conflicts)
        CoreData.clearDatabase()
    }
    
    fileprivate func configureAppearance() {
        UINavigationBar.appearance().tintColor = UIColor.navigationBarTint
        UINavigationBar.appearance().backgroundColor = .navigationBarBackground
        UINavigationBar.appearance().barTintColor = .navigationBarBackground
    }
    
    fileprivate func setRootViewController() {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        
        AppRouter.shared.showAppEntry()
    }
    
    
}
