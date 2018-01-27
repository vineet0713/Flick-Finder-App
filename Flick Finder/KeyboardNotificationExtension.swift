//
//  KeyboardNotificationExtension.swift
//  Flick Finder
//
//  Created by Vineet Joshi on 1/27/18.
//  Copyright © 2018 Vineet Joshi. All rights reserved.
//

import Foundation
import UIKit

extension ViewController {
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        // '.UIKeyboardWillShow' is shortened version of 'Notification.Name.UIKeyboardWillShow'
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        // moves the View up by the height of the keyboard: (so the keyboard won't cover up the content!)
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y = self.getKeyboardHeight(notification) * -1
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        // moves the View up by the height of the keyboard: (so the keyboard won't cover up the content!)
        self.view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        // Notifications carry information in the 'userInfo' Dictionary
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue  // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        // '.UIKeyboardWillShow' is shortened version of 'Notification.Name.UIKeyboardWillShow'
    }
}
