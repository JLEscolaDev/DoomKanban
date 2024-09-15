//
//  ContentView.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 1/8/24.
//

import SwiftUI

struct SprintsLayoutView: View {
    @Environment(KanbanAppVM.self) var kanbanVM
    @State private var localVM: SprintsViewModel = SprintsViewModel()
    @State private var lastVisibleItemIndex: Int? = nil

    var body: some View {
        @Bindable var kanbanVMBinding = kanbanVM
        GeometryReader { geometry in
            localVM.createSprintList(geometry: geometry, kanbanVM: $kanbanVMBinding)
        }.onChange(of: kanbanVM.round) {
            // When we start a new round, we re-init the localVM to avoid issues with previous data
            localVM = SprintsViewModel()
        }
    }
}

#Preview {
    SprintsLayoutView().frame(width: 150, height: 700)
        .environment(KanbanAppVM())
}
