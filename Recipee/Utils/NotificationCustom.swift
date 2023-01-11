//
//  NotificationCustom.swift
//  Recipee
//
//  Created by Alex on 11/01/2023.
//

import UIKit

class NotificationCustom {
    static let shared = NotificationCustom()
    
    private var observers = [String: [NSNotification.Name: (() -> ())]]()
    
    private init(){}
    
    func addObserver(observer: Any, name: NSNotification.Name, completion: @escaping () -> ()) {
        let className = String(describing: type(of: observer))
        if let _ = self.observers[className] {
            self.observers[className]![name] = completion
        } else {
            self.observers[className] = [name: completion]
        }
    }
    
    func post(name: NSNotification.Name) {
        observers.forEach { notifications in
            notifications.value.forEach { notification in
                if notification.key == name {
                    notification.value()
                }
            }
        }
    }
}
