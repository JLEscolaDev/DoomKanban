//
//  mobileChatVisibility.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 21/8/24.
//

import SwiftUI

private struct MobileChatVisibilityKey: EnvironmentKey {
    static let defaultValue: Binding<(Visibility, KanbanTask?)> = .constant((.hidden,nil))
}

extension EnvironmentValues {
    var mobileChatVisibility: Binding<(Visibility, KanbanTask?)> {
    get { self[MobileChatVisibilityKey.self] }
    set { self[MobileChatVisibilityKey.self] = newValue }
  }
}

extension View {
    func mobileChatVisibility(_ isVisible: Binding<(Visibility, KanbanTask?)>) -> some View {
    environment(\.mobileChatVisibility, isVisible)
  }
}
