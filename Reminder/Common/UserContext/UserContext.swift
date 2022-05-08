//
//  UserContext.swift
//  Reminder
//
//  Created by linhnd99 on 23/04/2022.
//

import Foundation
import GoogleSignIn
import RxSwift
import RxCocoa

private struct Const {
    static let kUsername = "kUsername"
    static let kUserID = "kUserID"
    static let kFullname = "kFullname"
    static let kHashCode = "kHashCode"
}

protocol UserContext {
    var userID: String? { get }
    var username: String? { get }
    var fullname: String? { get }
    var profileImage: UIImage? { get }
    
    func loginApple(userID: String, username: String?, fullname: String?)
    func loginGoogle(user: GIDGoogleUser)
    func isLoggedIn() -> Bool
    func logout()
    func subscribeLoginState() -> Driver<Bool>
}

final class UserContextImpl {
    static var shared = UserContextImpl()
    private var loginStateSubject: BehaviorSubject<Bool>
    private var disposeBag = DisposeBag()
    
    var userID: String? {
        return UserDefaults.standard.string(forKey: Const.kUserID)
    }
    
    var fullname: String? {
        return UserDefaults.standard.string(forKey: Const.kFullname)
    }
    
    var username: String? {
        return UserDefaults.standard.string(forKey: Const.kUsername)
    }
    
    var profileImage: UIImage? {
        return UIImage(contentsOfFile: FileManager.profileImageURL().path) ?? UIImage(named: "ic_user-1")
    }
    
    init() {
        loginStateSubject = BehaviorSubject<Bool>(value: UserDefaults.standard.string(forKey: Const.kUserID) != nil)
    }
}

extension UserContextImpl: UserContext {
    func loginApple(userID: String, username: String?, fullname: String?) {
        UserDefaults.standard.set(userID, forKey: Const.kUserID)
        UserDefaults.standard.set(username ?? userID, forKey: Const.kUsername)
        UserDefaults.standard.set(fullname ?? userID, forKey: Const.kFullname)
        self.loginStateSubject.onNext(true)
    }
    
    func loginGoogle(user: GIDGoogleUser) {
        UserDefaults.standard.set(user.userID!, forKey: Const.kUserID)
        UserDefaults.standard.set(user.profile!.email, forKey: Const.kUsername)
        UserDefaults.standard.set(user.profile!.name, forKey: Const.kFullname)
        self.downloadProfileImage(user: user) {
            self.loginStateSubject.onNext(true)
        }
    }
    
    func isLoggedIn() -> Bool {
        return self.userID != nil
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: Const.kUserID)
        UserDefaults.standard.removeObject(forKey: Const.kUsername)
        UserDefaults.standard.removeObject(forKey: Const.kFullname)
        try? FileManager.default.removeItem(at: FileManager.profileImageURL())
        self.loginStateSubject.onNext(false)
    }
    
    func subscribeLoginState() -> Driver<Bool> {
        self.loginStateSubject.asDriver(onErrorJustReturn: false)
    }
    
    // MARK: - Helper
    private func downloadProfileImage(user: GIDGoogleUser, completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            if user.profile?.hasImage != true {
                completion()
                return
            }
            
            guard let imageProfileURL = user.profile?.imageURL(withDimension: 1024) else {
                print("Can not get image profile url")
                completion()
                return
            }
            
            guard let imageData = try? Data(contentsOf: imageProfileURL) else {
                print("Can not get image profile data")
                completion()
                return
            }
            
            if FileManager.default.fileExists(atPath: FileManager.profileImageURL().path) {
                try? FileManager.default.removeItem(at: FileManager.profileImageURL())
            }
            
            try? imageData.write(to: FileManager.profileImageURL())
            print("Save profile image successfully")
            completion()
        }
    }
}
