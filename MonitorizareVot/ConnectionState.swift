//
//  ConnectionState.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/19/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation

typealias ConnectionStateCompletion = (_ available: Bool) -> Void

func connectionState(_ completion: @escaping ConnectionStateCompletion) {
    let url: URL = URL(string: "http://google.com/")!
    let request = NSMutableURLRequest(url: url as URL)
    request.httpMethod = "HEAD"
    request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
    request.timeoutInterval = 2.0
    
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
