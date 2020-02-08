//
//  HypeUser.swift
//  mySimpleHype
//
//  Created by Uzo on 2/4/20.
//  Copyright © 2020 Uzo. All rights reserved.
//

import Foundation
import CloudKit

struct HypeUserKeys {
    static let recordTypeKey = "HypeUser"
    static let appleUserRefKey = "appleUserRef"
    fileprivate static let usernameKey = "username"
    fileprivate static let bioKey = "bio"
}

class HypeUser {
    var username: String
    var bio: String
    var recordID: CKRecord.ID
    var appleUserRef: CKRecord.Reference
    
    init(
        username: String,
        bio: String = "",
        recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString),
        appleUserRef: CKRecord.Reference)
    {
        self.username = username
        self.bio = bio
        self.recordID = recordID
        self.appleUserRef = appleUserRef
    }
}

extension HypeUser {
    convenience init?(ckRecord: CKRecord) {
        guard let username = ckRecord[HypeUserKeys.usernameKey] as? String,
            let bio = ckRecord[HypeUserKeys.bioKey] as? String,
            let appleUserRef = ckRecord[HypeUserKeys.appleUserRefKey] as? CKRecord.Reference
        else { return nil }
        
        self.init(username: username, bio: bio, recordID: ckRecord.recordID, appleUserRef: appleUserRef)
    }
}

extension HypeUser: Equatable {
    static func == (lhs: HypeUser, rhs: HypeUser) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}

extension CKRecord {
    convenience init(hypeUser: HypeUser) {
        self.init(recordType: HypeUserKeys.recordTypeKey, recordID: hypeUser.recordID)
        setValuesForKeys([
            HypeUserKeys.usernameKey : hypeUser.username,
            HypeUserKeys.bioKey : hypeUser.bio,
            HypeUserKeys.appleUserRefKey : hypeUser.appleUserRef
        ])
    }
}
