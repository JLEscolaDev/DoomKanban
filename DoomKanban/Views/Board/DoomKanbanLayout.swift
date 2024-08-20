//
//  DoomKanbanLayout.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 3/8/24.
//

import SwiftUI

struct DoomKanbanLayout: View {
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        KanbanBoard()
        .onAppear {
            openWindow(id: "RunningSprints")
            openWindow(id: "SkillsView")
        }
    }
}

#Preview {
    DoomKanbanLayout()
}
