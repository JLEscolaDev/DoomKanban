//
//  mobileChatVisibility.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 21/8/24.
//

//import SwiftUI
//
//private struct MobileChatVisibilityKey: EnvironmentKey {
//    static let defaultValue: Binding<(Visibility, KanbanTask?)> = .constant((.hidden,nil))
//}
//
//extension EnvironmentValues {
//    var mobileChatVisibility: Binding<(Visibility, KanbanTask?)> {
//    get { self[MobileChatVisibilityKey.self] }
//    set { self[MobileChatVisibilityKey.self] = newValue }
//  }
//}
//
//extension View {
//    func mobileChatVisibility(_ isVisible: Binding<(Visibility, KanbanTask?)>) -> some View {
//    environment(\.mobileChatVisibility, isVisible)
//  }
//}

import SwiftUI

struct SecondaryColorKey: EnvironmentKey {
    static let defaultValue: Color = .clear
}

extension EnvironmentValues {
    var secondaryColor: Color {
        get { self[SecondaryColorKey.self] }
        set { self[SecondaryColorKey.self] = newValue }
    }
}

struct SecondaryColorModifier: ViewModifier {
    var color: Color

    func body(content: Content) -> some View {
        content
            .environment(\.secondaryColor, color)
    }
}

extension View {
    func secondaryColor(_ color: Color) -> some View {
        self.modifier(SecondaryColorModifier(color: color))
    }
}
