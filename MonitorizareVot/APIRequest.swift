//
//  APIRequest.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/15/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation

typealias APIRequestCompletion = (_ success: Bool, _ informations: Any) -> Void

protocol APIRequest {
    func perform(informations: Any, url: NSURL, completion: APIRequestCompletion)
}
