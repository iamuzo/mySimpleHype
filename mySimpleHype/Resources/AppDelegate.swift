//
//  AppDelegate.swift
//  mySimpleHype
//
//  Created by Uzo on 2/3/20.
//  Copyright © 2020 Uzo. All rights reserved.
//

import UIKit
import UserNotifications
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        /**Adds Remote Notifications*/
        UNUserNotificationCenter.current().requestAuthorization(
        options: [.alert, .badge, .sound]) { (userResponse, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            //if no error, check that userResponse did allow authorization or deny
            if userResponse == true {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        
        
        return true
    }
    
    /**Accessing the delegate function that fires when user authorizes*/
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        HypeController.sharedGlobalInstance.subscribeForRemoteNotifications { (error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
            
            
        }
    }
    
    // what does this do and when does it fire
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
    }
    
    /**
     Notify app that a new hype record exists -
     all users get a notification when a new hype
     record is created thus fetch the new hypes
     */
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        HypeController.sharedGlobalInstance.fetch { (result) in
            switch result {
                case .success(let hypes):
                    HypeController.sharedGlobalInstance.hypes = hypes
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
    
    /**
     When the application becomes active,
     we want to reset the number of notifications
     that the bage displays like resetting number
     of messages to 0
     */
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}
