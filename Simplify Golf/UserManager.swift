//
//  UserManager.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/13/24.
//

import Foundation
import CloudKit

class UserManager: ObservableObject {
    @Published var currentUser: CKRecord.ID?
    private let container: CKContainer
    
    init() {
        container = CKContainer(identifier: "iCloud.com.jaysondasher.Simplify-Golf")
        fetchUserRecord()
    }
    
    func fetchUserRecord() {
        container.fetchUserRecordID { (recordID, error) in
            DispatchQueue.main.async {
                if let recordID = recordID {
                    self.currentUser = recordID
                } else if let error = error {
                    print("Error fetching user record: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func isCurrentUser(_ userID: CKRecord.ID) -> Bool {
        return currentUser == userID
    }
    
    func getCurrentUserID() -> String {
        return currentUser?.recordName ?? ""
    }
}
