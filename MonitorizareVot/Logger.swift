//  Created by Code4Romania

import Foundation
import Firebase

func DebugLog(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
    let filename = URL(fileURLWithPath: file.description).lastPathComponent
    let output = "\(filename):\(line) \(function) $ \(message)"
    

    #if targetEnvironment(simulator)
        // just log to console
        NSLogv("%@", getVaList([output]))
    #elseif DEBUG
        // log to Crashlytics and Console
        Crashlytics.crashlytics().log(format: "%@", arguments: getVaList([output]))
        NSLogv("%@", getVaList([output]))
    #else
        // on prod, only log to crashlytics so we get it on crashes
        Crashlytics.crashlytics().log(format: "%@", arguments: getVaList([output]))
    #endif
}
