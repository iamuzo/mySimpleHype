//
//  Hype.swift
//  mySimpleHype
//
//  Created by Uzo on 2/3/20.
//  Copyright © 2020 Uzo. All rights reserved.
//

import Foundation
import CloudKit

struct HypeKeys {
    static let recordTypeKey = "Hype"
    fileprivate static let bodyKey = "body"
    fileprivate static let timestampkey = "timestamp"
    fileprivate static let userReferenceKey = "userReference"
}

class Hype {
    
    var body: String
    var timestamp: Date
    var recordID: CKRecord.ID
    var userReference: CKRecord.Reference?
    
    init(body: String,
         timestamp: Date = Date(),
         recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString),
         userReference: CKRecord.Reference?)
    {
        self.body = body
        self.timestamp = timestamp
        self.recordID = recordID
        self.userReference = userReference
    }
}

extension Hype {
    /**
     Accepts a CKRecord, pulls out the values found in it, and
     uses those values to initialize a Hype instance.
     This is used when an object that already exists in CloudKit
     is requested from the server. When the request is fulfilled
     successfully, the returned Objects are CKRecords but since
     we need to present our own Class (in this case, an instance
     of class `Hype`) we need to turn each CKRecord into
     a Hype object. The failable `convenience` method below
     is used to accomplish this.
     
     ALL `init` (meaning memberwise and failable ones) must
     return something - either an instance of the class
     that is being initialized or nil.
     */
    convenience init?(ckRecord: CKRecord) {
        
        guard let body = ckRecord[HypeKeys.bodyKey] as? String,
            let timestamp = ckRecord[HypeKeys.timestampkey] as? Date
            else { return nil }
        
        // this is not definitely required thus we don't have to guard unwrap it
        // if our userReference comes back nil, it is okay because we told it is optional
        // in the Hype Class. but body and timestamp must always have a value as those
        // properties are not optional
        let userReference = ckRecord[HypeKeys.userReferenceKey] as? CKRecord.Reference
        
        self.init(body: body, timestamp: timestamp, recordID: ckRecord.recordID, userReference: userReference)
    }
}

/**
 this is used to ensure that updates and deletes work correctly.
 Basically we ask:
 - `hey! I need to update/delete an object`
 - `return true/false to let me know if I am working on the right object`
 */
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
 CKRecord is essentially a dictionary of key-value pairs BUT there are
 limitations to the types of values that can be assigned to keys. Currently
 the following are object types supported:
    - NSString
    - NSNumber
    - NSData
    - NSArray
    - CLLocation
    - CKAsset
    - CKRecord.Reference
 
 Notes on CKRecord
    CKRecord.Reference is only new Type that I should be unfamilar with. Still, it is easy
    to understand as it simply creates a link to a related record; the reference stores the
    ID of the target record.
    - The advantage of using a reference instead of storing the ID as a string is that
    - references can initiate cascade deletions of dependent records.
    - The disadvantage is that references can only link between records in the same
    - record zone, see CKRecord.Reference documentation for more
 */
extension CKRecord {
    /**
     Packaging our Hype model properties to be
     stored in a CKRecord and saved to the cloud
     */
    convenience init(hype: Hype) {
        self.init(recordType: HypeKeys.recordTypeKey, recordID: hype.recordID)
        self.setValuesForKeys([
            HypeKeys.bodyKey : hype.body,
            HypeKeys.timestampkey : hype.timestamp
        ])
        
        if let reference = hype.userReference {
            self.setValue(reference, forKey: HypeKeys.userReferenceKey)
        }
    }
}
