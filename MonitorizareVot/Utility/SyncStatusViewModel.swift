//
//  SyncStatusViewModel.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 16/11/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit
import Promises

class SyncStatusViewModel: NSObject {
    enum State {
        case synced
        case unsynced
    }
    
    var state: State {
        RemoteSyncer.shared.needsSync ? .unsynced : .synced
    }
    
    func sync(then callback: @escaping (Error?) -> Void) {
        RemoteSyncer.shared.syncUnsyncedData { anyError in
            callback(anyError)
        }
    }
}
