//
//  KanbanCardViewModel.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 15/9/24.
//

import SwiftUI

@Observable
class KanbanCardViewModel {
    var task: KanbanTask
    let column: KanbanColumn.KanbanColumnType
    var dragOffset: CGSize = .zero
    var isDragging: Bool = false
    var progress: Double = 0.0
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let isAutoCompleteEnabled: Bool
    let activateFlagProbability: Bool

    init(
        task: KanbanTask,
        in column: KanbanColumn.KanbanColumnType,
        autoComplete: Bool = true,
        activateFlagProbability: Bool = false
    ) {
        self.task = task
        self.column = column
        self.isAutoCompleteEnabled = autoComplete
        self.activateFlagProbability = activateFlagProbability
    }
}

extension KanbanCardViewModel {
    func stopTimer() {
        self.timer.upstream.connect().cancel()
    }
}
