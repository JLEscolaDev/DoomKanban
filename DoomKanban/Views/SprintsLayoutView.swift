//
//  ContentView.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 1/8/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

@Observable
class SprintsViewModel {
    // local variable to manage remaining tasks displayed in each indicator. It is importante to not observe changes so we dont refresh the view.
    @ObservationIgnored var sprintsAlreadyDisplayedAsIndicators: [KanbanSprint] = []
    
    func removeTasks(tasksToRemove: [KanbanTask]) {
        for task in tasksToRemove {
            // Iterate over each sprint and delete only matching tasks
            for i in 0..<sprintsAlreadyDisplayedAsIndicators.count {
                sprintsAlreadyDisplayedAsIndicators[i].tasks.removeAll { $0 == task }
            }
        }
    }
}
extension Collection {
  func enumeratedArray() -> Array<(offset: Int, element: Self.Element)> {
    return Array(self.enumerated())
  }
}

struct SprintsLayoutView: View {
    @Environment(\.kanban) private var kanbanVM
    @State private var localVM: SprintsViewModel = SprintsViewModel()
    @State private var lastVisibleItemIndex: Int? = nil

    var body: some View {
        GeometryReader { geometry in
            let indicatorHeight = geometry.size.width * 0.4
            let vstackSpacing: CGFloat = 40
            let totalHeightPerIndicator = indicatorHeight + vstackSpacing
            let verticalPadding = geometry.size.height * 0.1
            let availableHeight = geometry.size.height - verticalPadding
            // Calculate the maximum amount of indicators we can display based on layout height
            let maxIndicators = Int(availableHeight / totalHeightPerIndicator)
            
            createSprintList(geometry: geometry)
            // Clean tasks added locally to modify the remaining tasks counting for each indicator so that tasks already added do not show an incorrect count and local subtraction is done correctly after the view is refreshed
            
        }
//        GeometryReader { geometry in
//            let indicatorHeight = geometry.size.width * 0.4
//            let vstackSpacing: CGFloat = 40
//
//            ScrollView {
//                VStack(spacing: vstackSpacing) {
//                    ForEach(Array(kanbanVM.mixedTasks.enumeratedArray()), id: \.element.id) { index, task in
////                        let taskBinding = kanbanVM.mixedTasks[index]
//                        if let sprint = kanbanVM.sprints.first(where: { $0.tasks.contains(task) }) {
//
//                            // Update local sprints if the task is not already added
//                            if let sprintIndex = localVM.sprintsAlreadyDisplayedAsIndicators.firstIndex(where: { $0.id == sprint.id }) {
//                                var sprintToUpdate = localVM.sprintsAlreadyDisplayedAsIndicators[sprintIndex]
//                                if !sprintToUpdate.tasks.contains(where: { $0 == task }) {
//                                    sprintToUpdate.tasks.append(task)
//                                    localVM.sprintsAlreadyDisplayedAsIndicators[sprintIndex] = sprintToUpdate
//                                }
//                            } else {
//                                var newSprint = sprint
//                                newSprint.tasks = [task]
//                                localVM.sprintsAlreadyDisplayedAsIndicators.append(newSprint)
//                            }
//
//                            let shownTasksCount = localVM.sprintsAlreadyDisplayedAsIndicators.first(where: { $0.id == sprint.id })?.tasks.count ?? 0
//                            let remainingTasks = sprint.tasks.count + 1 - shownTasksCount
//
//                            let indicator = VStack {
//                                Text("Project \(sprint.project)")
//                                    .foregroundStyle(.black)
//                                    .font(.system(size: geometry.size.width * 0.05))
//                                RunningSprintIndicatorView(RunningSprintVM(sprint: sprint, customRemainingTasksCount: remainingTasks))
//                                    .frame(width: geometry.size.width * 0.6, height: indicatorHeight)
//                                    .frame(depth: 5)
//                            }.overlay(
//                                GeometryReader { geo in
//                                    Color.clear
//                                        .onAppear {
//                                            if index == kanbanVM.mixedTasks.count - 1 {
//                                                let itemIsVisible = geo.frame(in: .global).maxY < UIScreen.main.bounds.height
//                                                if itemIsVisible {
//                                                    lastVisibleItemIndex = index
//                                                }
//                                            }
//                                        }
//                                }
//                            )
//
//                            AnyView(indicator)
//                        } else {
//                            AnyView(EmptyView())
//                        }
//                    }
//
//                    // This view serves as an indicator if the last item isn't fully visible
//                    if lastVisibleItemIndex == nil {
//                        Spacer()
//                        Image(systemName: "ellipsis")
//                            .font(.system(size: geometry.size.width * 0.3))
//                            .foregroundStyle(.gray)
//                        Spacer()
//                    }
//                }
//                .padding()
//            }
//        }
//        .onAppear {
//            if kanbanVM.mixedTasks.count > 0, let lastVisibleIndex = lastVisibleItemIndex {
//                let tasksToRemove = Array(kanbanVM.mixedTasks.prefix(lastVisibleIndex + 1))
//                localVM.removeTasks(tasksToRemove: tasksToRemove)
//            }
//        }
    }
    
    private func createSprintList(geometry: GeometryProxy) -> some View {
//        GeometryReader { geometry in
            let indicatorHeight = geometry.size.width * 0.4
            let vstackSpacing: CGFloat = 40
            let totalHeightPerIndicator = indicatorHeight + vstackSpacing
            let verticalPadding = geometry.size.height * 0.1
            let availableHeight = geometry.size.height - verticalPadding
            // Calculate the maximum amount of indicators we can display based on layout height
            let maxIndicators = Int(availableHeight / totalHeightPerIndicator)
            
            let tasksToRemove = Array(kanbanVM.mixedTasks.prefix(maxIndicators-1))
            localVM.removeTasks(tasksToRemove: tasksToRemove)
            return RoundedRectangle(cornerRadius: geometry.size.width * 0.1)
                .overlay {
                    VStack(spacing: vstackSpacing) {
                        ForEach(Array(kanbanVM.mixedTasks.prefix(maxIndicators - 1)), id: \.id) { task in
                            createIndicator(from: task, with: geometry, and: indicatorHeight)
                        }
                        
                        Spacer()
                        
                        if kanbanVM.mixedTasks.count > maxIndicators {
                            Image(systemName: "ellipsis")
                                .font(.system(size: geometry.size.width * 0.3))
                                .foregroundStyle(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, verticalPadding / 2)
                }
//        }
    }
    
    private func createIndicator(from task: KanbanTask, with geometry: GeometryProxy, and indicatorHeight: CGFloat) -> some View {
        if let sprint = kanbanVM.sprints.first(where: { $0.tasks.contains(task) }) {
            
            // Update local sCannotprints if the task is not already added so we can controll the indicator remaining tasks counting
            if let sprintIndex = localVM.sprintsAlreadyDisplayedAsIndicators.firstIndex(where: { $0.id == sprint.id }) {
                var sprintToUpdate = localVM.sprintsAlreadyDisplayedAsIndicators[sprintIndex]
                if !sprintToUpdate.tasks.contains(where: { $0.id == task.id }) {
                    sprintToUpdate.tasks.append(task)
                    localVM.sprintsAlreadyDisplayedAsIndicators[sprintIndex] = sprintToUpdate
                }
            } else {
                var newSprint = sprint
                newSprint.tasks = [task]
                localVM.sprintsAlreadyDisplayedAsIndicators.append(newSprint)
            }
            
            let shownTasksCount = localVM.sprintsAlreadyDisplayedAsIndicators.first(where: { $0.id == sprint.id })?.tasks.count ?? 0
            // We always add a +1 because we don't want to display 0 taks remaining when the last task is going to appear/fall/animate.
            let remainingTasks = sprint.tasks.count+1 - shownTasksCount
            
            let indicator = VStack {
                Text("Project \(sprint.project)")
                    .foregroundStyle(.black)
                    .font(.system(size: geometry.size.width * 0.05))
                RunningSprintIndicatorView(RunningSprintVM(sprint: sprint, customRemainingTasksCount: remainingTasks))
                    .frame(width: geometry.size.width * 0.6, height: indicatorHeight)
                    .frame(depth: 5)
            }
            
            return AnyView(indicator)
        }
        else {
            return AnyView(EmptyView())
        }
    }
}

#Preview {
    SprintsLayoutView().frame(width: 150, height: 700)
        .kanbanVM(KanbanAppVM())
}
