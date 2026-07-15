import Foundation
import SwiftUI

final class SessionStore: ObservableObject {
    static let shared = SessionStore()

    @Published var token: String?
    @Published var isSignedIn: Bool = false
    @Published var userId: String?

    private let tokenKey = "tracky_session_token"
    private let userIdKey = "tracky_user_id"

    init() {
        token     = UserDefaults.standard.string(forKey: tokenKey)
        userId    = UserDefaults.standard.string(forKey: userIdKey)
        isSignedIn = token != nil
    }

    func signIn(token: String, userId: String) {
        self.token     = token
        self.userId    = userId
        self.isSignedIn = true
        UserDefaults.standard.set(token,  forKey: tokenKey)
        UserDefaults.standard.set(userId, forKey: userIdKey)
    }

    func signOut() {
        token      = nil
        userId     = nil
        isSignedIn = false
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userIdKey)
    }
}
