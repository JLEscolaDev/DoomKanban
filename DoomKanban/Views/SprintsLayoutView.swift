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
                sprintsAlreadyDisplayedAsIndicators[i].tasks.removeAll { $0.id == task.id }
            }
        }
    }
    
    func createSprintList(geometry: GeometryProxy, kanbanVM: Bindable<KanbanAppVM>) -> some View {
//        GeometryReader { geometry in
            let indicatorHeight = geometry.size.width * 0.4
            let vstackSpacing: CGFloat = 40
            let totalHeightPerIndicator = indicatorHeight + vstackSpacing
            let verticalPadding = geometry.size.height * 0.1
            let availableHeight = geometry.size.height - verticalPadding
            // Calculate the maximum amount of indicators we can display based on layout height
            let maxIndicators = Int(availableHeight / totalHeightPerIndicator)
            
        let tasksToRemove = Array(kanbanVM.wrappedValue.mixedTasks.prefix(maxIndicators-1))
            removeTasks(tasksToRemove: tasksToRemove)
            return RoundedRectangle(cornerRadius: geometry.size.width * 0.1)
                .overlay {
                    VStack(spacing: vstackSpacing) {
                        ForEach(Array(kanbanVM.mixedTasks.prefix(maxIndicators - 1)), id: \.id) { task in
                            self.createIndicator(from: task.wrappedValue, with: geometry, and: indicatorHeight, kanbanVM: kanbanVM)
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
    
    func createIndicator(from task: KanbanTask, with geometry: GeometryProxy, and indicatorHeight: CGFloat, kanbanVM: Bindable<KanbanAppVM>) -> some View {
        if let sprint = kanbanVM.wrappedValue.sprints.first(where: { $0.tasks.contains(where: {$0.id == task.id}) }) {
            
            // Update local sCannotprints if the task is not already added so we can controll the indicator remaining tasks counting
            if let sprintIndex = sprintsAlreadyDisplayedAsIndicators.firstIndex(where: { $0.id == sprint.id }) {
                var sprintToUpdate = sprintsAlreadyDisplayedAsIndicators[sprintIndex]
                if !sprintToUpdate.tasks.contains(where: { $0.id == task.id }) {
                    sprintToUpdate.tasks.append(task)
                    sprintsAlreadyDisplayedAsIndicators[sprintIndex] = sprintToUpdate
                }
            } else {
                var newSprint = sprint
                newSprint.tasks = [task]
                sprintsAlreadyDisplayedAsIndicators.append(newSprint)
            }
            
            let shownTasksCount = sprintsAlreadyDisplayedAsIndicators.first(where: { $0.id == sprint.id })?.tasks.count ?? 0
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
extension Collection {
  func enumeratedArray() -> Array<(offset: Int, element: Self.Element)> {
    return Array(self.enumerated())
  }
}

struct SprintsLayoutView: View {
    @Environment(KanbanAppVM.self) var kanbanVM
    @State private var localVM: SprintsViewModel = SprintsViewModel()
    @State private var lastVisibleItemIndex: Int? = nil

    var body: some View {
        @Bindable var kanbanVMBinding = kanbanVM
        GeometryReader { geometry in
//            let indicatorHeight = geometry.size.width * 0.4
//            let vstackSpacing: CGFloat = 40
//            let totalHeightPerIndicator = indicatorHeight + vstackSpacing
//            let verticalPadding = geometry.size.height * 0.1
//            let availableHeight = geometry.size.height - verticalPadding
            // Calculate the maximum amount of indicators we can display based on layout height
//            let maxIndicators = Int(availableHeight / totalHeightPerIndicator)
            
            localVM.createSprintList(geometry: geometry, kanbanVM: $kanbanVMBinding)
            // Clean tasks added locally to modify the remaining tasks counting for each indicator so that tasks already added do not show an incorrect count and local subtraction is done correctly after the view is refreshed
            
        }.onChange(of: kanbanVM.round) {
            // When we start a new round, we re-init the localVM to avoid issues with previous data
            localVM = SprintsViewModel()
        }
    }
    
    
}

#Preview {
    SprintsLayoutView().frame(width: 150, height: 700)
        .environment(KanbanAppVM())
}
