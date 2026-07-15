import Foundation
import SwiftUI

final class SessionStore: ObservableObject {
    static let shared = SessionStore()

    @Published var token: String?
    @Published var isSignedIn: Bool = false
    @Published var userId: String?
    @Published var firstName: String?

    private let tokenKey = "tracky_session_token"
    private let userIdKey = "tracky_user_id"
    private let firstNameKey = "tracky_first_name"

    init() {
        token     = UserDefaults.standard.string(forKey: tokenKey)
        userId    = UserDefaults.standard.string(forKey: userIdKey)
        firstName = UserDefaults.standard.string(forKey: firstNameKey)
        isSignedIn = token != nil
    }

    func signIn(token: String, userId: String, firstName: String? = nil) {
        self.token     = token
        self.userId    = userId
        self.firstName = firstName
        self.isSignedIn = true
        UserDefaults.standard.set(token,  forKey: tokenKey)
        UserDefaults.standard.set(userId, forKey: userIdKey)
        UserDefaults.standard.set(firstName, forKey: firstNameKey)
    }

    func signOut() {
        token      = nil
        userId     = nil
        firstName  = nil
        isSignedIn = false
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userIdKey)
        UserDefaults.standard.removeObject(forKey: firstNameKey)
    }
}
