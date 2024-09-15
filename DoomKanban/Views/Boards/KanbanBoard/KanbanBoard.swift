//
//  KanbanBoard.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 3/8/24.
//

import SwiftUI
import Algorithms

extension KanbanBoard {
    enum GameStatus {
        case notStarted
        case playing
        case lost
        case won
    }
}

struct KanbanBoard: View {
    @State private var boardVM = KanbanBoardVM()
    @Environment(KanbanAppVM.self) var kanbanVM
    
    var body: some View {
        kanbanBoardOrScoreViewSaveScreen()
    }
    
    // - MARK: Subviews-NextTasks Countdown indicator
    @State private var countDownViewId = UUID()
    @State private var isViewA = true
    
    private func addCountDownView(geometry: GeometryProxy) -> some View {
        let nextKanbanCardSize = geometry.size.width / 5
        let minSize = min(geometry.size.width, geometry.size.height)
        let counterSize = minSize * 0.11
        
        return Group {
            // We create two Counters to "restart" the counter for the next card
            if isViewA {
                CountDownCircle(
                    count: boardVM.counter,
                    startOnAppear: true,
                    action: {
                        boardVM.animateNextTask = true
                        toggleView() // Cambia la vista cuando el contador llega a 0
                    }
                )
            } else {
                CountDownCircle(
                    count: boardVM.counter,
                    startOnAppear: true,
                    action: {
                        boardVM.animateNextTask = true
                        toggleView() // Cambia la vista cuando el contador llega a 0
                    }
                )
            }
        }
        .frame(width: counterSize, height: counterSize)
        .frame(depth: 1)
        .offset(x: nextKanbanCardSize / 2 - 15, y: -10)
    }
    
    /// Force redraw
    private func toggleView() {
        // Keep reseting the countDownView until there is only one card missing (we will use 2 instead of 1 because the timer executes one time more than we would expect because we are working with delayed animations and timers)
        if kanbanVM.mixedTasks.count >= 2 {
            isViewA.toggle()
        }
    }
}

// - MARK: Subviews-Main View
extension KanbanBoard {
    private func kanbanBoardOrScoreViewSaveScreen() -> some View {
        if boardVM.gameStatus == .lost || boardVM.gameStatus == .won {
            AnyView(SaveScoreView(points: kanbanVM.points))
        } else {
            AnyView(board())
        }
    }
    
    private func board() -> some View {
        GeometryReader { geometry in
            VStack {
                HStack(spacing: 0) {
                    nextTasks(geometry: geometry)
                    WarningsLayout(geometry: geometry)
                }
                .padding(.vertical, 10)
                .padding(.trailing, 10)
                Spacer()
                kanbanColumns(geometry: geometry)
            }
        }
            .overlay {
                if boardVM.showNewRoundCountDown {
                    RoundCountdownView(round: kanbanVM.round, countdown: boardVM.secondsUntilGameStarts) {
                        Task {
                            try await Task.sleep(nanoseconds: 1_000_000_000)
                            boardVM.showNewRoundCountDown.toggle()
                        }
                    }
                }
            }
            .onChange(of: kanbanVM.round) {
                boardVM.showNewRoundCountDown.toggle()
            }
            .onChange(of: kanbanVM.toDoTasks) {
                if warningsUpdate(from: kanbanVM.toDoTasks) {
                    // Clean tasks from column
                    kanbanVM.toDoTasks.removeAll()
                }
                checkNewRound()
            }.onChange(of: kanbanVM.inProgressTasks) {
                checkNewRound()
            }.onChange(of: kanbanVM.testingTasks) {
                checkNewRound()
            }.onChange(of: kanbanVM.doneTasks) {
                // full Done column should not trigger a warning. Just clean all tasks.
                checkDoneColumn()
                checkNewRound()
            }
            .onChange(of: kanbanVM.warningList) {
                warningControl()
            }
            .ornament(
                visibility: kanbanVM.chatVisibility.0,
                attachmentAnchor: .scene(.bottomFront),
                contentAlignment: .top
            ) {
                mobileChatOrnament()
            }
            .onChange(of: kanbanVM.mixedTasks) {_ , nextTasks in
                // Update gameStatus when round is finished to re-start the new round
                if nextTasks.isEmpty {
                    boardVM.gameStatus = .notStarted
                }
            }
            .onAppear {
                startRound()
            }

    }
}

// - MARK: Subviews-Next Tasks
extension KanbanBoard {
    private func nextTasks(geometry: GeometryProxy) -> some View {
        VStack(spacing: 5) {
            nextTasksTitle(geometry: geometry)
            nextTasksStack(geometry: geometry)
        }
        .padding(.leading, geometry.size.width * 0.025)
        .padding(.trailing, geometry.size.width * 0.025)
        .overlay {
            if boardVM.gameStatus == .playing {
                addCountDownView(geometry: geometry)
                    .opacity(kanbanVM.mixedTasks.isEmpty || boardVM.counter == 0 || !kanbanVM.showNextTaskCounterView ? 0 : 1)
                    .allowsHitTesting(false) // Disable user interaction so the user can drag and drop the card
            }
        }
    }
    
    private func nextTasksTitle(geometry: GeometryProxy) -> some View {
        ZStack {
            Text("Next task")
                .foregroundStyle(.black)
                .bold()
                .font(.system(size: geometry.size.height * 0.04))
        }
    }
    
    private func nextTasksStack(geometry: GeometryProxy) -> some View {
        let kanbanCardWidth = geometry.size.width / 5
        let kanbanCardHeight = geometry.size.height * 0.13
        let kanbanCardInitialPosition = CGPoint(x: kanbanCardWidth / 2, y: geometry.size.height * 0.055)  // Centra la tarjeta horizontalmente en su contenedor
        let kanbanCardFinalYPosition = kanbanCardInitialPosition.y + kanbanCardHeight * CGFloat((4-kanbanVM.toDoTasks.count)) + geometry.size.height*0.18
        
        return ZStack {
            if kanbanVM.mixedTasks.count > 1 {
                nextTasksBottomCard(
                    for: kanbanVM.mixedTasks[1],
                    geometry: geometry,
                    kanbanCardWidth: kanbanCardWidth,
                    kanbanCardInitialYPosition: kanbanCardInitialPosition.y
                )
            }
            
            if let card = kanbanVM.mixedTasks.first {
                nextTasksTopCard(
                    for: card,
                    geometry: geometry,
                    kanbanCardHeight: kanbanCardHeight,
                    kanbanCardInitialPosition: kanbanCardInitialPosition
                )
            }
        }.padding(.leading, geometry.size.width * 0.01)
            .frame(width: kanbanCardWidth, height: kanbanCardHeight)
            .padding(.top, 15)
            .onChange(of: boardVM.animateNextTask) {_, newValue in
                if newValue == true {
                    withAnimation(.easeInOut(duration: TimeInterval(kanbanVM.nextTaskAnimationTime))) {
                        var finalPosition = kanbanCardInitialPosition
                        finalPosition.y = kanbanCardFinalYPosition
                        boardVM.nextTaskPosition = finalPosition
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(kanbanVM.nextTaskAnimationTime)) {
                        boardVM.animateNextTask = false
                    }
                } else {
                    
                    DispatchQueue.main.async {
                        if let task = kanbanVM.mixedTasks.first {
                            kanbanVM.add(task, to: .ToDo)
                            kanbanVM.mixedTasks.removeFirst()
                        }
                        boardVM.nextTaskPosition = kanbanCardInitialPosition
                    }
                }
            }
    }
    
    private func nextTasksBottomCard(for task: KanbanTask, geometry: GeometryProxy, kanbanCardWidth: CGFloat, kanbanCardInitialYPosition: CGFloat) -> some View {
        KanbanCard(task: task)
            .frame(depth: 30)
            .background {
                VStack {
                    Spacer()
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .black.opacity(0.4), location: 0.52),
                            .init(color: .gray.opacity(0.8), location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(width: geometry.size.width / 7, height: geometry.size.height * 0.07)
                    .shadow(color: .black, radius: 2, y: geometry.size.height * 0.06)
                    Spacer()
                }
            }
            .position(x: kanbanCardWidth / 2, y: kanbanCardInitialYPosition)  // Calcula la posición horizontal dinámica
    }
    
    private func nextTasksTopCard(for task: KanbanTask, geometry: GeometryProxy, kanbanCardHeight: CGFloat, kanbanCardInitialPosition: CGPoint) -> some View {
        KanbanCard(task: task)
            .frame(depth: 1)
            .shadow(color: .black.opacity(0.7), radius: 2, x: 0, y: kanbanCardHeight*0.2)
            .position(boardVM.nextTaskPosition)
            .offset(boardVM.draggedCard == task && boardVM.isDragging ? boardVM.dragOffset : .zero)
            .onAppear {
                boardVM.nextTaskPosition = kanbanCardInitialPosition
            }
            .onChange(of: geometry.size) { oldSize, newSize in
                let newKanbanCardWidth = newSize.width / 5
                boardVM.nextTaskPosition = CGPoint(x: newKanbanCardWidth / 2, y: geometry.size.height * 0.055)
            }
            .hoverEffect(.highlight)
    }
}

// - MARK: Subviews-Columns
extension KanbanBoard {
    private func kanbanColumns(geometry: GeometryProxy) -> some View {
        ZStack {
            HStack(spacing: 0) {
                KanbanColumn(columnType: .ToDo, title: "To Do", headerColor: .red, geometry: geometry)
                    .zIndex(boardVM.draggedCard != nil && kanbanVM.toDoTasks.contains(boardVM.draggedCard!) ? 5 : 1)
                
                KanbanColumn(columnType: .Doing, title: "Doing", headerColor: .cyan, geometry: geometry)
                    .zIndex(boardVM.draggedCard != nil && kanbanVM.inProgressTasks.contains(boardVM.draggedCard!) ? 5 : 1)
                
                KanbanColumn(columnType: .Testing, title: "Testing", headerColor: .blue, geometry: geometry)
                    .zIndex(boardVM.draggedCard != nil && kanbanVM.testingTasks.contains(boardVM.draggedCard!) ? 5 : 1)
                
                KanbanColumn(columnType: .Done, title: "Done", headerColor: .green, geometry: geometry)
                    .zIndex(boardVM.draggedCard != nil && kanbanVM.doneTasks.contains(boardVM.draggedCard!) ? 5 : 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 25.0))
            KanbanBoardShape()
                .foregroundStyle(.black)
        }
        .background {
            RoundedRectangle(cornerRadius: 25.0)
                .fill(.white.opacity(0.8))
        }
        .frame(height: geometry.size.height * 0.75)
    }
}

// - MARK: Subviews-Fake Chat ornament
extension KanbanBoard {
    private func mobileChatOrnament() -> some View {
        FakeMobileChat() {
            if let flaggedTask = kanbanVM.chatVisibility.1 {
                // Busca y actualiza la tarea en la columna "To Do"
                if let index = kanbanVM.toDoTasks.firstIndex(where: { $0.id == flaggedTask.id }) {
                    kanbanVM.toDoTasks[index].isFlagged = false
                    
                    //                        toDoTasks[index].isComplete = true
                }
                // Busca y actualiza la tarea en la columna "In Progress"
                else if let index = kanbanVM.inProgressTasks.firstIndex(where: { $0.id == flaggedTask.id }) {
                    kanbanVM.inProgressTasks[index].isFlagged = false
                    print(kanbanVM.inProgressTasks[index].isFlagged)
                    //                        inProgressTasks[index].isComplete = true
                }
                // Busca y actualiza la tarea en la columna "Testing"
                else if let index = kanbanVM.testingTasks.firstIndex(where: { $0.id == flaggedTask.id }) {
                    kanbanVM.testingTasks[index].isFlagged = false
                    print(kanbanVM.testingTasks[index].isFlagged)
                    //                        testingTasks[index].isComplete = true
                }
            }
        }
        .labelStyle(.iconOnly)
        .padding(.vertical)
        .frame(width: 150, height: 400)
        .rotation3DEffect(.degrees(25), axis: (x: 1, y: 0, z: 0))
        .offset(z: 100)
        .offset(y: -80)
    }
}

// - MARK: Board states control
extension KanbanBoard {
    private func warningControl() {
        for project in kanbanVM.warningList {
            // Player looses if he gets 3 warnings in the same project
            if project.numberOfWarnings >= 3 {
                boardVM.gameStatus = .lost
            }
            // Verify if there are still tasks from the same project. If there are no more cards, we clean the warnings (it's not posible any more to lose for that warnings)
            if !kanbanVM.mixedTasks.contains(where: { $0.projectId == project.id }),
               !kanbanVM.toDoTasks.contains(where: { $0.projectId == project.id }),
               !kanbanVM.inProgressTasks.contains(where: { $0.projectId == project.id }),
               !kanbanVM.testingTasks.contains(where: { $0.projectId == project.id }) {
                kanbanVM.warningList.remove(id: project.id)
            }
        }
    }
    
    private func checkNewRound() {
        if kanbanVM.mixedTasks.isEmpty,
           kanbanVM.toDoTasks.isEmpty,
           kanbanVM.inProgressTasks.isEmpty,
           kanbanVM.testingTasks.isEmpty {
            // We check this here because it can be an extreme case where there is one task left on the kanban board, you have 2 warnings and you fail that task. At that point, it should trigger a loss due to the three warnings, but the startNewRound clears everything before view refreshes and will save you from losing the game.
            warningControl()
            kanbanVM.startNewRound()
            startRound()
        }
    }
    
    private func checkDoneColumn() {
        // Clean Done column when it's full
        if kanbanVM.doneTasks.count == 4 {
            kanbanVM.doneTasks.removeAll()
        }
        // Clean Done column when the game has finished and there are only tasks on Done
        else if kanbanVM.mixedTasks.isEmpty,
                kanbanVM.toDoTasks.isEmpty,
                kanbanVM.inProgressTasks.isEmpty,
                kanbanVM.testingTasks.isEmpty,
                !kanbanVM.doneTasks.isEmpty {
            kanbanVM.doneTasks.removeAll()
        }
    }
    
    private func startRound() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(boardVM.secondsUntilGameStarts)) {
            boardVM.gameStatus = .playing
        }
    }
    
    @MainActor
    private func warningsUpdate(from column: [KanbanTask]) -> Bool {
        if column.count > 4 {
            if let task = column.last {
                kanbanVM.addWarning(causedBy: task)
                if kanbanVM.warningList.count >= 3 {
                    boardVM.gameStatus = .lost
                }
            }
            return true
        }
        return false
    }
}

#Preview(windowStyle: .plain) {
    KanbanBoard().frame(width: 700, height: 700)
        .environment(KanbanAppVM())
}
