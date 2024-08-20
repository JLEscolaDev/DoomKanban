//
//  KanbanColumn.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 16/8/24.
//

import SwiftUI

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
                                .padding(.leading, columnType == .ToDo ? geometry.size.width * 0.008 : 0)
                                .padding(.trailing, columnType != .ToDo ? geometry.size.width * 0.014 : 0)
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

#Preview {
    GeometryReader { geometry in
        KanbanColumn(columnType: .Done, title: "Done", headerColor: .green, tasks: .constant([.init(title: "Test card", color: .red, value: 3)]), geometry: geometry, toDoTasks: .constant([]), inProgressTasks: .constant([]), testingTasks: .constant([]), doneTasks: .constant([]))
    }.frame(width: 200, height: 600)
        .background(.white)
        .border(.black)
}
