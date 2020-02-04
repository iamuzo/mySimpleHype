//
//  HypeController.swift
//  mySimpleHype
//
//  Created by Uzo on 2/3/20.
//  Copyright © 2020 Uzo. All rights reserved.
//

import Foundation
import CloudKit

class HypeController {
    
    // MARK: - Properties
    var hypes: [Hype] = []
    static let sharedGlobalInstance = HypeController()
    
    /**
     Hype inmitates a social media platform where user
     created `Hype` instances are public. Hence use public DB
     */
    let publicDB = CKContainer.default().publicCloudDatabase
    
    func saveHypeInstance(with body: String, completion: @escaping (Bool) -> Void) {
        let newHypeInstance = Hype(body: body)
        
        //use hype instance to create a CKRecord
        //using the convience initializer that
        //we wrote in CKRecord extension
        let hypeRecord = CKRecord(hype: newHypeInstance)
        
        // save this hypeRecord in the cloud Cloudkit
        publicDB.save(hypeRecord) { (ckrecordOptional, error) in
            
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            
            //saved record is an optional thus we need to unwrap it
            guard let record = ckrecordOptional,
                let savedHypeRecord = Hype(ckRecord: record)
                //if we can't unwrap, completion is false thus
                //and we return/jump out from the function
                else {  completion(false); return }

            // Insert the successfully saved Hype object
            //at the first index of our Source of Truth array
            self.hypes.insert(savedHypeRecord, at: 0)

            completion(true)
        }
    }
    
    func fetchHypes(completion: @escaping (Bool) -> Void) {
        /**a predicate is a way to set rules for what
         information we want back. In this case we
         we want all Hype Records
         */
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: HypeStrings.recordTypeKey, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
            
            guard let records = records
                else { completion(false); return}
            
            // compactMap through returned records to
            // return only non-nil Hype records
            let fetchedHypes = records.compactMap {
                //for each returned record that is of type Hype
                (record) -> Hype? in
                //initialize a new Hype instance
                Hype(ckRecord: record)
            }
            
            self.hypes = fetchedHypes
            completion(true)
        }
    }
    
    func update(_ hype: Hype, completion: @escaping (_ success: Bool) -> Void) {
        let record = CKRecord(hype: hype)

        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)

        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (records, _, error) in

            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            
            // Unwrap the record that was updated and complete true
            guard let record = records?.first else { completion(false) ; return }
            print("Updated \(record.recordID) successfully in CloudKit")
            completion(true)
        }

        publicDB.add(operation)
    }
    
    func delete(_ hype: Hype, completion: @escaping (_ success: Bool) -> Void) {
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [hype.recordID])
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = {records, _, error in
            
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
            }
            
            if records?.count == 0 {
                print("Deleted record from CloudKit")
                completion(true)
            } else {
                print("Unexpected records were returned when trying to delete")
                completion(false)
            }
        }
        publicDB.add(operation)
    }
}
