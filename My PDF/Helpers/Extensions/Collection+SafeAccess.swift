//
//  Collection+SafeAccess.swift
//  My PDF
//
//  Created by Эдвард on 12/8/25.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
