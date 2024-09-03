//
//  KanbanBoard.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 3/8/24.
//

import SwiftUI
import Algorithms

@Observable
class KanbanBoardVM: ObservableObject {
    var gameStatus: KanbanBoard.GameStatus = .notStarted
    var nextTaskPosition: CGPoint = .zero
    var draggedCard: KanbanTask?
    var dragOffset = CGSize.zero
    var isDragging = false
    var dropTarget = true
    var validDropTarget = true
    var animateNextTask = false
    var warningList: [WarningsInfo] = []
    
    var isChatVisible: (Visibility, KanbanTask?) = (.hidden, nil)
}

struct KanbanBoard: View {
    enum GameStatus {
        case notStarted
        case playing
        case lost
        case won
    }
    @State private var boardVM = KanbanBoardVM()
//    @State var gameStatus = GameStatus.notStarted
    let secondsUntilGameStarts: CGFloat = 2
//    @State private var nextTaskPosition: CGPoint = .zero
//    @State private var draggedCard: KanbanTask?
//    @State private var dragOffset = CGSize.zero
//    @State private var isDragging = false
//    @State private var dropTarget = true
//    @State private var validDropTarget = true
//    @State private var cardDragStatus: DragStatus = .outOfBounds
    
//    private let nextTaskAnimationTime: Int = 2
//    @State private var animateNextTask: Bool = false
    private let counter = 3
//    estoy cambiando de las nextTasks (que eran mixedTasks heredadas como environment) a pasar el kanbanVM entero que tiene las mixedTasks y los sprints. Tengo que comprobar si al modificar mixedTasks se modifica también sprints o tengo que hacer alguna comprobación de a qué sprint pertenece la tarea para luego modificar sprints
//    @State var nextCards: [KanbanTask]
    @Environment(\.kanban) private var kanbanVM
    
//    @State private var isChatVisible: (Visibility, KanbanTask?) = (.hidden, nil)
//    private var nextCards: [KanbanTask] {
//        kanbanVM.mixedTasks
//    }
    /// [projectId: (numberOfWarnings, projectColor)]
//    @State private var warningList: [WarningsInfo] = []
    
//    @State private var toDoTasks: [KanbanTask] = []
//    @State private var inProgressTasks: [KanbanTask] = []
//    @State private var testingTasks: [KanbanTask] = []
//    @State private var doneTasks: [KanbanTask] = []

    private func warningControl() {
        for project in boardVM.warningList {
            // Player looses if he gets 3 warnings in the same project
            if project.numberOfWarnings >= 3 {
                boardVM.gameStatus = .lost
                print("GAME LOST")
            }
            // Verify if there are still tasks from the same project. If there are no more cards, we clean the warnings (it's not posible any more to lose for that warnings)
            if !kanbanVM.mixedTasks.contains(where: { $0.projectId == project.id }) {
                boardVM.warningList.remove(id: project.id)
            }
        }
    }
    
    var body: some View {
//        @Bindable var vm = kanbanVM
//        print("😬\(kanbanVM.toDoTasks.count)")
        return GeometryReader { geometry in
            VStack {
                HStack(spacing: 0) {
                    VStack(spacing: 5) {
                        ZStack {
                            Text("Next task")
                                .foregroundStyle(.black)
                                .bold()
                                .font(.system(size: geometry.size.height * 0.04))
                        }

                        let kanbanCardWidth = geometry.size.width / 5
                        let kanbanCardHeight = geometry.size.height * 0.13
                        let kanbanCardInitialPosition = CGPoint(x: kanbanCardWidth / 2, y: geometry.size.height * 0.055)  // Centra la tarjeta horizontalmente en su contenedor
                        let kanbanCardFinalYPosition = kanbanCardInitialPosition.y + kanbanCardHeight * CGFloat((4-kanbanVM.toDoTasks.count)) + geometry.size.height*0.18

                        ZStack {
                            if kanbanVM.mixedTasks.count > 1 {
                                KanbanCard(task: kanbanVM.mixedTasks[1])
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
                                    .position(x: kanbanCardWidth / 2, y: kanbanCardInitialPosition.y)  // Calcula la posición horizontal dinámica
                            }

                            if let card = kanbanVM.mixedTasks.first {
                                KanbanCard(task: card)
                                    .frame(depth: 1)
                                    .shadow(color: .black.opacity(0.7), radius: 2, x: 0, y: kanbanCardHeight*0.2)
                                    .position(boardVM.nextTaskPosition)
                                    .offset(boardVM.draggedCard == card && boardVM.isDragging ? boardVM.dragOffset : .zero)
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                if boardVM.draggedCard == nil {
                                                    boardVM.draggedCard = card
                                                    boardVM.isDragging = true
                                                }
                                                boardVM.dragOffset = value.translation

                                                // Actualiza la posición global ajustada con el offset del arrastre
                                                let globalPosition = CGPoint(
                                                    x: boardVM.nextTaskPosition.x + boardVM.dragOffset.width,
                                                    y: boardVM.nextTaskPosition.y + boardVM.dragOffset.height
                                                )

                                                // Detecta si el drop sería válido o no usando la posición global
                                                if isInDropArea(location: globalPosition, geometry: geometry) {
                                                    boardVM.dropTarget = true
                                                } else {
                                                    boardVM.dropTarget = false
                                                }

                                                if isInValidDropArea(location: globalPosition, geometry: geometry) {
                                                    boardVM.validDropTarget = true
                                                } else {
                                                    boardVM.validDropTarget = false
                                                }
                                            }
                                            .onEnded { value in
                                                let globalPosition = CGPoint(
                                                    x: boardVM.nextTaskPosition.x + boardVM.dragOffset.width,
                                                    y: boardVM.nextTaskPosition.y + boardVM.dragOffset.height
                                                )

//                                                handleDrop(of: card, from: kanbanVM.mixedTasks, in: globalPosition, ofSize: geometry)
                                                boardVM.draggedCard = nil
                                                boardVM.dragOffset = .zero
                                                boardVM.isDragging = false
                                            }
                                    )
                                    .onAppear {
                                        boardVM.nextTaskPosition = kanbanCardInitialPosition
                                        animateNextTasksSequentially()
                                    }
                                    .onChange(of: geometry.size) { oldSize, newSize in
                                        let newKanbanCardWidth = newSize.width / 5
                                        boardVM.nextTaskPosition = CGPoint(x: newKanbanCardWidth / 2, y: geometry.size.height * 0.055)
                                    }
                                    .hoverEffect(.highlight)
                            }
                        }.padding(.leading, geometry.size.width * 0.01)
                        .frame(width: kanbanCardWidth, height: kanbanCardHeight)
                        .padding(.top, 15)
                        .onChange(of: boardVM.animateNextTask) {_, newValue in
//                            print("ANIMATE")
                            if newValue == true {
//                                print(newValue)
                                withAnimation(.easeInOut(duration: TimeInterval(kanbanVM.nextTaskAnimationTime))) {
                                    var finalPosition = kanbanCardInitialPosition
                                    finalPosition.y = kanbanCardFinalYPosition
                                    boardVM.nextTaskPosition = finalPosition
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + Double(kanbanVM.nextTaskAnimationTime)) {
                                    boardVM.animateNextTask = false
                                }
                            } else {
//                                print("ENTRA")
                                
                                DispatchQueue.main.async {
                                    if let task = kanbanVM.mixedTasks.first {
                                        kanbanVM.add(task, to: .ToDo)
                                        // We cannot remove from computedProperty nextTasks
                                        //                                    print("se va a eliminar:  \(vm.wrappedValue.count)")
                                        kanbanVM.mixedTasks.removeFirst()
                                        //                                    print("se ha eliminado:  \(tasks.wrappedValue.count)")
                                    }
                                    //                                print("SALE")
                                    boardVM.nextTaskPosition = kanbanCardInitialPosition
                                }
                            }
                        }
                    }
                    .padding(.leading, geometry.size.width * 0.025)
                    .padding(.trailing, geometry.size.width * 0.025)
                    .overlay {
                        if boardVM.gameStatus == .playing {
                            addCountDownView(geometry: geometry)
                                .opacity(kanbanVM.mixedTasks.isEmpty || counter == 0 ? 0 : 1)
                                .allowsHitTesting(false) // Disable user interaction so the user can drag and drop the card
                        }
                    }
                    
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.white)
                        .stroke(.black.opacity(0.5), lineWidth: 2)
                        .overlay {
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Text("Warnings")
                                        .font(.system(size: geometry.size.height * 0.05))
                                        .bold()
                                        .foregroundStyle(.black)
                                    
                                    Spacer()
                                    WardenEye()
                                        .foregroundStyle(.red)
                                        .tint(.black)
                                        .frame(width: geometry.size.height * 0.06, height: geometry.size.height * 0.06)
                                        .padding(.trailing, geometry.size.width * 0.02)
                                        .frame(depth: 5)
                                        .opacity(kanbanVM.wardenIsWatching ? 1 : 0)
                                }.padding(.top, 30)
                                RoundedRectangle(cornerRadius: geometry.size.height * 0.05)
                                    .fill(.black)
                                    .frame(height: geometry.size.height * 0.001)
                                HStack {
                                    // Assume `warningList` is an array of `WarningsInfo`
                                    let warningStacks: [AnyView] = boardVM.warningList.compactMap { warningInfo in
                                        let triangles: [AnyView] = (0..<warningInfo.numberOfWarnings).map { _ in
                                            AnyView(
                                                WarningTriangle(image: Image(.shout))
                                                    .accentColor(warningInfo.projectColor.lighter())
                                                    .foregroundStyle(warningInfo.projectColor)
                                                    .tint(warningInfo.projectColor)
                                                    .frame(depth: 2)
                                            )
                                        }

                                        if !triangles.isEmpty {
                                            return AnyView(
                                                WarningStack(warnings: triangles, offset: geometry.size.width * 0.025)
                                                    .frame(width: geometry.size.width * 0.13, height: geometry.size.height * 0.08)
                                            )
                                        } else {
                                            return nil
                                        }
                                    }

                                    // Then display the warning stacks
                                    HStack {
                                        ForEach(0..<warningStacks.count, id: \.self) { index in
                                            warningStacks[index]
                                        }
                                    }
                                }
                                .frame(alignment: .leading)
                                .padding(.bottom, geometry.size.height * 0.02)
                                
//                                Spacer()
                            }.padding(.horizontal, 20)
                        }
                }
                .padding(.vertical, 10)
                .padding(.trailing, 10)
                
                Spacer()
                
                ZStack {
                    HStack(spacing: 0) {
                        KanbanColumn(columnType: .ToDo, title: "To Do", headerColor: .red, geometry: geometry)
                            .onDrop(of: [.kanbanTask], isTargeted: nil, perform: { _ in false })
                            .zIndex(boardVM.draggedCard != nil && kanbanVM.toDoTasks.contains(boardVM.draggedCard!) ? 5 : 1)

                        KanbanColumn(columnType: .Doing, title: "Doing", headerColor: .cyan, geometry: geometry)
                            .onDrop(of: [.kanbanTask], isTargeted: nil, perform: { _ in false })
                            .zIndex(boardVM.draggedCard != nil && kanbanVM.inProgressTasks.contains(boardVM.draggedCard!) ? 5 : 1)

                        KanbanColumn(columnType: .Testing, title: "Testing", headerColor: .blue, geometry: geometry)
                            .onDrop(of: [.kanbanTask], isTargeted: nil, perform: { _ in false })
                            .zIndex(boardVM.draggedCard != nil && kanbanVM.testingTasks.contains(boardVM.draggedCard!) ? 5 : 1)

                        KanbanColumn(columnType: .Done, title: "Done", headerColor: .green, geometry: geometry)
                            .onDrop(of: [.kanbanTask], isTargeted: nil, perform: { _ in false })
                            .zIndex(boardVM.draggedCard != nil && kanbanVM.doneTasks.contains(boardVM.draggedCard!) ? 5 : 1)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
                    .mobileChatVisibility($boardVM.isChatVisible)
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
        .onChange(of: kanbanVM.toDoTasks) {
            if warningsUpdate(from: kanbanVM.toDoTasks) {
                // Limpiamos las tareas de la columna
                kanbanVM.toDoTasks.removeAll()
            }
        }.onChange(of: kanbanVM.inProgressTasks) {
            if warningsUpdate(from: kanbanVM.inProgressTasks) {
                kanbanVM.inProgressTasks.removeAll()
            }
        }.onChange(of: kanbanVM.testingTasks) {
            if warningsUpdate(from: kanbanVM.testingTasks) {
                kanbanVM.testingTasks.removeAll()
            }
        }.onChange(of: kanbanVM.doneTasks) {
            // full Done column should not trigger a warning. Just clean all tasks.
            checkDoneColumn()
        }
        .onChange(of: boardVM.warningList) {
            warningControl()
        }
        .ornament(
            visibility: boardVM.isChatVisible.0,
            attachmentAnchor: .scene(.bottomFront),
            contentAlignment: .top
        ) {
            FakeMobileChat() {
                if let flaggedTask = boardVM.isChatVisible.1 {
                    // Busca y actualiza la tarea en la columna "To Do"
                    if let index = kanbanVM.toDoTasks.firstIndex(where: { $0.id == flaggedTask.id }) {
                        kanbanVM.toDoTasks[index].isFlagged = false
//                        toDoTasks[index].isComplete = true
                    }
                    // Busca y actualiza la tarea en la columna "In Progress"
                    else if let index = kanbanVM.inProgressTasks.firstIndex(where: { $0.id == flaggedTask.id }) {
                        kanbanVM.inProgressTasks[index].isFlagged = false
//                        inProgressTasks[index].isComplete = true
                    }
                    // Busca y actualiza la tarea en la columna "Testing"
                    else if let index = kanbanVM.testingTasks.firstIndex(where: { $0.id == flaggedTask.id }) {
                        kanbanVM.testingTasks[index].isFlagged = false
//                        testingTasks[index].isComplete = true
                    }
                    // Busca y actualiza la tarea en la columna "Done"
                    else if let index = kanbanVM.doneTasks.firstIndex(where: { $0.id == flaggedTask.id }) {
                        kanbanVM.doneTasks[index].isFlagged = false
//                        doneTasks[index].isComplete = true
                    }
                }
            }
            .labelStyle(.iconOnly)
            .padding(.vertical)
//            .glassBackgroundEffect()
            .frame(width: 150, height: 400)
            .rotation3DEffect(.degrees(25), axis: (x: 1, y: 0, z: 0))
            .offset(z: 100)
            .offset(y: -80)
            .mobileChatVisibility($boardVM.isChatVisible)
        }
        .onAppear {
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
        } else {
            return
        }
        kanbanVM.startNewRound()
    }
    
    private func startRound() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(secondsUntilGameStarts)) {
                boardVM.gameStatus = .playing
                // Logica adicional para iniciar la ronda
            }
        }

//        private func endRound(vm: KanbanAppVM) {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                vm.startNewRound()
//                startRound()
//            }
//        }
    
    @MainActor
    private func warningsUpdate(from column: [KanbanTask]) -> Bool {
        if column.count > 4 {
            if let task = column.last {
                // Calculamos los warnings a añadir
                var numberOfWarningsToAdd = 1
                if task.isWarningEnabled {
                    numberOfWarningsToAdd *= 2
                }
                if kanbanVM.wardenIsWatching {
                    numberOfWarningsToAdd *= 2
                }
                let projectId = task.projectId

                // Actualizamos o creamos el WarningsInfo adecuado
                var warningInfo = boardVM.warningList.getOrCreate(id: projectId)
                warningInfo.numberOfWarnings += numberOfWarningsToAdd
                warningInfo.projectColor = task.color

                // Actualizamos el array con el nuevo valor
                boardVM.warningList.update(warningInfo)
            }
            return true
        }
        return false
    }

//    @MainActor
//    private func handleDrop(of card: KanbanTask, from cardList: inout [KanbanTask], in location: CGPoint, ofSize geometry: GeometryProxy) {
//        if let index = cardList.firstIndex(of: card) {
//            cardList.remove(at: index)
//            
//            if isInValidDropArea(location: location, geometry: geometry) {
//                let columnWidth = geometry.size.width / 4
//                let columnIndex = Int(location.x / columnWidth)
//                
//                switch columnIndex {
//                case 0:
//                        kanbanVM.add(card, to: .ToDo)
//                case 1:
//                        kanbanVM.add(card, to: .Doing)
//                case 2:
//                        kanbanVM.add(card, to: .Testing)
//                case 3:
//                        kanbanVM.add(card, to: .Done)
//                default:
//                    cardList.insert(card, at: index) // Si no es válido, devolver a la lista original
//                }
//            } else {
//                // Devolver la tarjeta a la posición original si no es un drop válido
//                cardList.insert(card, at: index)
//            }
//        }
//    }

    @MainActor
    private func isInDropArea(location: CGPoint, geometry: GeometryProxy) -> Bool {
        let kanbanWidth = geometry.size.width * 0.965
        let leadingPadding = geometry.size.width * 0.015
        let kanbanHeight = geometry.size.height * 0.75
        let yInitKanbanBoardPosition = geometry.size.height * 0.27 // Without colored headers
        
        let isInDropArea = (0...kanbanWidth ~= location.x - leadingPadding) && (yInitKanbanBoardPosition...kanbanHeight + yInitKanbanBoardPosition ~= location.y)

//        print("Adjusted X: \(location.x), Adjusted Y: \(location.y)")
//        print("Drop Area Status: \(isInDropArea)")
        
        return isInDropArea
    }

    @MainActor
    private func isInValidDropArea(location: CGPoint, geometry: GeometryProxy) -> Bool {
        let columnWidth = (geometry.size.width * 0.965) / 4
        let columnHeight = geometry.size.height * 0.75
        let yInitKanbanBoardPosition = geometry.size.height * 0.27
        let yEndKanbanBoardPosition = yInitKanbanBoardPosition + columnHeight
        
        // Validación en el rango de la columna y la altura del tablero
        let isInYRange = location.y >= yInitKanbanBoardPosition && location.y <= yEndKanbanBoardPosition
        let columnIndex = Int((location.x - geometry.size.width * 0.015) / columnWidth)
        let isInXRange = columnIndex >= 0 && columnIndex <= 3
        
        return isInXRange && isInYRange
    }
    
    private func animateNextTasksSequentially() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(secondsUntilGameStarts)) {
            boardVM.gameStatus = .playing
        }
    }
    
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
                    count: counter,
                    startOnAppear: true,
                    action: {
//                        print("Contador llegó a 0 en View A")
                        boardVM.animateNextTask = true
                        toggleView() // Cambia la vista cuando el contador llega a 0
                    }
                )
            } else {
                CountDownCircle(
                    count: counter,
                    startOnAppear: true,
                    action: {
//                        print("Contador llegó a 0 en View B")
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


#Preview(windowStyle: .plain) {
    KanbanBoard().frame(width: 700, height: 700)
        .kanbanVM(KanbanAppVM())
}





//struct KanbanColumn: View {
//    enum KanbanColumnType: Int {
//        case ToDo
//        case Doing
//        case Testing
//        case Done
//    }
//    
//    enum DragStatus {
//        case outOfBounds
//        case notAllowed
//        case valid
//    }
//    
//    @State private var cardDragStatus: DragStatus = .outOfBounds
//    let columnType: KanbanColumnType
//    let title: String
//    let headerColor: Color
//    let tasks: Binding<[KanbanTask]>
//    let geometry: GeometryProxy
//    @State private var draggedCard: KanbanTask?
//    
//    @Binding var toDoTasks: [KanbanTask]
//    @Binding var inProgressTasks: [KanbanTask]
//    @Binding var testingTasks: [KanbanTask]
//    @Binding var doneTasks: [KanbanTask]
//    
//    var body: some View {
//        HStack(alignment: .top, spacing: 0) {
//            VStack(spacing: 0) {
//                ZStack {
//                    Rectangle()
//                        .fill(
//                            LinearGradient(
//                                gradient: Gradient(stops: [
//                                    .init(color: headerColor, location: 0.52),
//                                    .init(color: headerColor.darker(by: 0.4), location: 1.0)
//                                ]),
//                                startPoint: .top,
//                                endPoint: .bottom
//                            )
//                        )
//                    
//                    Text(title)
//                        .font(.title)
//                        .fontDesign(.serif)
//                        .foregroundStyle(.black)
//                }
//                .frame(height: geometry.size.height * 0.145)
//                
//                Rectangle()
//                    .fill(.clear)
//                    .background {
//                        HStack {
//                            Spacer()
//                            Rectangle()
//                                .foregroundStyle(.black.opacity(0.9))
//                                .frame(width: geometry.size.width * 0.005)
//                                .zIndex(1)
//                        }
//                    }
//                    .overlay {
//                        VStack(spacing: geometry.size.height * 0.02) {
//                            Spacer(minLength: 0)
//                            ForEach(Array(tasks.wrappedValue.reversed().enumerated()), id: \.element.id) {
//                                index,
//                                task in
//                                let draggableKanbanCard = DraggableView(
//                                    content: {
//                                        KanbanCard(task: task)
//                                    },
//                                    onDrag: { value in
//                                        if draggedCard == nil {
//                                            draggedCard = task
//                                        }
//                                        
//                                        // Actualiza la posición global ajustada con el offset del arrastre
//                                        let globalPosition = CGPoint(
//                                            x: geometry.frame(in: .global).origin.x + value.translation.width,
//                                            y: geometry.frame(in: .global).origin.y + value.translation.height
//                                        )
//                                        
//                                        // Detecta si el drop sería válido o no usando la posición global
////                                                if isInValidDropArea(location: globalPosition, geometry: geometry) {
////                                                    dropTarget = true
////                                                } else {
////                                                    dropTarget = false
////                                                }
//                                        self.cardDragStatus = isInValidDropArea(columnIndex: columnType.rawValue,location: globalPosition, geometry: geometry)
//                                    },
//                                    onEnded: { value in
//                                        
//                                        let globalPosition = CGPoint(
//                                            x: geometry.frame(in: .global).origin.x + value.translation.width,
//                                            y: geometry.frame(in: .global).origin.y + value.translation.height
//                                        )
//
//                                        handleCardDrop(columnIndex: columnType.rawValue, of: task, from: tasks, in: globalPosition, ofSize: geometry)
//                                        draggedCard = nil
//                                    })
////                                draggableKanbanCard
//                                    
////                                // Variable shadow based on if we are dragging to create a depth effect
//                                draggableKanbanCard
//                                    .overlay(
//                                        Group {
////                                            if dropTarget {
//                                            let kanbanCardWidth = geometry.size.width*0.21
//                                            if cardDragStatus == .notAllowed && draggableKanbanCard.isDragging {
//                                                    Image(systemName: "xmark.circle.fill")
//                                                        .foregroundColor(.red)
//                                                        .font(.largeTitle)
//                                                        .padding()
//                                                        .position(x: kanbanCardWidth + 3, y: 3)
//                                            } else if cardDragStatus == .valid && draggableKanbanCard.isDragging {
//                                                    Image(systemName: "xmark.circle.fill")
//                                                        .foregroundColor(.green)
//                                                        .font(.largeTitle)
//                                                        .padding()
//                                                        .position(x: kanbanCardWidth + 3, y: -3)
//                                                }
////                                            }
//                                        }
//                                    )
//                                    .frame(depth: draggableKanbanCard.isDragging ? 30 : 4)
//                                    .shadow(color: .black.opacity(draggableKanbanCard.isDragging ? 0.7 : 0.1), radius: draggableKanbanCard.isDragging ? 12 : 18, x: 0, y: draggableKanbanCard.isDragging ? geometry.size.height*0.03 : geometry.size.height*0.005)
//                                    .frame(height: geometry.size.height * 0.13)
////                                    .offset(draggedCard == task && draggableKanbanCard.isDragging ? draggableKanbanCard.dragOffset : .zero)
////                                    .gesture(
////                                        DragGesture()
////                                            .onChanged { value in
////                                                if draggedCard == nil {
////                                                    draggedCard = task
////                                                    task.isDragging = true
////                                                }
////                                                task.dragOffset = value.translation
////                                                
////                                                // Actualiza la posición global ajustada con el offset del arrastre
////                                                let globalPosition = CGPoint(
////                                                    x: geometry.frame(in: .global).origin.x + value.translation.width,
////                                                    y: geometry.frame(in: .global).origin.y + value.translation.height
////                                                )
////                                                
////                                                // Detecta si el drop sería válido o no usando la posición global
//////                                                if isInDropArea(location: globalPosition, geometry: geometry) {
//////                                                    dropTarget = true
//////                                                } else {
//////                                                    dropTarget = false
//////                                                }
////                                                self.cardDragStatus = isInValidDropArea(columnIndex: columnType.rawValue,location: globalPosition, geometry: geometry)
////                                            }
////                                            .onEnded { value in
////                                                let globalPosition = CGPoint(
////                                                    x: geometry.frame(in: .global).origin.x + value.translation.width,
////                                                    y: geometry.frame(in: .global).origin.y + value.translation.height
////                                                )
////
////                                                handleCardDrop(columnIndex: columnType.rawValue, of: task, from: tasks, in: globalPosition, ofSize: geometry)
////                                                draggedCard = nil
////                                                task.dragOffset = .zero
////                                                task.isDragging = false
////                                            }
////                                    )
//                                    .allowsHitTesting(true)
//                            }
//                        }
//                        .padding(.bottom, geometry.size.height * 0.05)
//                        .padding(.leading, geometry.size.height * 0.035)
//                        .padding(.trailing, geometry.size.height * 0.025)
//                    }.zIndex(2)
//            }
//            
//        }
//    }
//    
//    private func isInValidDropArea(columnIndex: Int, location: CGPoint, geometry: GeometryProxy) -> DragStatus {
//        let leadingOffset = geometry.size.width * 0.03
//        let kanbanWidth = geometry.size.width * 0.994
//        let columnWidth = (kanbanWidth) / 4
//        let columnHeight = geometry.size.height * 0.75
//        let cardHorizontalPadding = columnHeight * 0.015
//        let cardWidth = columnWidth - cardHorizontalPadding*2
//        let cardHeight = geometry.size.height * 0.145
//        let yInitKanbanBoardPosition = geometry.size.height * 0.27
//        let yEndKanbanBoardPosition = yInitKanbanBoardPosition + columnHeight
//        
//        // Calcular los límites de la tarjeta
//        let cardCenter = location.x + cardWidth/2
//        
//        // Validación en el rango de la columna y la altura del tablero
//        let isInYRange = location.y+yInitKanbanBoardPosition+cardHeight >= -yInitKanbanBoardPosition+cardHeight && location.y+yInitKanbanBoardPosition-50 <= yInitKanbanBoardPosition+cardHeight
////        este cálculo falla. Cuando vamos hacia a delante 175 + lo que avancemos = +1 al index pero si vamos hacia atrás queda en 0 y index - 0 sigue siendo x. Por eso hacia atrás no se mueve.
//        let columnIndex = ((columnWidth*CGFloat(columnIndex) + cardCenter-leadingOffset) / kanbanWidth)*4
//        let isInXRange = columnIndex >= 0 && columnIndex <= 3.7
//        let forceOutOfBounds = columnIndex <= -0.2 || columnIndex >= 3.7 || !isInYRange
//        
////        print("Y Start: \(yInitKanbanBoardPosition), Y End: \(yEndKanbanBoardPosition)")
////        print("Adjusted X: \(cardCenter), columnIndex: \(columnIndex)")
////        print("Y: \(location.y+yInitKanbanBoardPosition) >= \(-yInitKanbanBoardPosition) && \(location.y+yInitKanbanBoardPosition-50) <= \(yInitKanbanBoardPosition+cardHeight)")
////        print("isInYRange: \(isInYRange), isInXRange: \(isInXRange)")
////        print("\(location.y+yInitKanbanBoardPosition+cardHeight) >=  \(-yInitKanbanBoardPosition+cardHeight) \(location.y+yInitKanbanBoardPosition-50) <= \(yInitKanbanBoardPosition+cardHeight)")
//        
//        if forceOutOfBounds {
//            return .outOfBounds
//        }
//        
//        return switch (isInXRange, isInYRange) {
//            case (true, true):
//                .valid
//            case (false, false):
//                .outOfBounds
//            default:
//                .notAllowed
//        }
//        
//    }
//    
//    private func handleCardDrop(columnIndex: Int,of card: KanbanTask, from cardList: Binding<[KanbanTask]>, in location: CGPoint, ofSize geometry: GeometryProxy) {
//        if let index = cardList.wrappedValue.firstIndex(where: { $0 == card }) {
//            let removedCard = cardList.wrappedValue.remove(at: index)
//            
//            if isInValidDropArea(columnIndex: columnIndex, location: location, geometry: geometry) == .valid {
//                let leadingOffset = geometry.size.width * 0.03
//                let kanbanWidth = geometry.size.width * 0.994
//                let columnWidth = (kanbanWidth) / 4
//                let columnHeight = geometry.size.height * 0.75
//                let cardHorizontalPadding = columnHeight * 0.015
//                let cardWidth = columnWidth - cardHorizontalPadding*2
////                let cardHeight = geometry.size.height * 0.145
////                let yInitKanbanBoardPosition = geometry.size.height * 0.27
////                let yEndKanbanBoardPosition = yInitKanbanBoardPosition + columnHeight
//                
//                // Calcular los límites de la tarjeta
//                let cardCenter = location.x + cardWidth/2
//                
//                // Validación en el rango de la columna y la altura del tablero
////                let isInYRange = location.y+yInitKanbanBoardPosition+cardHeight >= -yInitKanbanBoardPosition+cardHeight && location.y+yInitKanbanBoardPosition-50 <= yInitKanbanBoardPosition+cardHeight
//        //        este cálculo falla. Cuando vamos hacia a delante 175 + lo que avancemos = +1 al index pero si vamos hacia atrás queda en 0 y index - 0 sigue siendo x. Por eso hacia atrás no se mueve.
//                let newColumnIndex = Int(((columnWidth*CGFloat(columnIndex) + cardCenter-leadingOffset) / kanbanWidth)*4)
////                print("newColumnIndex: \(columnIndex) = columnIndex:\(columnIndex) + \(cardCenter-leadingOffset) / \(columnWidth)")
//                switch newColumnIndex {
//                case 0:
//                    toDoTasks.append(removedCard)
//                    print("column 0")
//                case 1:
//                    inProgressTasks.append(removedCard)
//                    print("column 1")
//                case 2:
//                    testingTasks.append(removedCard)
//                    print("column 2")
//                case 3:
//                    doneTasks.append(removedCard)
//                    print("column 3")
//                default:
//                    cardList.wrappedValue.insert(removedCard, at: index) // Si no es válido, devolver a la lista original
//                    print("column default")
//                }
//                
//            } else {
//                // Devolver la tarjeta a la posición original si no es un drop válido
//                cardList.wrappedValue.insert(removedCard, at: index)
//                print("column ELSE")
//            }
//        }
//    }
//}
//
//struct DraggableView<Content: View>: View {
//    @State var isDragging: Bool = false
//    @State var dragOffset: CGSize = .zero
//    let content: Content
//    let onDrag: (DragGesture.Value) -> Void
//    let onEnded: (DragGesture.Value) -> Void
//    
//    init(
//        content: @escaping () -> Content,
//        onDrag: @escaping (DragGesture.Value) -> Void,
//        onEnded: @escaping (DragGesture.Value) -> Void
//    ) {
//        self.content = content()
//        self.onDrag = onDrag
//        self.onEnded = onEnded
//    }
//    
//    var body: some View {
//        content
//            .offset(dragOffset)
//            .gesture(
//                DragGesture()
//                    .onChanged { value in
//                        isDragging = true
//                        dragOffset = value.translation
//                        onDrag(value)
//                    }
//                    .onEnded { value in
//                        isDragging = false
//                        dragOffset = .zero
//                        onEnded(value)
//                    }
//            )
//    }
//}



//struct KanbanColumn: View {
//    let title: String
//    let color: Color
//    @Binding var tasks: [KanbanTask]
//    @Binding var toDoTasks: [KanbanTask]
//    @Binding var inProgressTasks: [KanbanTask]
//    @Binding var testingTasks: [KanbanTask]
//    @Binding var doneTasks: [KanbanTask]
//    let parentGeometry: GeometryProxy
//    
//    @State private var draggedCard: KanbanTask?
//    @State private var dragOffset = CGSize.zero
//    @State private var isDragging = false
//    @State private var dropTarget = true
//    @State private var validDropTarget = true
//    
//    var body: some View {
//        GeometryReader { geometry in
//            HStack(alignment: .top, spacing: 0) {
//                VStack(spacing: 0) {
//                    ZStack {
//                        Rectangle()
//                            .fill(
//                                LinearGradient(
//                                    gradient: Gradient(stops: [
//                                        .init(color: color, location: 0.52),
//                                        .init(color: color.darker(by: 0.4), location: 1.0)
//                                    ]),
//                                    startPoint: .top,
//                                    endPoint: .bottom
//                                )
//                            )
//                        
//                        Text(title)
//                            .font(.title)
//                            .fontDesign(.serif)
//                            .foregroundStyle(.black)
//                    }
//                    .frame(height: geometry.size.height * 0.145)
//                    
//                    Rectangle()
//                        .fill(.clear)
//                        .overlay {
//                            VStack(spacing: geometry.size.height*0.04) {
//                                Spacer(minLength: 0)
//                                ForEach(Array(tasks.reversed().enumerated()), id: \.element.id) { index, task in
//                                    KanbanCard(task: task)
//                                        .frame(height: geometry.size.height*0.17)
//                                        .offset(draggedCard == task && isDragging ? dragOffset : .zero)
//                                        .gesture(
//                                            DragGesture()
//                                                .onChanged { value in
//                                                    print(value)
//                                                    if draggedCard == nil {
//                                                        draggedCard = task
//                                                        isDragging = true
//                                                    }
//                                                    dragOffset = value.translation
//                                                    
//                                                    // Detecta si el drop sería válido o no
//                                                    if isInDropArea(location: value.location, geometry: parentGeometry) {
//                                                        dropTarget = true
//                                                    } else {
//                                                        dropTarget = false
//                                                    }
//                                                    
//                                                    if isInValidDropArea(location: value.location, geometry: parentGeometry) {
//                                                        validDropTarget = true
//                                                    } else {
//                                                        validDropTarget = false
//                                                    }
//                                                }
//                                                .onEnded { value in
//                                                    handleDrop(card: task, location: value.location, geometry: parentGeometry)
//                                                    draggedCard = nil
//                                                    dragOffset = .zero
//                                                    isDragging = false
//                                                }
//                                        )
//                                        .allowsHitTesting(true)
//                                }
//                            }
//                            .padding(.bottom, geometry.size.height*0.05)
//                            .padding(.horizontal, geometry.size.height*0.03)
//                        }
//                }
//                Rectangle()
//                    .foregroundStyle(.black.opacity(0.9))
//                    .frame(width: geometry.size.width * 0.005)
//            }
//        }
//    }
//    
//    private func isInDropArea(location: CGPoint, geometry: GeometryProxy) -> Bool {
//        let kanbanWidth = geometry.size.width*0.965
//        let leadingPadding = geometry.size.width*0.015
//        let kanbanHeight = geometry.size.height * 0.75
//        let yInitKanbanBoardPosition = geometry.size.height*0.27 // Without colored headers
//        let topPadding = geometry.size.height*0.15
//        
//        return (0...kanbanWidth ~= location.x - leadingPadding) && (yInitKanbanBoardPosition...kanbanHeight+topPadding ~= location.y)
//    }
//    
//    private func isInValidDropArea(location: CGPoint, geometry: GeometryProxy) -> Bool {
//        let columnWidth = (geometry.size.width*0.965) / 4
//        let columnHeight = geometry.size.height * 0.75
//        let yInitKanbanBoardPosition = geometry.size.height*0.27 // Without colored headers
//        let columnIndex = Int((location.x - geometry.size.width*0.015) / columnWidth)
//        let topPadding = geometry.size.height*0.15
//        print("isInValidDropArea columnIndex: \(columnIndex)")
//        return columnIndex >= 0 && columnIndex <= 2 && (yInitKanbanBoardPosition...columnHeight+topPadding ~= location.y)
//    }
//
//    private func handleDrop(card: KanbanTask, location: CGPoint, geometry: GeometryProxy) {
//        if let index = tasks.firstIndex(of: card) {
//            
//            tasks.remove(at: index)
//            if isInValidDropArea(location: location, geometry: geometry) {
////                dropDestination()
//                let columnWidth = geometry.size.width / 4
//                let columnIndex = Int(location.x / columnWidth)
//                print("columnIndex: \(columnIndex)")
//                
//                switch columnIndex {
//                case 0:
//                    toDoTasks.append(card)
//                case 1:
//                    inProgressTasks.append(card)
//                case 2:
//                    testingTasks.append(card)
//                case 3:
//                    doneTasks.append(card)
//                default:
//                    tasks.insert(card, at: index) // Si no es válido, devolver a la lista original
//                }
//            } else {
//                // Devolver la tarjeta a la posición original si no es un drop válido
//                tasks.insert(card, at: index)
//            }
//        }
//    }
//}





////
////  KanbanBoard.swift
////  DoomKanban
////
////  Created by Jose Luis Escolá García on 3/8/24.
////
//
//import SwiftUI
//import Algorithms
//
//struct KanbanBoard: View {
//    @State private var nextTaskPosition: CGPoint = .zero
//    @State private var draggedCard: KanbanTask?
//    @State private var dragOffset = CGSize.zero
//    @State private var isDragging = false
//    @State private var dropTarget = true
//    @State private var validDropTarget = true
//
//    @State private var nextCards: [KanbanTask] = [
//        .init(title: "Esto es un test", color: .blue, value: 3),
//        .init(title: "Esto es un test", color: .yellow, value: 3),
//        .init(title: "Esto es un test", color: .green, value: 3),
//        .init(title: "Esto es un test", color: .red, value: 5)
//    ]
//    
//    @State private var toDoTasks: [KanbanTask] = []
//    @State private var inProgressTasks: [KanbanTask] = []
//    @State private var testingTasks: [KanbanTask] = []
//    @State private var doneTasks: [KanbanTask] = []
//
//    var body: some View {
//        GeometryReader { geometry in
//            VStack {
//                HStack(spacing: 0) {
//                    VStack(spacing: 5) {
//                        ZStack {
//                            Text("Next task")
//                                .foregroundStyle(.black)
//                                .bold()
//                                .font(.system(size: geometry.size.height * 0.04))
//                        }
//                        let kanbanCardWidth = geometry.size.width / 5
//                        let kanbanCardHeight = geometry.size.height * 0.13
//                        let kanbanCardInitialPosition = CGPoint(x: kanbanCardWidth / 2, y: 50)
//
//                        ZStack {
//                            if nextCards.count > 1 {
//                                KanbanCard(task: nextCards[1])
//                                    .frame(depth: 30)
//                                    .background {
//                                        VStack {
//                                            Spacer()
//                                            LinearGradient(
//                                                gradient: Gradient(stops: [
//                                                    .init(color: .black.opacity(0.4), location: 0.52),
//                                                    .init(color: .gray.opacity(0.8), location: 1.0)
//                                                ]),
//                                                startPoint: .top,
//                                                endPoint: .bottom
//                                            )
//                                            .frame(width: geometry.size.width / 7, height: geometry.size.height * 0.07)
//                                            .shadow(color: .black, radius: 2, y: geometry.size.height * 0.06)
//                                            Spacer()
//                                        }
//                                    }
//                                    .position(kanbanCardInitialPosition)
//                            }
//                            
//                            if let card = nextCards.first {
//                                KanbanCard(task: card)
//                                    .frame(depth: 1)
//                                    .background {
//                                        VStack {
//                                            Spacer()
//                                            LinearGradient(
//                                                gradient: Gradient(stops: [
//                                                    .init(color: .black.opacity(0.4), location: 0.52),
//                                                    .init(color: .gray.opacity(0.8), location: 1.0)
//                                                ]),
//                                                startPoint: .top,
//                                                endPoint: .bottom
//                                            )
//                                            .frame(width: geometry.size.width / 7, height: geometry.size.height * 0.07)
//                                            .shadow(color: .black, radius: 2, y: geometry.size.height * 0.06)
//                                            Spacer()
//                                        }
//                                    }
//                                    .overlay(
//                                        Group {
//                                            if dropTarget {
//                                                if !validDropTarget && isDragging {
//                                                    Image(systemName: "xmark.circle.fill")
//                                                        .foregroundColor(.red)
//                                                        .font(.title)
//                                                        .padding()
//                                                        .position(x: kanbanCardWidth + 3, y: 3)
//                                                }else if validDropTarget && isDragging {
//                                                    Image(systemName: "xmark.circle.fill")
//                                                        .foregroundColor(.green)
//                                                        .font(.largeTitle)
//                                                        .padding()
//                                                        .position(x: kanbanCardWidth + 3, y: -3)
//                                                }
//                                            }
//                                        }
//                                    )
//                                    .position(nextTaskPosition)
//                                    .offset(draggedCard == card && isDragging ? dragOffset : .zero)
//                                    .gesture(
//                                        DragGesture()
//                                            .onChanged { value in
//                                                if draggedCard == nil {
//                                                    draggedCard = card
//                                                    isDragging = true
//                                                }
//                                                dragOffset = value.translation
//                                                
//                                                // Detecta si el drop sería válido o no
//                                                if isInDropArea(location: value.location, geometry: geometry) {
//                                                    dropTarget = true
//                                                } else {
//                                                    dropTarget = false
//                                                }
//                                                
//                                                if isInValidDropArea(location: value.location, geometry: geometry) {
//                                                    validDropTarget = true
//                                                } else {
//                                                    validDropTarget = false
//                                                }
//                                            }
//                                            .onEnded { value in
//                                                handleDrop(card: card, location: value.location, geometry: geometry)
//                                                draggedCard = nil
//                                                dragOffset = .zero
//                                                isDragging = false
//                                            }
//                                    )
//                            }
//                        }
//                        .frame(width: kanbanCardWidth, height: kanbanCardHeight)
//                        .padding(.top, 15)
//                        .onAppear {
//                            nextTaskPosition = kanbanCardInitialPosition
//                        }
//                    }
//                    .padding(.leading, geometry.size.width * 0.035)
//                    .padding(.trailing, geometry.size.width * 0.025)
//                    
//                    RoundedRectangle(cornerRadius: 15)
//                        .fill(.white)
//                        .stroke(.black.opacity(0.5), lineWidth: 2)
//                        .overlay {
//                            VStack(alignment: .leading, spacing: 5) {
//                                Text("Warnings")
//                                    .font(.system(size: geometry.size.height * 0.05))
//                                    .bold()
//                                    .foregroundStyle(.black)
//                                
//                                Spacer()
//                            }.padding(.horizontal, 20)
//                        }
//                }
//                .padding(.vertical, 10)
//                .padding(.trailing, 10)
//                
//                Spacer()
//                
//                ZStack {
//                    HStack(spacing: 0) {
//                        KanbanColumn(title: "To Do", color: .red, tasks: toDoTasks, dropDestination: {Rectangle()})
//                            .background(draggedCard != nil ? Color.red.opacity(0.3) : Color.red)
//                            .onDrop(of: [.kanbanTask], isTargeted: nil, perform: { _ in false })
//                        
//                        KanbanColumn(title: "Doing", color: .cyan, tasks: inProgressTasks, dropDestination: {Rectangle()})
//                            .background(draggedCard != nil ? Color.cyan.opacity(0.3) : Color.cyan)
//                            .onDrop(of: [.kanbanTask], isTargeted: nil, perform: { _ in false })
//                        
//                        KanbanColumn(title: "Testing", color: .blue, tasks: testingTasks, dropDestination: {Rectangle()})
//                            .background(draggedCard != nil ? Color.blue.opacity(0.3) : Color.blue)
//                            .onDrop(of: [.kanbanTask], isTargeted: nil, perform: { _ in false })
//                        
//                        KanbanColumn(title: "Done", color: .green, tasks: doneTasks, dropDestination: {Rectangle()})
//                            .background(draggedCard != nil ? Color.green.opacity(0.3) : Color.green)
//                            .onDrop(of: [.kanbanTask], isTargeted: nil, perform: { _ in false })
//                    }
//                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
//                    KanbanBoardShape()
//                        .foregroundStyle(.black)
//                }
//                .background {
//                    RoundedRectangle(cornerRadius: 25.0)
//                        .fill(.white.opacity(0.8))
//                }
//                .frame(height: geometry.size.height * 0.75)
//            }
//        }
//    }
//    
//    private func isInDropArea(location: CGPoint, geometry: GeometryProxy) -> Bool {
//        let kanbanWidth = geometry.size.width*0.965
//        let leadingPadding = geometry.size.width*0.015
//        let kanbanHeight = geometry.size.height * 0.75
//        let yInitKanbanBoardPosition = geometry.size.height*0.27 // Without colored headers
//        let topPadding = geometry.size.height*0.15
//        
//        return (0...kanbanWidth ~= location.x - leadingPadding) && (yInitKanbanBoardPosition...kanbanHeight+topPadding ~= location.y)
//    }
//    
//    private func isInValidDropArea(location: CGPoint, geometry: GeometryProxy) -> Bool {
//        let columnWidth = (geometry.size.width*0.965) / 4
//        let columnHeight = geometry.size.height * 0.75
//        let yInitKanbanBoardPosition = geometry.size.height*0.27 // Without colored headers
//        let columnIndex = Int((location.x - geometry.size.width*0.015) / columnWidth)
//        let topPadding = geometry.size.height*0.15
//        
//        return columnIndex >= 0 && columnIndex <= 2 && (yInitKanbanBoardPosition...columnHeight+topPadding ~= location.y)
//    }
//
//    private func handleDrop(card: KanbanTask, location: CGPoint, geometry: GeometryProxy) {
//        if let index = nextCards.firstIndex(of: card) {
//            nextCards.remove(at: index)
//            
//            if isInValidDropArea(location: location, geometry: geometry) {
//                let columnWidth = geometry.size.width / 4
//                let columnIndex = Int(location.x / columnWidth)
//                
//                switch columnIndex {
//                case 0:
//                    toDoTasks.append(card)
//                case 1:
//                    inProgressTasks.append(card)
//                case 2:
//                    testingTasks.append(card)
//                case 3:
//                    doneTasks.append(card)
//                default:
//                    nextCards.insert(card, at: index) // Si no es válido, devolver a la lista original
//                }
//            } else {
//                // Devolver la tarjeta a la posición original si no es un drop válido
//                nextCards.insert(card, at: index)
//            }
//        }
//    }
//}
//
//#Preview(windowStyle: .plain) {
//    KanbanBoard().frame(width: 700, height: 700)
//}
//
//
//struct KanbanColumn<Content: View>: View {
//    let title: String
//    let color: Color
//    let tasks: [KanbanTask]
//    var dropDestination: () -> Content
//    
//    var body: some View {
//        GeometryReader { geometry in
//            HStack(alignment: .top, spacing: 0) {
//                VStack(spacing: 0) {
//                    ZStack {
//                        Rectangle()
//                            .fill(
//                                LinearGradient(
//                                    gradient: Gradient(stops: [
//                                        .init(color: color, location: 0.52),
//                                        .init(color: color.darker(by: 0.4), location: 1.0)
//                                    ]),
//                                    startPoint: .top,
//                                    endPoint: .bottom
//                                )
//                            )
//                        
//                        Text(title)
//                            .font(.title)
//                            .fontDesign(.serif)
//                            .foregroundStyle(.black)
//                    }
//                    .frame(height: geometry.size.height * 0.145)
//                    
//                    dropDestination()
//                        .overlay {
//                            VStack(spacing: geometry.size.height*0.04) {
//                                Spacer(minLength: 0)
//                                ForEach(Array(tasks.reversed().enumerated()), id: \.element.id) { index, task in
//                                    KanbanCard(task: task)
//                                        .frame(height: geometry.size.height*0.17)
//                                        .draggable(task)
//                                        .allowsHitTesting(true)
//                                }
//                            }
//                            .padding(.bottom, geometry.size.height*0.05)
//                            .padding(.horizontal, geometry.size.height*0.03)
//                        }
//                }
//                Rectangle()
//                    .foregroundStyle(.black.opacity(0.9))
//                    .frame(width: geometry.size.width * 0.005)
//            }
//        }
//    }
//}
