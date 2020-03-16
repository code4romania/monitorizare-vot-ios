//
//  AppUpdateManager.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 14/12/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit
import Alamofire

/// This manager's sole purpose is to check if there's a new version of the app available on the app store
/// You can adjust its functionality via RemoteConfig or completely disable it using the local xcconfig setting
/// `DISABLE_UPDATE_CHECK` (set it to true)
class AppUpdateManager: NSObject {
    static let shared = AppUpdateManager()
    
    var currentVersion: String {
        guard let infoDict = Bundle.main.infoDictionary,
            let currentVer = infoDict["CFBundleShortVersionString"] as? String else {
            fatalError("No current ver found, this shouldn't happen")
        }
        return currentVer
    }
    
    var applicationURL: URL {
        return URL(string: "https://apps.apple.com/app/id1183063109")!
    }
    
    var isUpdateCheckCompletelyDisabled: Bool {
        if let infoDict = Bundle.main.infoDictionary,
            let disableFlag = infoDict["DISABLE_UPDATE_CHECK"] as? String,
            disableFlag == "true" {
            return true
        }
        return false
    }
    
    private override init() {}
    
    /// It's okay to have the error messages not localized, since they'll never reach the user. Debugging purposes only
    enum UpdateError: Error {
        case noResults
        case unknown(reason: String)
        
        var localizedDescription: String {
            switch self {
            case .noResults: return "No information on latest version"
            case .unknown(let reason): return reason
            }
        }
    }
    
    typealias NewVersionCallback = (_ isNewVersionAvailable: Bool, _ result: AppInformationResponse.ResultResponse?, _ error: UpdateError?) -> Void
    
    func checkForNewVersion(then callback: @escaping NewVersionCallback) {
        guard !isUpdateCheckCompletelyDisabled else {
            DebugLog("Update check disabled via DISABLE_UPDATE_CHECK flag. Ignoring...")
            return
        }
        
        guard let infoDict = Bundle.main.infoDictionary,
            let bundleId = infoDict["CFBundleIdentifier"] as? String else {
            fatalError("No app id found, this shouldn't happen")
        }
        
        let currentVer = currentVersion
        let urlString = "https://itunes.apple.com/lookup?bundleId=" + bundleId
        guard let url = URL(string: urlString) else {
            fatalError("Invalid check url: \(urlString)")
        }
        
        Alamofire
            .request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [:])
            .response { response in
                if response.response?.statusCode == 200,
                    let data = response.data {
                    do {
                        let response = try JSONDecoder().decode(AppInformationResponse.self, from: data)
                        if let result = response.results.first {
                            let isNewVersionAvailable = result.version.compare(currentVer, options: .numeric, range: nil, locale: nil) == .orderedDescending
                            callback(isNewVersionAvailable, result, nil)
                            return
                        }
                    } catch {
                        callback(false, nil, .unknown(reason: "Couldn't decode response"))
                    }
                }
                callback(false, nil, .unknown(reason: "Unknown reason"))
        }
    }
}
