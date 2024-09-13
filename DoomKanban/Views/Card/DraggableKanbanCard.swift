//
//  DraggableKanbanCard.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 16/8/24.
//

import SwiftUI

struct DraggableKanbanCard: View {
    @State var task: KanbanTask
    let geometry: GeometryProxy
    let column: KanbanColumn.KanbanColumnType
    @Binding var cardDragStatus: KanbanColumn.DragStatus
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false
    private var isAutoCompleteEnabled: Bool
    private let activateFlagProbability: Bool

    let onDrag: (DragGesture.Value, KanbanTask) -> Void
    let onEnded: (DragGesture.Value, KanbanTask) -> Void

    @State private var progress: Double = 0.0
//    @Environment(\.mobileChatVisibility) private var isChatVisible
    @Environment(KanbanAppVM.self) var kanbanAppVM
//    @State private var timeRemaining: Int
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(
        task: KanbanTask,
        in column: KanbanColumn.KanbanColumnType,
        geometry: GeometryProxy,
        cardDragStatus: Binding<KanbanColumn.DragStatus>,
        autoComplete: Bool = true,
        activateFlagProbability: Bool = false,
        onDrag: @escaping (DragGesture.Value, KanbanTask) -> Void,
        onEnded: @escaping (DragGesture.Value, KanbanTask) -> Void
    ) {
        self.task = task
        self.column = column
        self.geometry = geometry
        self._cardDragStatus = cardDragStatus
        self.isAutoCompleteEnabled = autoComplete
        self.activateFlagProbability = activateFlagProbability
        self.onDrag = onDrag
        self.onEnded = onEnded
    }

    var body: some View {
        let cardHeight = geometry.size.height * 0.13
        
        KanbanCard(task: task)
            .hoverEffect { effect, isActive, proxy in
                effect.scaleEffect(isActive ? 0.9 : 1.0)
            }
            .background(
                AnimatedGradientStrokeView(progress: progress, lineWidth: cardHeight * 0.2)
                    .drawingGroup()
            )
            .frame(depth: isDragging ? 30 : 4)
            .shadow(color: .black.opacity(isDragging ? 0.7 : 0.1), radius: isDragging ? 12 : 18, x: 0, y: isDragging ? geometry.size.height * 0.03 : geometry.size.height * 0.005)
            .frame(height: cardHeight)
            .overlay(topRightDragAvailabilityIndicator)
            .offset(dragOffset)
            .scaleEffect(isDragging ? 1.2 : 1)
            .gesture(dragCardGesture)
            .simultaneousGesture(
                TapGesture()
                    .onEnded {
                        if kanbanAppVM.chatVisibility.0 != .visible, task.isFlagged {
                            kanbanAppVM.chatVisibility = (.visible, task)
                        }
                    }
            )
            .zIndex(isDragging ? 1 : 0)
            .onAppear {
                if task.value <= 0 || column == .Done {
                    stopTimer()
                }
                initializeCard()
                if column == .Done {
                    kanbanAppVM.points += task.value
                    task.value = 0
                }
            }
            .onChange(of: task.isFlagged) {
                if !task.isFlagged {
                    task.isComplete = true
                    kanbanAppVM.update(task: task)
                }
            }.onReceive(timer) { time in
                if task.value > 0 {
                    task.value -= 1
                }else {
                    stopTimer()
                    if column != .Done {
                        kanbanAppVM.remove(task, from: column)
                        kanbanAppVM.addWarning(causedBy: task)
                    }
                }
            }.onDisappear {
                stopTimer()
                kanbanAppVM.update(task: task)
            }
    }
    
    private func stopTimer() {
        self.timer.upstream.connect().cancel()
    }

    private var topRightDragAvailabilityIndicator: some View {
        let kanbanCardWidth = geometry.size.width * 0.21
        return Group {
            if cardDragStatus == .notAllowed && isDragging {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            } else if cardDragStatus == .valid && isDragging {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .font(.largeTitle)
        .padding()
        .position(x: kanbanCardWidth * 0.9 - 3)
    }

    private var dragCardGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isDragging = true
                }
                dragOffset = value.translation
                onDrag(value, task)
            }
            .onEnded { value in
                isDragging = false
                dragOffset = .zero
                print("onEnded -> isComplete:\(task.isComplete)")
                onEnded(value, task)
            }
    }

    @MainActor
    private func initializeCard() {
        task.isComplete = false
//        kanbanAppVM.update(task: task)
        print("onAppeear isComplete:\(kanbanAppVM.draggedCard?.isComplete)")
        startBackgroundStrokeAnimation()
        flagTask()
        complete()
    }

    @MainActor
    private func complete() {
        Task {
            guard !task.isFlagged, isAutoCompleteEnabled else { return }
            
            let maxCompletionTime = 5
            let completionTimeRange = CGFloat(kanbanAppVM.tasksAutocompletesFaster ? maxCompletionTime / 2 : maxCompletionTime)
            let completionTime = CGFloat.random(in: 1...completionTimeRange) * kanbanAppVM.roundAdvanceModifier * CGFloat(kanbanAppVM.round)
            try await Task.sleep(nanoseconds: UInt64(completionTime * 1_000_000_000))
            
            task.isComplete = true
            kanbanAppVM.update(task: task)
        }
    }

    @MainActor
    private func flagTask() {
        guard activateFlagProbability else { return }

        let unflaggedToFlaggedProbability: Float = 10
        let flaggedToUnflaggedProbability: Float = 3

        if task.isFlagged {
            if Bool.random(with: flaggedToUnflaggedProbability) {
                task.isFlagged = false
                task.isComplete = true
            }
        } else {
            if Bool.random(with: unflaggedToFlaggedProbability) {
                task.isFlagged = true
            }
        }
        kanbanAppVM.update(task: task)
    }

    private func startBackgroundStrokeAnimation() {
        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
            progress = 1.0
        }
    }
}


//struct ConditionalEmptyView<Content: View>: View {
//    let content: Content
//    let condition: () -> Bool
//
//    @ViewBuilder
//    var body: some View {
//        if condition() {
//            content
//        } else {
//            EmptyView()
//        }
//    }
//}
