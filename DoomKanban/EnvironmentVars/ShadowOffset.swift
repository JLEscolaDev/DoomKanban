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

struct ShadowOffsetKey: EnvironmentKey {
    static let defaultValue: Offset = Offset(x: 0, y: 0)
}

extension EnvironmentValues {
    var shadowOffset: Offset {
        get { self[ShadowOffsetKey.self] }
        set { self[ShadowOffsetKey.self] = newValue }
    }
}

extension View {
    func shadowOffset(_ offset: Offset) -> some View {
        environment(\.shadowOffset, offset)
    }
}
