//
//  RandomValues.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 23/8/24.
//

import SwiftUI

extension Bool {
    static func random(with percentChance: Float ) -> Bool {
        return Float(Int.random(in: 1...100)) <= percentChance
    }
}
