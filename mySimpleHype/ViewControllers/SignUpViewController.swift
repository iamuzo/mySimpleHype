//
//  SignUpViewController.swift
//  mySimpleHype
//
//  Created by Uzo on 2/6/20.
//  Copyright © 2020 Uzo. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    // MARK: - OUTLETS
    @IBOutlet weak var usernameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser()
    }
    
    // MARK: - ACTIONS
    @IBAction func signupButtonTapped(_ sender: UIButton) {
        guard let username = usernameTextField.text, !username.isEmpty else {return}
        
        HypeUserController.sharedInstance.createUserWith(username) { (result) in
            switch result {
                case .success(let user):
                    HypeUserController.sharedInstance.currentUser = user
                    self.presentUserHypeListViewController()
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    func fetchUser() {
        HypeUserController.sharedInstance.fetchUser { (result) in
            switch result {
                case .success(let currentUser):
                    HypeUserController.sharedInstance.currentUser = currentUser
                    self.presentUserHypeListViewController()
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    func presentUserHypeListViewController() {
        // I can use this instead of prepare for segue
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "HypeList", bundle: nil)
            guard let viewController = storyboard.instantiateInitialViewController() else { return }
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true)
        }
    }
}
