//
//  KanbanBoard.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 3/8/24.
//

import SwiftUI
import Algorithms

import SwiftUI

struct KanbanBoard: View {
    @State var gameStarted = false
    let gameStartsIn: CGFloat = 2
    @State private var nextTaskPosition: CGPoint = .zero
    @State private var draggedCard: KanbanTask?
    @State private var dragOffset = CGSize.zero
    @State private var isDragging = false
    @State private var dropTarget = true
    @State private var validDropTarget = true
//    @State private var cardDragStatus: DragStatus = .outOfBounds
    
    private let nextTaskAnimationTime: Int = 2
    @State private var animateNextTask: Bool = false
    private let counter = 3

    @State private var nextCards: [KanbanTask] = [
        .init(title: "Esto es un test", color: .blue, value: 3),
        .init(title: "Esto es un test", color: .yellow, value: 3),
        .init(title: "Esto es un test", color: .green, value: 3),
        .init(title: "Esto es un test", color: .red, value: 5)
    ]
    
    @State private var toDoTasks: [KanbanTask] = []
    @State private var inProgressTasks: [KanbanTask] = []
    @State private var testingTasks: [KanbanTask] = []
    @State private var doneTasks: [KanbanTask] = []

    var body: some View {
        GeometryReader { geometry in
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
                        let kanbanCardFinalYPosition = kanbanCardInitialPosition.y + kanbanCardHeight * CGFloat((4-toDoTasks.count)) + geometry.size.height*0.18

                        ZStack {
                            if nextCards.count > 1 {
                                KanbanCard(task: nextCards[1])
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

                            if let card = nextCards.first {
                                KanbanCard(task: card)
                                    .frame(depth: 1)
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
                                    .shadow(color: .black.opacity(0.7), radius: 2, x: 0, y: kanbanCardHeight*0.2)
                                    .position(nextTaskPosition)
                                    .offset(draggedCard == card && isDragging ? dragOffset : .zero)
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                if draggedCard == nil {
                                                    draggedCard = card
                                                    isDragging = true
                                                }
                                                dragOffset = value.translation

                                                // Actualiza la posición global ajustada con el offset del arrastre
                                                let globalPosition = CGPoint(
                                                    x: nextTaskPosition.x + dragOffset.width,
                                                    y: nextTaskPosition.y + dragOffset.height
                                                )

                                                // Detecta si el drop sería válido o no usando la posición global
                                                if isInDropArea(location: globalPosition, geometry: geometry) {
                                                    dropTarget = true
                                                } else {
                                                    dropTarget = false
                                                }

                                                if isInValidDropArea(location: globalPosition, geometry: geometry) {
                                                    validDropTarget = true
                                                } else {
                                                    validDropTarget = false
                                                }
                                            }
                                            .onEnded { value in
                                                let globalPosition = CGPoint(
                                                    x: nextTaskPosition.x + dragOffset.width,
                                                    y: nextTaskPosition.y + dragOffset.height
                                                )

                                                handleDrop(of: card, from: &nextCards, in: globalPosition, ofSize: geometry)
                                                draggedCard = nil
                                                dragOffset = .zero
                                                isDragging = false
                                            }
                                    )
                                    .onAppear {
                                        nextTaskPosition = kanbanCardInitialPosition
                                        animateNextTasksSequentially()
                                    }
                                    // Añadir este modificador para detectar cambios en el tamaño de la vista
                                    .onChange(of: geometry.size) { newSize in
                                        let newKanbanCardWidth = newSize.width / 5
                                        nextTaskPosition = CGPoint(x: newKanbanCardWidth / 2, y: geometry.size.height * 0.055)
                                    }
                            }
                        }
                        .frame(width: kanbanCardWidth, height: kanbanCardHeight)
                        .padding(.top, 15)
                        .onChange(of: animateNextTask) {_, newValue in
                            if newValue == true {
                                
                                withAnimation(.easeInOut(duration: TimeInterval(nextTaskAnimationTime))) {
                                    var finalPosition = kanbanCardInitialPosition
                                    finalPosition.y = kanbanCardFinalYPosition
                                    nextTaskPosition = finalPosition
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + Double(nextTaskAnimationTime)) {
                                    //                                        useCard1.toggle()
                                    if let task = nextCards.first {
                                        toDoTasks.append(task)
                                        nextCards.removeFirst()
                                    }
                                    nextTaskPosition = kanbanCardInitialPosition
                                }
                            }
                        }
                    }
                    .padding(.leading, geometry.size.width * 0.035)
                    .padding(.trailing, geometry.size.width * 0.025)
                    .overlay {
                        if gameStarted {
                            addCountDownView(geometry: geometry)
                                .opacity(nextCards.isEmpty || counter == 0 ? 0 : 1)
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
                                }.padding(.top, 30)
                                RoundedRectangle(cornerRadius: geometry.size.height * 0.05)
                                    .fill(.black)
                                    .frame(width: .infinity, height: geometry.size.height * 0.001)
                                HStack {
                                    WarningStack(warnings: [
                                        WarningTriangle(image: Image("shout")).accentColor(Color(red: 135 / 255, green: 199 / 255, blue: 235 / 255))
                                            .foregroundStyle(.blue)
                                            .tint(.blue)
                                            .frame(depth: 2),
                                        WarningTriangle(image: Image("shout")).accentColor(Color(red: 135 / 255, green: 199 / 255, blue: 235 / 255))
                                            .foregroundStyle(.blue)
                                            .tint(.blue)
                                            .frame(depth: 2)
                                        
                                    ], offset: geometry.size.width * 0.025)
                                    .frame(width: geometry.size.width * 0.13, height: geometry.size.height * 0.08)
                                    
                                    WarningStack(warnings: [
                                        WarningTriangle(image: Image("shout")).accentColor(Color(red: 135 / 255, green: 199 / 255, blue: 235 / 255))
                                            .foregroundStyle(.blue)
                                            .tint(.blue)
                                            .frame(depth: 2),
                                        WarningTriangle(image: Image("shout")).accentColor(Color(red: 135 / 255, green: 199 / 255, blue: 235 / 255))
                                            .foregroundStyle(.blue)
                                            .tint(.blue)
                                            .frame(depth: 2)
                                    ], offset: geometry.size.width * 0.025)
                                    .frame(width: geometry.size.width * 0.13, height: geometry.size.height * 0.08)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
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
                        KanbanColumn(columnType: .ToDo, title: "To Do", headerColor: .red, tasks: $toDoTasks, geometry: geometry, toDoTasks: $toDoTasks, inProgressTasks: $inProgressTasks, testingTasks: $testingTasks, doneTasks: $doneTasks)
                            .onDrop(of: [.kanbanTask], isTargeted: nil, perform: { _ in false })
                            .zIndex(draggedCard != nil && toDoTasks.contains(draggedCard!) ? 5 : 1)
                        
                        KanbanColumn(columnType: .Doing, title: "Doing", headerColor: .cyan, tasks: $inProgressTasks, geometry: geometry, toDoTasks: $toDoTasks, inProgressTasks: $inProgressTasks, testingTasks: $testingTasks, doneTasks: $doneTasks)
                            .onDrop(of: [.kanbanTask], isTargeted: nil, perform: { _ in false })
                            .zIndex(draggedCard != nil && inProgressTasks.contains(draggedCard!) ? 5 : 1)
                        
                        KanbanColumn(columnType: .Testing, title: "Testing", headerColor: .blue, tasks: $testingTasks, geometry: geometry, toDoTasks: $toDoTasks, inProgressTasks: $inProgressTasks, testingTasks: $testingTasks, doneTasks: $doneTasks)
                            .onDrop(of: [.kanbanTask], isTargeted: nil, perform: { _ in false })
                            .zIndex(draggedCard != nil && testingTasks.contains(draggedCard!) ? 5 : 1)
                        
                        KanbanColumn(columnType: .Done, title: "Done", headerColor: .green, tasks: $doneTasks, geometry: geometry, toDoTasks: $toDoTasks, inProgressTasks: $inProgressTasks, testingTasks: $testingTasks, doneTasks: $doneTasks)
                            .onDrop(of: [.kanbanTask], isTargeted: nil, perform: { _ in false })
                            .zIndex(draggedCard != nil && doneTasks.contains(draggedCard!) ? 5 : 1)
                        
//                        addKanbanColumn(columnType: .ToDo, title: "To Do", headerColor: .red, tasks: $toDoTasks, geometry: geometry)
//                            .onDrop(of: [.kanbanTask], isTargeted: nil, perform: { _ in false })
//                            .zIndex(draggedCard != nil && toDoTasks.contains(draggedCard!) ? 5 : 1)
//                        
//                        addKanbanColumn(columnType: .Doing, title: "Doing", headerColor: .cyan, tasks: $inProgressTasks, geometry: geometry)
//                            .onDrop(of: [.kanbanTask], isTargeted: nil, perform: { _ in false })
//                            .zIndex(draggedCard != nil && inProgressTasks.contains(draggedCard!) ? 5 : 1)
//                        
//                        addKanbanColumn(columnType: .Testing, title: "Testing", headerColor: .blue, tasks: $testingTasks, geometry: geometry)
//                            .onDrop(of: [.kanbanTask], isTargeted: nil, perform: { _ in false })
//                            .zIndex(draggedCard != nil && testingTasks.contains(draggedCard!) ? 5 : 1)
//                        
//                        addKanbanColumn(columnType: .Done, title: "Done", headerColor: .green, tasks: $doneTasks, geometry: geometry)
//                            .onDrop(of: [.kanbanTask], isTargeted: nil, perform: { _ in false })
//                            .zIndex(draggedCard != nil && doneTasks.contains(draggedCard!) ? 5 : 1)
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
    }

    private func handleDrop(of card: KanbanTask, from cardList: inout [KanbanTask], in location: CGPoint, ofSize geometry: GeometryProxy) {
        if let index = cardList.firstIndex(of: card) {
            cardList.remove(at: index)
            
            if isInValidDropArea(location: location, geometry: geometry) {
                let columnWidth = geometry.size.width / 4
                let columnIndex = Int(location.x / columnWidth)
                
                switch columnIndex {
                case 0:
                    toDoTasks.append(card)
                case 1:
                    inProgressTasks.append(card)
                case 2:
                    testingTasks.append(card)
                case 3:
                    doneTasks.append(card)
                default:
                    cardList.insert(card, at: index) // Si no es válido, devolver a la lista original
                }
            } else {
                // Devolver la tarjeta a la posición original si no es un drop válido
                cardList.insert(card, at: index)
            }
        }
    }
    
//    private func columnCardHandleDrop(columnIndex: Int,of card: KanbanTask, from cardList: Binding<[KanbanTask]>, in location: CGPoint, ofSize geometry: GeometryProxy) {
//        if let index = cardList.wrappedValue.firstIndex(where: { $0 == card }) {
//            let removedCard = cardList.wrappedValue.remove(at: index)
//            
//            if isColumnCardInValidDropArea(columnIndex: columnIndex, location: location, geometry: geometry) == .valid {
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

    private func isInDropArea(location: CGPoint, geometry: GeometryProxy) -> Bool {
        let kanbanWidth = geometry.size.width * 0.965
        let leadingPadding = geometry.size.width * 0.015
        let kanbanHeight = geometry.size.height * 0.75
        let yInitKanbanBoardPosition = geometry.size.height * 0.27 // Without colored headers
        
        let isInDropArea = (0...kanbanWidth ~= location.x - leadingPadding) && (yInitKanbanBoardPosition...kanbanHeight + yInitKanbanBoardPosition ~= location.y)

        print("Adjusted X: \(location.x), Adjusted Y: \(location.y)")
        print("Drop Area Status: \(isInDropArea)")
        
        return isInDropArea
    }

    private func isInValidDropArea(location: CGPoint, geometry: GeometryProxy) -> Bool {
        let columnWidth = (geometry.size.width * 0.965) / 4
        let columnHeight = geometry.size.height * 0.75
        let yInitKanbanBoardPosition = geometry.size.height * 0.27
        let yEndKanbanBoardPosition = yInitKanbanBoardPosition + columnHeight
        
        // Validación en el rango de la columna y la altura del tablero
        let isInYRange = location.y >= yInitKanbanBoardPosition && location.y <= yEndKanbanBoardPosition
        let columnIndex = Int((location.x - geometry.size.width * 0.015) / columnWidth)
        let isInXRange = columnIndex >= 0 && columnIndex <= 3
        
//        print("Y Start: \(yInitKanbanBoardPosition), Y End: \(yEndKanbanBoardPosition)")
//        print("Adjusted Y: \(location.y)")
//        print("IsInXRange: \(isInXRange), IsInYRange: \(isInYRange)")
        
        return isInXRange && isInYRange
    }
//    Las X tienen el mismo problema que la y. Esto se puede solucionar añadiendo el index de la columna actual a el nuevo index (por ejemplo, si es desde la columna To Do será index 0 más el index calculado nuevo)
//    private func isColumnCardInValidDropArea(columnIndex: Int, location: CGPoint, geometry: GeometryProxy) -> DragStatus {
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
    
    
    
    

//    private func addKanbanColumn(
//        columnType: KanbanColumnType,
//        title: String,
//        headerColor: Color,
//        tasks: Binding<[KanbanTask]>,
//        geometry: GeometryProxy
//    ) -> some View {
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
//                            ForEach(Array(tasks.wrappedValue.reversed().enumerated()), id: \.element.id) { index, task in
//                                KanbanCard(task: task)
//                                    .overlay(
//                                        Group {
////                                            if dropTarget {
//                                            let kanbanCardWidth = geometry.size.width*0.21
//                                                if cardDragStatus == .notAllowed && isDragging {
//                                                    Image(systemName: "xmark.circle.fill")
//                                                        .foregroundColor(.red)
//                                                        .font(.largeTitle)
//                                                        .padding()
//                                                        .position(x: kanbanCardWidth + 3, y: 3)
//                                                } else if cardDragStatus == .valid && isDragging {
//                                                    Image(systemName: "xmark.circle.fill")
//                                                        .foregroundColor(.green)
//                                                        .font(.largeTitle)
//                                                        .padding()
//                                                        .position(x: kanbanCardWidth + 3, y: -3)
//                                                }
////                                            }
//                                        }
//                                    )
//                                // Variable shadow based on if we are dragging to create a depth effect
//                                    .frame(depth: isDragging ? 30 : 4)
//                                    .shadow(color: .black.opacity(isDragging ? 0.7 : 0.1), radius: isDragging ? 12 : 18, x: 0, y: isDragging ? geometry.size.height*0.03 : geometry.size.height*0.005)
//                                    .frame(height: geometry.size.height * 0.13)
//                                    .offset(draggedCard == task && isDragging ? dragOffset : .zero)
//                                    .gesture(
//                                        DragGesture()
//                                            .onChanged { value in
//                                                if draggedCard == nil {
//                                                    draggedCard = task
//                                                    isDragging = true
//                                                }
//                                                dragOffset = value.translation
//                                                
//                                                // Actualiza la posición global ajustada con el offset del arrastre
//                                                let globalPosition = CGPoint(
//                                                    x: geometry.frame(in: .global).origin.x + value.translation.width,
//                                                    y: geometry.frame(in: .global).origin.y + value.translation.height
//                                                )
//                                                
//                                                // Detecta si el drop sería válido o no usando la posición global
////                                                if isInDropArea(location: globalPosition, geometry: geometry) {
////                                                    dropTarget = true
////                                                } else {
////                                                    dropTarget = false
////                                                }
//                                                self.cardDragStatus = isColumnCardInValidDropArea(columnIndex: columnType.rawValue,location: globalPosition, geometry: geometry)
//                                            }
//                                            .onEnded { value in
//                                                let globalPosition = CGPoint(
//                                                    x: geometry.frame(in: .global).origin.x + value.translation.width,
//                                                    y: geometry.frame(in: .global).origin.y + value.translation.height
//                                                )
//
//                                                columnCardHandleDrop(columnIndex: columnType.rawValue, of: task, from: tasks, in: globalPosition, ofSize: geometry)
//                                                draggedCard = nil
//                                                dragOffset = .zero
//                                                isDragging = false
//                                            }
//                                    )
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
    private func animateNextTasksSequentially() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(gameStartsIn)) {
            gameStarted = true
            for index in nextCards.indices {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index * counter)) {
                    animateNextTask = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(nextTaskAnimationTime)) {
                        animateNextTask = false
                    }
                }
            }
        }
    }
    
    private func addCountDownView(geometry: GeometryProxy) -> some View {
        let nextKanbanCardSize = geometry.size.width / 5
        let minSize = min(geometry.size.width, geometry.size.height)
        let counterSize = minSize * 0.11

        return CountDownCircle(
            count: counter,
            startOnAppear: true,
            action: {
                print("Pendiente de implementar el lanzamiento de la carta y el reinicio del contador")
                animateNextTask = false
            }
        )
        .id(UUID()) // Force re-creation of the view by changing the id
        .frame(width: counterSize, height: counterSize)
        .frame(depth: 1)
        .offset(x: nextKanbanCardSize / 2 - 15, y: -10)
    }
}


#Preview(windowStyle: .plain) {
    KanbanBoard().frame(width: 700, height: 700)
}

struct KanbanColumn: View {
    enum KanbanColumnType: Int {
        case ToDo
        case Doing
        case Testing
        case Done
    }
    
    enum DragStatus {
        case outOfBounds
        case notAllowed
        case valid
    }
    
    @State private var cardDragStatus: DragStatus = .outOfBounds
    let columnType: KanbanColumnType
    let title: String
    let headerColor: Color
    let tasks: Binding<[KanbanTask]>
    let geometry: GeometryProxy
    @State private var draggedCard: KanbanTask?
    
    @Binding var toDoTasks: [KanbanTask]
    @Binding var inProgressTasks: [KanbanTask]
    @Binding var testingTasks: [KanbanTask]
    @Binding var doneTasks: [KanbanTask]
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(spacing: 0) {
                ZStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: headerColor, location: 0.52),
                                    .init(color: headerColor.darker(by: 0.4), location: 1.0)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    Text(title)
                        .font(.title)
                        .fontDesign(.serif)
                        .foregroundStyle(.black)
                }
                .frame(height: geometry.size.height * 0.145)
                
                Rectangle()
                    .fill(.clear)
                    .background {
                        HStack {
                            Spacer()
                            Rectangle()
                                .foregroundStyle(.black.opacity(0.9))
                                .frame(width: geometry.size.width * 0.005)
                                .zIndex(1)
                        }
                    }
                    .overlay {
                        VStack(spacing: geometry.size.height * 0.02) {
                            Spacer(minLength: 0)
                            ForEach(Array(tasks.wrappedValue.reversed().enumerated()), id: \.element.id) { index, task in
                                
                                DraggableKanbanCard(
                                    task: task,
                                    geometry: geometry,
                                    cardDragStatus: $cardDragStatus,
                                    onDrag: { value in
                                        if draggedCard == nil {
                                            draggedCard = task
                                        }
                                        
                                        // Actualiza la posición global ajustada con el offset del arrastre
                                        let globalPosition = CGPoint(
                                            x: geometry.frame(in: .global).origin.x + value.translation.width,
                                            y: geometry.frame(in: .global).origin.y + value.translation.height
                                        )
                                        
                                        // Detecta si el drop sería válido o no usando la posición global
                                        self.cardDragStatus = isInValidDropArea(columnIndex: columnType.rawValue, location: globalPosition, geometry: geometry)
                                    },
                                    onEnded: { value in
                                        
                                        let globalPosition = CGPoint(
                                            x: geometry.frame(in: .global).origin.x + value.translation.width,
                                            y: geometry.frame(in: .global).origin.y + value.translation.height
                                        )

                                        handleCardDrop(columnIndex: columnType.rawValue, of: task, from: tasks, in: globalPosition, ofSize: geometry)
                                        draggedCard = nil
                                    })
                            }
                        }
                        .padding(.bottom, geometry.size.height * 0.05)
                        .padding(.leading, geometry.size.height * 0.035)
                        .padding(.trailing, geometry.size.height * 0.025)
                    }.zIndex(2)
            }
        }
    }
    
    private func isInValidDropArea(columnIndex: Int, location: CGPoint, geometry: GeometryProxy) -> DragStatus {
        let leadingOffset = geometry.size.width * 0.03
        let kanbanWidth = geometry.size.width * 0.994
        let columnWidth = (kanbanWidth) / 4
        let columnHeight = geometry.size.height * 0.75
        let cardHorizontalPadding = columnHeight * 0.015
        let cardWidth = columnWidth - cardHorizontalPadding * 2
        let cardCenter = location.x + cardWidth / 2
        let yInitKanbanBoardPosition = geometry.size.height * 0.27
        
        let isInYRange = location.y + yInitKanbanBoardPosition + cardWidth >= -yInitKanbanBoardPosition + cardWidth && location.y + yInitKanbanBoardPosition - 50 <= yInitKanbanBoardPosition + cardWidth
        let columnIndex = ((columnWidth * CGFloat(columnIndex) + cardCenter - leadingOffset) / kanbanWidth) * 4
        let isInXRange = columnIndex >= 0 && columnIndex <= 3.7
        let forceOutOfBounds = columnIndex <= -0.2 || columnIndex >= 3.7 || !isInYRange
        
        if forceOutOfBounds {
            return .outOfBounds
        }
        
        return switch (isInXRange, isInYRange) {
            case (true, true): .valid
            case (false, false): .outOfBounds
            default: .notAllowed
        }
    }
    
    private func handleCardDrop(columnIndex: Int, of card: KanbanTask, from cardList: Binding<[KanbanTask]>, in location: CGPoint, ofSize geometry: GeometryProxy) {
        if let index = cardList.wrappedValue.firstIndex(where: { $0 == card }) {
            let removedCard = cardList.wrappedValue.remove(at: index)
            
            if isInValidDropArea(columnIndex: columnIndex, location: location, geometry: geometry) == .valid {
                let leadingOffset = geometry.size.width * 0.03
                let kanbanWidth = geometry.size.width * 0.994
                let columnWidth = (kanbanWidth) / 4
                let cardCenter = location.x + (columnWidth - (geometry.size.height * 0.015) * 2) / 2
                let newColumnIndex = Int(((columnWidth * CGFloat(columnIndex) + cardCenter - leadingOffset) / kanbanWidth) * 4)
                
                switch newColumnIndex {
                case 0:
                    toDoTasks.append(removedCard)
                case 1:
                    inProgressTasks.append(removedCard)
                case 2:
                    testingTasks.append(removedCard)
                case 3:
                    doneTasks.append(removedCard)
                default:
                    cardList.wrappedValue.insert(removedCard, at: index) // Devolver a la lista original si no es válido
                }
                
            } else {
                // Devolver la tarjeta a la posición original si no es un drop válido
                cardList.wrappedValue.insert(removedCard, at: index)
            }
        }
    }
}

struct DraggableKanbanCard: View {
    let task: KanbanTask
    let geometry: GeometryProxy
    @Binding var cardDragStatus: KanbanColumn.DragStatus
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false

    let onDrag: (DragGesture.Value) -> Void
    let onEnded: (DragGesture.Value) -> Void

    var body: some View {
        KanbanCard(task: task)
            .overlay(
                Group {
                    let kanbanCardWidth = geometry.size.width * 0.21
                    if cardDragStatus == .notAllowed && isDragging {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.largeTitle)
                            .padding()
                            .position(x: kanbanCardWidth + 3, y: 3)
                    } else if cardDragStatus == .valid && isDragging {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.largeTitle)
                            .padding()
                            .position(x: kanbanCardWidth + 3, y: -3)
                    }
                }
            )
            .frame(depth: isDragging ? 30 : 4)
            .shadow(color: .black.opacity(isDragging ? 0.7 : 0.1), radius: isDragging ? 12 : 18, x: 0, y: isDragging ? geometry.size.height * 0.03 : geometry.size.height * 0.005)
            .frame(height: geometry.size.height * 0.13)
            .offset(dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        dragOffset = value.translation
                        onDrag(value)
                    }
                   
                    .onEnded { value in
                        isDragging = false
                        dragOffset = .zero
                        onEnded(value)
                    }
            )
            .zIndex(isDragging ? 1 : 0)
    }
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
