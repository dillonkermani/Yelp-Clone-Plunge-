//
//  UserViewModel.swift
//  Yelp Clone (Plunge)
//
//  Created by Dillon Kermani on 8/11/23.
//

import Foundation
import SwiftUI
import FirebaseAuth

class UserViewModel: ObservableObject {
    
    @Published var user: User = User( uid: "", firstName: "", lastName: "", email: "")
    @Published var initialized: Bool = false
    @Published var isLoading = false
    
    // Locally Updatable User Fields (Distinct from 'user' ^)
    @Published var uid: String = "" //maybe we want this so that we dont have to use
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    
    
    func refreshUser() {
        self.isLoading = true
        getUser(uid: self.uid) { user in
            self.setLocalVariablesWith(user: user)
            self.isLoading = false
        } onError: {
            print("Failed to refresh user")
            self.isLoading = false
        }

    }
       
    // Sets local @Published variables to passed in User fields.
    func setLocalVariablesWith(user : User) {
        self.user = user
        self.initialized = true
        
        self.uid = user.uid
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.email = user.email
    }
    
    // Deletes user from Firebase Auth but not from Firestore
    func deleteUserAccount () {
        let user = Auth.auth().currentUser

        user?.delete { error in
            if error != nil {
              print("unable to delete account")
            // An error happened.
          } else {
              print("user account deleted")
            // Account deleted.
          }
        }

    }

    func loadUser(uid: String) {
        isLoading = true
        let firestoreUserId = Ref.FIRESTORE_DOCUMENT_USERID(uid: uid)
        firestoreUserId.getDocument { (document, error) in
            if let dict = document?.data() {
                guard let decoderUser = try? User.init(from: dict as! Decoder) else { return }
                self.user = decoderUser
                self.isLoading = false
            }
        }
        
    }
    
    func getUser(uid: String, onSuccess: @escaping(_ user: User) -> Void, onError: @escaping() -> Void) {
        isLoading = true
        let firestoreUserId = Ref.FIRESTORE_DOCUMENT_USERID(uid: uid)
        firestoreUserId.getDocument { (document, error) in
            if let dict = document?.data() {
                guard let decoderUser = try? User.init(from: dict as! Decoder) else { return }
                self.user = decoderUser
                onSuccess(decoderUser)
                self.isLoading = false
            }
        }
        
    }
    
}
