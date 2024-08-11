//
//  Debug.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 4/8/24.
//
import SwiftUI


extension View {
    func debug(_ color: Color? = nil) -> some View {
        modifier(Debug(color: color))
    }
}

struct Debug: ViewModifier {
    init(color: Color?) {
        self.color = color ?? .red
    }
    
    let color: Color

    func body(content: Content) -> some View {
            content.overlay {
                Rectangle().fill(.red.opacity(0.2))
            }
    }
}
