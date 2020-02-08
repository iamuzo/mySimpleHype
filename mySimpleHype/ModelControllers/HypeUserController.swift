//
//  HypeUserController.swift
//  mySimpleHype
//
//  Created by Uzo on 2/6/20.
//  Copyright © 2020 Uzo. All rights reserved.
//

import Foundation
import CloudKit

class HypeUserController {
    
    var currentUser: HypeUser?
    static let sharedInstance = HypeUserController()
    var publicDB = CKContainer.default().publicCloudDatabase
    
    private func fetchAppleUserReference(completion: @escaping (_ reference: CKRecord.Reference?) -> Void) {
        
        CKContainer.default().fetchUserRecordID { (ckRecordID, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) \n---\n \(error)")
                completion(nil)
            }
            
            if let ckRecordID = ckRecordID {
                let reference = CKRecord.Reference(recordID: ckRecordID, action: .deleteSelf)
                completion(reference)
            }
        }
    }
    
    func createUserWith(_ username: String, completion: @escaping (Result<HypeUser?, HypeUserError>) -> Void) {
        /**Fetch the AppleID User reference and handle User creation in the closure*/
        fetchAppleUserReference { (appleUserReference) in
            
            guard let appleUserReference = appleUserReference else {
                return completion(.failure(.appleUserNotLoggedIn))
            }
            
            let newHypeUser = HypeUser(username: username, appleUserRef: appleUserReference)
            
            let record = CKRecord(hypeUser: newHypeUser)
            
            self.publicDB.save(record) { (ckRecord, error) in
                if let error = error {
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    completion(.failure(.ckError(error)))
                }
                
                guard let ckRecord = ckRecord,
                    let savedHypeUser = HypeUser(ckRecord: ckRecord)
                    else {
                        return completion(.failure(.unableToUnWrapCKRecordObject))
                }
                
                //Duplication not needed as we return the current user
                //self.currentUser = savedHypeUser
                print("Created User: \(record.recordID.recordName) successfully")
                completion(.success(savedHypeUser))
            }
        }
    }
    
    /**
     get user if user is logged in?
     */
    func fetchUser(completion: @escaping (_ result: Result<HypeUser?, HypeUserError>) -> Void ) {
        
        fetchAppleUserReference { (ckRecordReference) in
            guard let ckRecordReference = ckRecordReference
                else { return completion(.failure(.appleUserNotLoggedIn)) }
            
            /**fetches a user object and compares it to the appleID that is fetched*/
            let predicate = NSPredicate(
                // compare K to supplied argument, which in this case is the ckRecordReference
                // key == suppliedArg
                format: "%K == %@",
                argumentArray: [HypeUserKeys.appleUserRefKey, ckRecordReference]
            )
            
            let query = CKQuery(recordType: HypeUserKeys.recordTypeKey, predicate: predicate)
            
            self.publicDB.perform(query, inZoneWith: nil) { (records, error) in
                
                if let error = error {
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    completion(.failure(.ckError(error)))
                    
                }
                
                //guard let record = records?.first,
                //    let foundUser = HypeUser(ckRecord: record)
                //    //i am not sure what type of error this is. What does it signify when a user is
                //    // either not found or a user cannot be initialized using the record found?
                //    else { return completion(.failure(.unexpectedRecordsFound))}
                //// Not needed as we are returning the current user
                //self.currentUser = foundUser
                //print("Fetched User: \(record.recordID.recordName) successfully")
                //completion(.success(self.currentUser))
                
                guard let record = records?.first,
                    let foundUser = HypeUser(ckRecord: record)
                    //i am not sure what type of error this is. What does it signify when a user is
                    // either not found or a user cannot be initialized using the record found?
                    else { return completion(.failure(.unexpectedRecordsFound))}
                
                // Not needed as we are returning the current user
                //self.currentUser = foundUser
                
                print("Fetched User: \(record.recordID.recordName) successfully")
                completion(.success(foundUser))
                
            }
        }
    }
    
    func updateUser(_ user: HypeUser, completion: @escaping (Result<HypeUser?, HypeUserError>) ->Void) {
    }
    
    func deleteUser() {}
    
}
