//
//  ErrorPresenter.swift
//  mySimpleHype
//
//  Created by Uzo on 2/4/20.
//  Copyright © 2020 Uzo. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func presentErrorToUser(localizedError: LocalizedError) {
        
        let alertController = UIAlertController(
            title: "Error",
            message: localizedError.errorDescription,
            preferredStyle: .actionSheet
        )
        
        let dismissAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(dismissAction)
        present(alertController, animated: true)
    }
}
