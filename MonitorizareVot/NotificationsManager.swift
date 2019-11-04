//
//  NotificationsManager.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 03/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit
import Firebase


class NotificationsManager: NSObject {
    static let shared = NotificationsManager()
    
    fileprivate let gcmMessageIDKey = "gcm.message_id"
    
    override init() {
        super.init()
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        
        Messaging.messaging().delegate = self
    }
    
    func checkIfIsRegisteredForRemoteNotifications(then callback: @escaping (Bool) -> Void) {
        if #available(iOS 10.0, *) {
           let current = UNUserNotificationCenter.current()
           current.getNotificationSettings(completionHandler: { settings in
                DispatchQueue.main.async {
                    switch settings.authorizationStatus {
                    case .notDetermined, .denied:
                        callback(false)
                    case .authorized:
                        callback(true)
                    default:
                        callback(false)
                    }
                }
           })
        } else {
            // Fallback on earlier versions
            callback(UIApplication.shared.isRegisteredForRemoteNotifications)
        }
    }
    
    func registerForRemoteNotificationsIfNecessary() {
        checkIfIsRegisteredForRemoteNotifications { [weak self] authorized in
            guard let self = self else { return }
            if !authorized {
                self.registerForRemoteNotifications()
            } else {
                DebugLog("Already authorized for push notifications")
            }
        }
    }
    
    func registerForRemoteNotifications() {
        DebugLog("Registering for push notifications")
        let application = UIApplication.shared
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()

    }
    
    func didReceiveRemoteNotification(userInfo: [AnyHashable: Any]) {
        guard let topmostController = AppDelegate.shared.window?.rootViewController?.topmostViewController else { return }
        
        let title = userInfo["title"] as? String ?? "Notification"
        let message = userInfo["body"] as? String ?? ""
        let messageAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        messageAlert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))
        topmostController.present(messageAlert, animated: true, completion: nil)
    }
    
    func didFailToRegisterForRemoteNotifications(withError error: Error) {
        DebugLog("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: Data) {
        //print("didRegisterForRemoteNotificationsWithDeviceToken: \(deviceToken)")
        //let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        //print("token str = \(token)")
    }
    
    func uploadTokenToServer(token: String) {
        APIManager.shared.sendPushToken(withToken: token) { error in
            if let error = error {
                DebugLog("Could not send token to server. Error: \(error.localizedDescription)")
            } else {
                DebugLog("Sent token to server")
            }
        }
    }
}


@available(iOS 10, *)
extension NotificationsManager: UNUserNotificationCenterDelegate {

  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)
    // Print message ID.
    if let messageID = userInfo[gcmMessageIDKey] {
        DebugLog("Message ID: \(messageID)")
    }

    didReceiveRemoteNotification(userInfo: userInfo)

    // Change this to your preferred presentation option
    completionHandler([])
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    // Print message ID.
    if let messageID = userInfo[gcmMessageIDKey] {
        DebugLog("Message ID: \(messageID)")
    }

    didReceiveRemoteNotification(userInfo: userInfo)

    completionHandler()
  }
}

// [END ios_10_message_handling]

extension NotificationsManager: MessagingDelegate {
  // [START refresh_token]
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        DebugLog("Firebase registration token: \(fcmToken)")
    
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        
        uploadTokenToServer(token: fcmToken)

        // Note: This callback is fired at each app startup and whenever a new token is generated.
  }
  
    // [END refresh_token]
  // [START ios_10_data_message]
  // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
  // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
  func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        DebugLog("Received data message: \(remoteMessage.appData)")
  }
  // [END ios_10_data_message]
}
