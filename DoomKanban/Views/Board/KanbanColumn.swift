//
//  KanbanColumn.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 16/8/24.
//

import SwiftUI

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
    
    let geometry: GeometryProxy
    @State private var draggedCard: KanbanTask?

    // Computed binding property
//    private var tasksBinding: Binding<[KanbanTask]> {
//        switch columnType {
//        case .ToDo:
//            return $kanbanVM.toDoTasks
//        case .Doing:
//            return $kanbanVM.inProgressTasks
//        case .Testing:
//            return $kanbanVM.testingTasks
//        case .Done:
//            return $kanbanVM.doneTasks
//        }
//    }
    @Environment(\.kanban) private var kanbanVM

    var body: some View {
//        print("Tipo: \(columnType), valor: \(tasksBinding.wrappedValue.count)")
//        @Bindable var kanbanVM: KanbanAppVM
        var tasks: [KanbanTask] {
            switch columnType {
            case .ToDo:
                return kanbanVM.toDoTasks
            case .Doing:
                return kanbanVM.inProgressTasks
            case .Testing:
                return kanbanVM.testingTasks
            case .Done:
                return kanbanVM.doneTasks
            }
        }
        return HStack(alignment: .top, spacing: 0) {
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
                            if tasks.count < 5 && tasks.count > 0 {
                                ForEach(tasks.reversed()) { task in
                                    DraggableKanbanCard(
                                        task: task,
                                        geometry: geometry,
                                        cardDragStatus: $cardDragStatus,
                                        autoComplete: columnType == .ToDo || columnType == .Done ? false : true,
                                        activateFlagProbability: columnType == .Testing,
                                        onDrag: { value in
                                            if draggedCard == nil {
                                                draggedCard = task
                                                kanbanVM.draggedCard = task
                                                print("ENTRA")
                                            }
                                            let globalPosition = CGPoint(
                                                x: geometry.frame(in: .global).origin.x + value.translation.width,
                                                y: geometry.frame(in: .global).origin.y + value.translation.height
                                            )
                                            self.cardDragStatus = isInValidDropArea(columnIndex: columnType.rawValue, task: task, location: globalPosition, geometry: geometry)
                                        },
                                        onEnded: { value in
                                            let globalPosition = CGPoint(
                                                x: geometry.frame(in: .global).origin.x + value.translation.width,
                                                y: geometry.frame(in: .global).origin.y + value.translation.height
                                            )
                                            handleCardDrop(columnIndex: columnType.rawValue, from: tasks, in: globalPosition, ofSize: geometry)
                                            draggedCard = nil
                                            kanbanVM.draggedCard = nil
                                        }
                                    )
                                    .padding(.leading, columnType == .ToDo ? geometry.size.width * 0.008 : 0)
                                    .padding(.trailing, columnType != .ToDo ? geometry.size.width * 0.014 : 0)
                                }
                            }
                        }
                        .padding(.bottom, geometry.size.height * 0.05)
                        .padding(.leading, geometry.size.height * 0.035)
                        .padding(.trailing, geometry.size.height * 0.025)
                    }
                    .zIndex(2)
            }
        }
        .onAppear {
            // Sync tasks with the initial state of the view
//            updateTasks()
        }
    }

//    private func updateTasks() {
//        tasks = switch columnType {
//        case .ToDo:
//            kanbanVM.toDoTasks
//        case .Doing:
//            kanbanVM.inProgressTasks
//        case .Testing:
//            kanbanVM.testingTasks
//        case .Done:
//            kanbanVM.doneTasks
//        }
//    }
    @MainActor
    /// Validates when the user is dragging over a valid area to drop cards and return DragStatus to notify the user (with an indicator) when and where he can drop the card.
    private func isInValidDropArea(columnIndex: Int, task: KanbanTask, location: CGPoint, geometry: GeometryProxy) -> DragStatus {
        let leadingOffset = geometry.size.width * 0.03
        let kanbanWidth = geometry.size.width * 0.994
        let columnWidth = (kanbanWidth) / 4
        let columnHeight = geometry.size.height * 0.75
        let cardHorizontalPadding = columnHeight * 0.015
        let cardWidth = columnWidth - cardHorizontalPadding * 2
        let cardCenter = location.x + cardWidth / 2
        let yInitKanbanBoardPosition = geometry.size.height * 0.27

        let isInYRange = location.y + yInitKanbanBoardPosition + cardWidth >= -yInitKanbanBoardPosition + cardWidth && location.y + yInitKanbanBoardPosition - 50 <= yInitKanbanBoardPosition + cardWidth
        let newColumnIndex = ((columnWidth * CGFloat(columnIndex) + cardCenter - leadingOffset) / kanbanWidth) * 4
        let isInXRange = newColumnIndex >= 0 && newColumnIndex <= 3.8
        let forceOutOfBounds = newColumnIndex <= -0.2 || newColumnIndex >= 3.8 || !isInYRange

        let isFlaggedTaskInTestingTryingToMoveBackwards = newColumnIndex < CGFloat(columnIndex) && !task.isFlagged
        let isFlaggedTaskTryingToMoveToDone = columnIndex == 2 && newColumnIndex > 3.8 && task.isFlagged
        let notFlaggedTaskAndIncompleteTryingToMove = !task.isFlagged && !task.isComplete && columnIndex != 0
        let forceForbidden = isFlaggedTaskInTestingTryingToMoveBackwards || isFlaggedTaskTryingToMoveToDone || notFlaggedTaskAndIncompleteTryingToMove
        
        /// An offset that we apply so the card is dragged in the correct column when its center is closer to that column (example: column 2 is in the drag range of 2-0.05 and 3-0.05)
        let userExperienceKanbanDropAreaOffset = 0.05
        let newColumnIsInProgress = ((Double(KanbanColumnType.Doing.rawValue)-userExperienceKanbanDropAreaOffset)...(Double(KanbanColumnType.Testing.rawValue)-userExperienceKanbanDropAreaOffset)) ~= newColumnIndex
        let newColumnIsTesting = ((Double(KanbanColumnType.Testing.rawValue)-userExperienceKanbanDropAreaOffset)...(Double(KanbanColumnType.Done.rawValue)-userExperienceKanbanDropAreaOffset)) ~= newColumnIndex
        
        /// We dont allow moving to inProgress or Testing columns when they are full (to avoid the user to clean all the column and getting a warning. This is a UX decision to avoid drag and drop where you don't want avoiding unnecessary frustration)
        let isTryingToMoveACardFromToDoToInProgressOrTesting = columnIndex < 2 && (newColumnIsInProgress || newColumnIsTesting)
        if isTryingToMoveACardFromToDoToInProgressOrTesting {
            let isMovingToNotAllowedFullColumn = newColumnIsInProgress ? kanbanVM.inProgressTasks.count == 4 : newColumnIsTesting ? kanbanVM.testingTasks.count == 4 : false
            if isMovingToNotAllowedFullColumn {
                return .notAllowed
            }
        }
        
        if columnIndex < 2 && newColumnIndex > 2.6 {
            return .notAllowed
        }

        if forceForbidden {
            return .notAllowed
        }

        if forceOutOfBounds {
            return .outOfBounds
        }

        return switch (isInXRange, isInYRange) {
        case (true, true): .valid
        case (false, false): .outOfBounds
        default: .notAllowed
        }
    }

    @MainActor
    /// Handles the logic of the card movement between the different KanbanColumns calculating based on the drag values, which should be the next column.
    private func handleCardDrop(columnIndex: Int, from cardList: [KanbanTask], in location: CGPoint, ofSize geometry: GeometryProxy) {
        if let index = cardList.firstIndex(where: { $0 == draggedCard }) {
            let removedCard = kanbanVM.remove(from: KanbanColumnType(rawValue: columnIndex) ?? .ToDo, at: index)
            
            if isInValidDropArea(columnIndex: columnIndex, task: removedCard, location: location, geometry: geometry) == .valid {
                let leadingOffset = geometry.size.width * 0.03
                let kanbanWidth = geometry.size.width * 0.994
                let columnWidth = (kanbanWidth) / 4
                let cardCenter = location.x + (columnWidth - (geometry.size.height * 0.015) * 2) / 2
                let calculatedColumnIndex = ((columnWidth * CGFloat(columnIndex) + cardCenter - leadingOffset) / kanbanWidth) * 4

                // The card can be dropped in the nearest column based on the percentage of card inside the column. (The card will move to a column if most of it is on that column)
                let lowerBound = CGFloat(Int(calculatedColumnIndex))
                let upperBound = lowerBound + 0.95
                let newColumnIndex = (lowerBound...upperBound) ~= calculatedColumnIndex ? Int(lowerBound) : Int(lowerBound) + 1

                print("column: \(columnIndex), new: \(newColumnIndex)")
                switch newColumnIndex {
                case 0...3:
                        kanbanVM.move(task: kanbanVM.draggedCard, to: KanbanColumnType(rawValue: newColumnIndex) ?? .ToDo)
                    fallthrough
                case 2:
                    // We allow moving directly from ToDo to testing but the task increases its error probability and will require using chat to resolve the task flag.
                    if columnIndex == 0, newColumnIndex == 2 {
                        if Bool.random(with: 90) {
                            kanbanVM.updateTask(id: removedCard.id) { task in
                                task.isFlagged = true
                            }
                        }
                    }
                default:
                        // Revert to the original list if the drop is not valid
                        kanbanVM.move(task: kanbanVM.draggedCard, to: KanbanColumnType(rawValue: columnIndex) ?? .ToDo, at: index)
//                    cardList.insert(removedCard, at: index)
                }
            } else {
                // Return the card to its original position if the drop is not valid
                kanbanVM.move(task: kanbanVM.draggedCard, to: KanbanColumnType(rawValue: columnIndex) ?? .ToDo, at: index)
//                cardList.insert(removedCard, at: index)
            }
        }
    }
}

//#Preview {
//    GeometryReader { geometry in
//        KanbanColumn(columnType: .Done, title: "Done", headerColor: .green, kanbanVM: <#Bindable<KanbanAppVM>#>, geometry: geometry)
//    }.frame(width: 200, height: 600)
//        .background(.white)
//        .border(.black)
//}
