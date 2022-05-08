//
//  AccountViewController.swift
//  Reminder
//
//  Created by linhnd99 on 23/04/2022.
//

import UIKit

private struct Const {
    static let kHashCode = "kHashCode"
}

protocol AccountViewControllerDelegate: AnyObject {
    func accountViewControllerDidEndPullData(_ viewController: AccountViewController)
}

class AccountViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var topContentViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var pullingStateLabel: UILabel!
    @IBOutlet private weak var pullingStateView: UIView!
    
    var delegate: AccountViewControllerDelegate?
    var topContentViewConstant: CGFloat = 110
    private lazy var userContext: UserContext = {
        return DIContainer.shared.resolve(UserContext.self)
    }()
    
    private lazy var cloudManager: CloudDatabaseManager = {
        return DIContainer.shared.resolve(CloudDatabaseManager.self)
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadDataState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.animateShowing()
    }
    
    // MARK: - Config
    private func config() {
        self.loadData()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(backgroundViewDidTap))
        self.backgroundView.addGestureRecognizer(gesture)
        
        self.animateDismissing(animated: false)
        
        self.pullingStateView.isHidden = true
    }
    
    private func loadData() {
        self.avatarImageView.image = self.userContext.profileImage
        self.nameLabel.text = self.userContext.fullname ?? ""
        self.usernameLabel.text = self.userContext.username ?? ""
    }
    
    // MARK: - Action
    @IBAction func backupButtonDidTap(_ sender: Any) {
        guard let userID = self.userContext.userID else {
            return
        }
        
        self.animateDismissing(animated: true) {
            self.dismiss(animated: false)
            print("start backup")
            LoadingHUD.show()
            self.cloudManager.backup(userId: userID) { error in
                print("end backup")
                LoadingHUD.dismiss()
                self.handleError(error, prefixNotification: "Backup")
            }
        }
    }
    
    @IBAction func pullFromServerButtonDidTap(_ sender: Any) {
        guard let userID = self.userContext.userID else {
            return
        }
        
        self.animateDismissing(animated: true) {
            self.dismiss(animated: false)
            print("start pull")
            LoadingHUD.show()
            self.cloudManager.pull(userId: userID) { error in
                print("end pull")
                LoadingHUD.dismiss()
                self.handleError(error, prefixNotification: "Pull data from server")
                if error == nil {
                    self.delegate?.accountViewControllerDidEndPullData(self)
                }
            }
        }
    }
    
    @IBAction func logoutButtonDidTap(_ sender: Any) {
        self.userContext.logout()
        self.animateDismissing(animated: true) {
            self.dismiss(animated: false)
        }
    }
    
    @objc private func backgroundViewDidTap() {
        self.animateDismissing(animated: true) {
            self.dismiss(animated: false)
        }
    }
    
    // MARK: - Helper
    private func animateShowing() {
        UIView.animate(withDuration: 0.25) {
            self.backgroundView.alpha = 0.5
            self.topContentViewConstraint.constant = self.topContentViewConstant
            self.view.layoutIfNeeded()
        }
    }
    
    func animateDismissing(animated: Bool, completion: (() -> Void)? = nil) {
        let block = {
            self.backgroundView.alpha = 0
            self.topContentViewConstraint.constant = -600
            self.view.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: 0.25, animations: block) { _ in
                completion?()
            }
        } else {
            block()
            completion?()
        }
    }
    
    private func handleError(_ error: Error?, prefixNotification: String) {
        if let error = error {
            NotificationBannerView.show("Something went wrong", mode: .dark, icon: .warning, duration: 3)
            print(error)
        } else {
            NotificationBannerView.show("\(prefixNotification) successfully", mode: .dark, icon: .success, duration: 3)
        }
    }
    
    private func reloadDataState() {
        if let userId = self.userContext.userID {
            self.cloudManager.getHashCode(userId: userId) { [weak self] hashCode, error in
                guard let self = self else {
                    return
                }
                
                if error != nil {
                    return
                }
                
                self.pullingStateView.isHidden = false
                if UserDefaults.standard.string(forKey: Const.kHashCode) == hashCode {
                    self.pullingStateLabel.text = "Newest"
                    self.pullingStateView.backgroundColor = UIColor(rgb: 0x009688)
                } else {
                    self.pullingStateLabel.text = "Old"
                    self.pullingStateView.backgroundColor = UIColor(rgb: 0xE9B189)
                }
            }
        }
    }
}
