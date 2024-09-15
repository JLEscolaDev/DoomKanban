//
//  KanbanBoardVM.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 15/9/24.
//

import SwiftUI

@Observable
class KanbanBoardVM {
    var gameStatus: KanbanBoard.GameStatus = .notStarted
    var nextTaskPosition: CGPoint = .zero
    var draggedCard: KanbanTask?
    var dragOffset = CGSize.zero
    var isDragging = false
    var dropTarget = true
    var validDropTarget = true
    var animateNextTask = false
    @ObservationIgnored let secondsUntilGameStarts: Int = 3
    @ObservationIgnored let counter = 3
    var showNewRoundCountDown = true
}
