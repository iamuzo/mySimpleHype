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
    
    // MARK: - PROPERTIES
    var hypes: [Hype] = []
    static let sharedGlobalInstance = HypeController()
    
    /**
     Hype inmitates a social media platform where user
     created `Hype` instances are public. Hence use public DB
     */
    let publicDB = CKContainer.default().publicCloudDatabase
    
    func saveHype(with body: String, completion: @escaping (Result<Hype?, HypeError>) -> Void) {
        
        guard let currentUser = HypeUserController.sharedInstance.currentUser else {
            return completion(.failure(.noUserLoggedIn))
        }
        
        let reference = CKRecord.Reference(recordID: currentUser.recordID, action: .none)
        
        let newHypeInstance = Hype(body: body, userReference: reference)
        
        let hypeRecord = CKRecord(hype: newHypeInstance)
        
        publicDB.save(hypeRecord) { (ckrecordOptional, error) in
            
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.ckError(error)))
            }
            
            //saved record is an optional thus we need to unwrap it
            guard let record = ckrecordOptional,
                let savedHypeRecord = Hype(ckRecord: record)
                /**if we can't unwrap, completion is false thus
                 and we return/jump out from the function
                 */
                else { return completion(.failure(.unableToUnWrapCKRecordObject)) }

            //Insert the successfully saved Hype object
            //at the first index of our Source of Truth array
            self.hypes.insert(savedHypeRecord, at: 0)

            return completion(.success(savedHypeRecord))
        }
    }
    
    func fetch(completion: @escaping (Result<[Hype], HypeError>) -> Void ) {
        
        /**a predicate is a way to set rules for what
         information we want back. In this case we
         we want all Hype Records so we say if a
         */
        let queryAllPredicate = NSPredicate(value: true)
        
        let query = CKQuery(
            recordType: HypeKeys.recordTypeKey,
            predicate: queryAllPredicate
        )
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.ckError(error)))
            }
            
            guard let records = records
                else {return completion(.failure(.unableToUnWrapCKRecordObject))}

            // compactMap through returned records to
            // return only non-nil Hype records
            let fetchedHypes = records.compactMap {
                //for each returned record that is of type Hype
                (record) -> Hype? in
                //initialize a new Hype instance
                Hype(ckRecord: record)
            }
            
            self.hypes = fetchedHypes
            completion(.success(self.hypes))
            
        }
    }

    func update(_ hype: Hype, completion: @escaping (Result<Hype?, HypeError>) ->Void) {
        
        //users can only edit their own hypes
        guard hype.userReference?.recordID == HypeUserController.sharedInstance.currentUser?.recordID
            else { return completion(.failure(.unexpectedRecordsFound))}
        
        let record = CKRecord(hype: hype)
        
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        
        /**
         savePolicy determines what needs to be saved during the operation.
         if the values changed from what is on cloudkit, change that value else
         do not change the value. Basically, when saving things only change
         things that have changed.
         */
        operation.savePolicy = .changedKeys
        
        
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (records, _, error) in
            
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = records?.first,
                let updatedHype = Hype(ckRecord: record)
                else {return completion(.failure(.unableToUnWrapCKRecordObject))}
            completion(.success(updatedHype))
        }
        publicDB.add(operation)
    }
    
    /**UPDATED VERSION*/
    func delete(_ hype: Hype, completion: @escaping (Result<Bool, HypeError>) ->Void) {
        
        //users can only delete their own hypes
        guard hype.userReference?.recordID == HypeUserController.sharedInstance.currentUser?.recordID
            else { return completion(.failure(.unexpectedRecordsFound))}
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [hype.recordID])
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        
        operation.modifyRecordsCompletionBlock = {records, _, error in
            
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.ckError(error)))
            }
            
            if records?.count == 0 {
                print("Deleted record from CloudKit")
                return completion(.success(true))
            } else {
                print("Unable to delete record")
                return completion(.failure(.unexpectedRecordsFound))
            }
        }
        publicDB.add(operation)
    }
    
    // trigger notifications
    func subscribeForRemoteNotifications(completion: @escaping (_ error: Error?) -> Void) {
        let predicate = NSPredicate(value: true)
        
        /**create subscriptions; since predicate is true,
         it gets the notifications for ALL Hype record types
         */
        let subscription = CKQuerySubscription(
            recordType: HypeKeys.recordTypeKey,
            predicate: predicate,
            options: .firesOnRecordCreation
        )
        
        /**create a notification and set its properties */
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "Something"
        notificationInfo.alertBody = "What goes here"
        notificationInfo.shouldBadge = true
        notificationInfo.soundName = "default"
        
        /** access subscription and assign its nofification info*/
        subscription.notificationInfo = notificationInfo
        
        /**save subscription to database so that database
         can push notifications to all devices that are
         subscribed to that notification */
        publicDB.save(subscription) { (_, error) in
            if let error = error {
                completion(error)
            }
            
            //if no error, then assume it is successful
            completion(nil)
        }
    }
}
