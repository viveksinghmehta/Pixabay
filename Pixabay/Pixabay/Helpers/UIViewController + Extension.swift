//
//  UIViewController + Extension.swift
//  Pixabay
//
//  Created by WishACloud on 11/02/21.
//

import UIKit
import Foundation


extension UIViewController {
    
    func showAlert(title: String?, msg: String?) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}
