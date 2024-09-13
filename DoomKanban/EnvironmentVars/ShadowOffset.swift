//
//  EnvironmentVars.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 20/8/24.
//

import SwiftUI

@Observable
class Offset {
    init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }
    
    let x: CGFloat
    let y: CGFloat
}

// Default value
extension EnvironmentValues {
    @Entry var shadowOffset: Offset = .init(x: 0, y: 0)
}

extension View {
    func shadowOffset(_ offset: Offset) -> some View {
        environment(offset)
    }
}
