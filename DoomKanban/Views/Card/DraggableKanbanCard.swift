//
//  DraggableKanbanCard.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 16/8/24.
//

import SwiftUI

struct DraggableKanbanCard: View {
    @Environment(KanbanAppVM.self) var kanbanAppVM

    @State private var vm: KanbanCardViewModel
    let geometry: GeometryProxy
    @Binding var cardDragStatus: KanbanColumn.DragStatus
    let onDrag: (DragGesture.Value, KanbanTask) -> Void
    let onEnded: (DragGesture.Value, KanbanTask) -> Void

    init(
        vm: KanbanCardViewModel,
        geometry: GeometryProxy,
        cardDragStatus: Binding<KanbanColumn.DragStatus>,
        onDrag: @escaping (DragGesture.Value, KanbanTask) -> Void,
        onEnded: @escaping (DragGesture.Value, KanbanTask) -> Void
    ) {
        self.vm = vm
        self.geometry = geometry
        self._cardDragStatus = cardDragStatus
        self.onDrag = onDrag
        self.onEnded = onEnded
    }

    var body: some View {
        let cardHeight = geometry.size.height * 0.13

        KanbanCard(task: vm.task)
            .hoverEffect { effect, isActive, proxy in
                effect.scaleEffect(isActive ? 0.9 : 1.0)
            }
            .background(cardBackground(cardHeight: cardHeight))
            .frame(depth: vm.isDragging ? 30 : 4)
            .shadow(color: shadowColor(), radius: shadowRadius(), x: 0, y: shadowYOffset())
            .frame(height: cardHeight)
            .overlay(topRightDragAvailabilityIndicator)
            .offset(vm.dragOffset)
            .scaleEffect(vm.isDragging ? 1.2 : 1)
            .gesture(dragCardGesture())
            .simultaneousGesture(tapGesture())
            .zIndex(vm.isDragging ? 1 : 0)
            .onAppear { handleOnAppear() }
            .onChange(of: vm.task.isFlagged) { handleTaskFlagChange() }
            .onReceive(vm.timer) { _ in handleTimerUpdate() }
            .onDisappear { handleOnDisappear() }
    }
    
    /// View displayed on the top right corner of the card that shows the user when drop is allowed
    private var topRightDragAvailabilityIndicator: some View {
        let kanbanCardWidth = geometry.size.width * 0.21
        return Group {
            if cardDragStatus == .notAllowed && vm.isDragging {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            } else if cardDragStatus == .valid && vm.isDragging {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .font(.largeTitle)
        .padding()
        .position(x: kanbanCardWidth * 0.9 - 3)
    }
}

// - MARK: Card events and life cycle
extension DraggableKanbanCard {
    private func handleOnAppear() {
        if vm.task.value <= 0 || vm.column == .Done {
            vm.stopTimer()
        }
        initializeCard()
        if vm.column == .Done {
            kanbanAppVM.points += vm.task.value
            vm.task.value = 0
        }
    }
    
    private func tapGesture() -> some Gesture {
        TapGesture()
            .onEnded {
                if kanbanAppVM.removeAllTasksFromSelectedProject {
                    kanbanAppVM.removeAllTasksFrom(project: vm.task.projectId)
                } else if kanbanAppVM.chatVisibility.0 != .visible, vm.task.isFlagged {
                    kanbanAppVM.chatVisibility = (.visible, vm.task)
                }
            }
    }
    
    private func dragCardGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation(.easeInOut(duration: 0.1)) {
                    vm.isDragging = true
                }
                vm.dragOffset = value.translation
                onDrag(value, vm.task)
            }
            .onEnded { value in
                vm.isDragging = false
                vm.dragOffset = .zero
                onEnded(value, vm.task)
            }
    }

    private func handleTaskFlagChange() {
        if !vm.task.isFlagged {
            vm.task.isComplete = true
            kanbanAppVM.update(task: vm.task)
        }
    }
    
    func handleTimerUpdate() {
        if vm.task.value > 0 {
            vm.task.value -= 1
        } else {
            vm.stopTimer()
            if vm.column != .Done {
                kanbanAppVM.remove(vm.task, from: vm.column)
                kanbanAppVM.addWarning(causedBy: vm.task)
            }
        }
    }

    private func handleOnDisappear() {
        vm.stopTimer()
        kanbanAppVM.update(task: vm.task)
    }
}

// - MARK: KanbanCard modifiers
extension DraggableKanbanCard {
    private func cardBackground(cardHeight: CGFloat) -> some View {
        AnimatedGradientStrokeView(progress: vm.progress, lineWidth: cardHeight * 0.2)
            .drawingGroup()
    }

    private func shadowColor() -> Color {
        .black.opacity(vm.isDragging ? 0.7 : 0.1)
    }

    private func shadowRadius() -> CGFloat {
        vm.isDragging ? 12 : 18
    }

    private func shadowYOffset() -> CGFloat {
        vm.isDragging ? geometry.size.height * 0.03 : geometry.size.height * 0.005
    }
    
    private func startBackgroundStrokeAnimation() {
        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
            vm.progress = 1.0
        }
    }
}

// - MARK: Card state modification
extension DraggableKanbanCard {
    @MainActor
    private func initializeCard() {
        vm.task.isComplete = false
        startBackgroundStrokeAnimation()
        flagTask()
        complete()
    }

    @MainActor
    private func complete() {
        Task {
            guard !vm.task.isFlagged, vm.isAutoCompleteEnabled else { return }
            
            let maxCompletionTime = 5
            let completionTimeRange = CGFloat(kanbanAppVM.tasksAutocompletesFaster ? maxCompletionTime / 2 : maxCompletionTime)
            let completionTime = CGFloat.random(in: 1...completionTimeRange) * kanbanAppVM.roundAdvanceModifier * CGFloat(kanbanAppVM.round)
            try await Task.sleep(nanoseconds: UInt64(completionTime * 1_000_000_000))
            
            vm.task.isComplete = true
            kanbanAppVM.update(task: vm.task)
        }
    }

    @MainActor
    private func flagTask() {
        guard vm.activateFlagProbability else { return }

        let unflaggedToFlaggedProbability: Float = 10
        let flaggedToUnflaggedProbability: Float = 3

        if vm.task.isFlagged {
            if Bool.random(with: flaggedToUnflaggedProbability) {
                vm.task.isFlagged = false
                vm.task.isComplete = true
            }
        } else {
            if Bool.random(with: unflaggedToFlaggedProbability) {
                vm.task.isFlagged = true
            }
        }
        kanbanAppVM.update(task: vm.task)
    }
}
