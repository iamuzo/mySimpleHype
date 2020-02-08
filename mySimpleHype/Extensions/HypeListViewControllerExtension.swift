//
//  HypeListViewControllerExtension.swift
//  mySimpleHype
//
//  Created by Uzo on 2/4/20.
//  Copyright © 2020 Uzo. All rights reserved.
//

import UIKit


extension HypeListViewController {

    func presentHypeAlert(for hype: Hype?) {
        let alertController = UIAlertController(
            title: "Get Hype!",
            message: "What is hype may never die",
            preferredStyle: .alert
        )
        
        alertController.addTextField { (textField) in
            textField.delegate = self as? UITextFieldDelegate
            textField.placeholder = "What is hype today?"
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .sentences
            if let hype = hype {
                textField.text = hype.body
            }
        }
        
        let addHypeAction = UIAlertAction(title: "Send", style: .default) { (_) in
            guard let text = alertController.textFields?.first?.text,
                !text.isEmpty
                else { return }
            
            if let hype = hype {
                hype.body = text
                HypeController.sharedGlobalInstance.update(hype) { (result) in
                    switch result {
                        case .success(_):
                            self.updateViews()
                        case .failure(let error):
                            
                            print(error)
                    }
                }
            } else {
                HypeController.sharedGlobalInstance.saveHype(with: text) { (result) in
                    switch result {
                        case .success(_):
                            self.updateViews()
                        case .failure(let error):
                            print(error)
                    }
                }
            }
        }
        
        alertController.addAction(addHypeAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
    }
}
