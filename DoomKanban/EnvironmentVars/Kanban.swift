//
//  EnvironmentVars.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 20/8/24.
//

import SwiftUI

private struct KanbanKey: EnvironmentKey {
    static let defaultValue: Binding<KanbanAppVM> = .constant(.init())
}

extension EnvironmentValues {
    var kanban: Binding<KanbanAppVM> {
    get { self[KanbanKey.self] }
    set { self[KanbanKey.self] = newValue }
  }
}

extension View {
  func kanbanVM(_ appVM: Binding<KanbanAppVM>) -> some View {
    environment(\.kanban, appVM)
  }
}