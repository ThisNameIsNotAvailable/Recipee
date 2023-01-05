//
//  NSNotification+Utils.swift
//  Recipee
//
//  Created by Alex on 05/01/2023.
//

import Foundation

extension NSNotification.Name {
    static let showRefine = NSNotification.Name(rawValue: "Show Refine")
    static let hideRefine = NSNotification.Name(rawValue: "Hide Refine")
    static let updateCollectionView = NSNotification.Name(rawValue: "Update Collection View")
    static let updateTableView = NSNotification.Name(rawValue: "Update Table View")
    static let updateHeartButton = NSNotification.Name(rawValue: "Update Heart Button")
    static let updateListButton = NSNotification.Name(rawValue: "Update List Button")
}
