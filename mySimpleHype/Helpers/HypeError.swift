//
//  HypeError.swift
//  mySimpleHype
//
//  Created by Uzo on 2/4/20.
//  Copyright © 2020 Uzo. All rights reserved.
//

import Foundation

enum HypeError: LocalizedError {
    case ckError(Error)
    case unableToUnWrapCKRecordObject
    case unexpectedRecordsFound
    
    var errorDescription: String? {
        switch self {
            case .ckError(let error):
                return error.localizedDescription
            case .unableToUnWrapCKRecordObject:
                return "unable to unwrap or get hype object"
            case .unexpectedRecordsFound:
                return "unexpected records found while trying to delete"
        }
    }
}
