//
//  DoomKanbanLayout.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 3/8/24.
//

import SwiftUI

struct DoomKanbanLayout: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    var body: some View {
        KanbanBoard()
        .onAppear {
            openWindow(id: "RunningSprints")
            openWindow(id: "SkillsView")
            Task {
                await openImmersiveSpace(id: "Points")
            }
        }
    }
}

#Preview {
    DoomKanbanLayout()
}
