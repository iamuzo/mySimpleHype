//
//  HypeUserError.swift
//  mySimpleHype
//
//  Created by Uzo on 2/6/20.
//  Copyright © 2020 Uzo. All rights reserved.
//

import Foundation

enum HypeUserError: LocalizedError {
    case ckError(Error)
    case unableToUnWrapCKRecordObject
    case unexpectedRecordsFound
    case appleUserNotLoggedIn
    
    var errorDescription: String? {
        switch self {
            case .ckError(let error):
                return error.localizedDescription
            case .unableToUnWrapCKRecordObject:
                return "unable to unwrap or get hype object"
            case .unexpectedRecordsFound:
                return "unexpected records found while trying to delete"
            case .appleUserNotLoggedIn:
                return "apple user id reference not found"
        }
    }
}
