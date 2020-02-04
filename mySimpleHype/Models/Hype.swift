//
//  Hype.swift
//  mySimpleHype
//
//  Created by Uzo on 2/3/20.
//  Copyright © 2020 Uzo. All rights reserved.
//

import Foundation
import CloudKit

struct HypeStrings {
    static let recordTypeKey = "Hype"
    fileprivate static let bodyKey = "body"
    fileprivate static let timestampkey = "timestamp"
}

class Hype {
    
    var body: String
    var timestamp: Date
    var recordID: CKRecord.ID
    
    init(body: String,
         timestamp: Date = Date(),
         recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString))
    {
        self.body = body
        self.timestamp = timestamp
        self.recordID = recordID
    }
}

extension Hype {
    /**
     Accepts a CKRecord, pulls out the values found in it, and
     uses those values to initialize a Hype instance
     */
    convenience init?(ckRecord: CKRecord) {
        guard let body = ckRecord[HypeStrings.bodyKey] as? String,
            let timestamp = ckRecord[HypeStrings.timestampkey] as? Date
            else { return nil }
        
        self.init(body: body, timestamp: timestamp, recordID: ckRecord.recordID)
    }
}

extension Hype: Equatable {
    static func == (lhs: Hype, rhs: Hype) -> Bool {
        /**
         a shorthandway to do this is:
         return lhs === rhs, which just says that the left-hand-side is equal to the rhs
         */
        return lhs.recordID == rhs.recordID
    }
}

/**
 CKRecord is essentially a dictionary of key-value pairs
 */
extension CKRecord {
    /**
     Packaging our Hype model properties to be
     stored in a CKRecord and saved to the cloud
     */
    convenience init(hype: Hype) {
        self.init(recordType: HypeStrings.recordTypeKey, recordID: hype.recordID)
        self.setValuesForKeys([
            HypeStrings.bodyKey : hype.body,
            HypeStrings.timestampkey : hype.timestamp
        ])
    }
}
