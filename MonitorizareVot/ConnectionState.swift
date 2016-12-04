//  Created by Code4Romania

import Foundation

typealias ConnectionStateCompletion = (_ available: Bool) -> Void

func connectionState(_ completion: @escaping ConnectionStateCompletion) {
    let url: URL = URL(string: "https://google.com/")!
    let request = NSMutableURLRequest(url: url as URL)
    request.httpMethod = "HEAD"
    request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
    request.timeoutInterval = 5.0
    
    URLSession(configuration: .default).dataTask(with: request as URLRequest, completionHandler: { (data, urlResponse, error) in
        DispatchQueue.main.async {
            if error == nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }).resume()
}
