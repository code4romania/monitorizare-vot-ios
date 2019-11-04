//  Created by Code4Romania

import Foundation
import Firebase
import Crashlytics

func DebugLog(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
    let filename = URL(fileURLWithPath: file.description).lastPathComponent
    let output = "\(filename):\(line) \(function) $ \(message)"

    #if targetEnvironment(simulator)
        NSLogv("%@", getVaList([output]))
    #elseif DEBUG
        CLSNSLogv("%@", getVaList([output]))
    #else
        CLSLogv("%@", getVaList([output]))
    #endif
}
