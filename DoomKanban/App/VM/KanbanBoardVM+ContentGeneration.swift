//
//  KanbanBoard+ContentGeneration.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 15/9/24.
//

import SwiftUI

// - MARK: KanbanBoard Content Generation
extension KanbanAppVM {
    func reset() {
        self.points = 0
        self.round = 0
        self.wardenIsWatching = false
        self.chatVisibility = (.hidden, nil)
        self.warningList = []

        // Reset kanban board state
        self.sprints.removeAll()
        self.originalTasks.removeAll()
        self.mixedTasks.removeAll()
        self.toDoTasks.removeAll()
        self.inProgressTasks.removeAll()
        self.testingTasks.removeAll()
        self.doneTasks.removeAll()

        // Restart logic
        startNewRound()
        startWardenMonitoring()
    }
    
    func startNewRound() {
        warningList.removeAll()
        round += 1
        sprints = KanbanAppVM.generateSprints(for: round)
        
        let shuffledTasksSortedBySprint = sprints.reduce(into: [KanbanTask]()) { result, sprint in
            result.append(contentsOf: sprint.tasks)
        }.shuffled().sorted(by: {$0.sprintId < $1.sprintId})

        originalTasks = shuffledTasksSortedBySprint
        mixedTasks = shuffledTasksSortedBySprint
    }

    static func generateSprints(for round: Int) -> [KanbanSprint] {
        let totalTasks = Int.random(in: 12...15) * round
        var taskList = [KanbanTask]()
        var sprints: [KanbanSprint] = []
        guard let url = Bundle.main.url(forResource: "TasksTitles", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let tasksTitles = try? JSONDecoder().decode([String].self, from: data) else {
            fatalError("No se pudieron cargar los mensajes del JSON")
        }
        
        taskList.append(contentsOf:(1...totalTasks).map {_ in
            let minTimeValueToCompleteTask = 5
            let randomTitle = tasksTitles.randomElement() ?? "No title"
            let timeToCompleteTask = max(Int.random(in: 10...20) - (round / 2), minTimeValueToCompleteTask)
            return KanbanTask(projectId: -1, sprintId: -1, title: randomTitle, color: .red, value: timeToCompleteTask, isWarningEnabled: Bool.random(with: 8), isFlagged: Bool.random(with: 4))
        })
        
        var colors: [Color] = [
            .blue, .red, .yellow, .green, .orange, .purple, .pink, .teal, .indigo, .brown,
            .mint, .cyan, .magenta, .gray, .lime, .olive, .coral,
            .chartreuse, .gold, .silver, .plum, .violet, .navy, .peach, .aqua, .turquoise,
            .lavender, .scarlet, .crimson
        ]
        /// [ProjectId : Color]
        var colorsForProject: [Int: Color] = [:]
        
        // Iterate through all tasks until all are asigned to sprints
        repeat {
            let projectId = Int.random(in: 1...round)
            let sprintId = sprints.count + 1
            // Get new color (linked to project) and remove it from the list so it won't be reused
            var sprintColor = colorsForProject[projectId]
            if sprintColor == nil {
                let newColorForProject = colors.randomElement() ?? .red
                colorsForProject[projectId] = newColorForProject
                sprintColor = newColorForProject
                colors.removeAll {$0 == sprintColor}
            }
            
            var sprintTasks = [KanbanTask]()
            let numberOfTasksInSprint = Int.random(in: 3...6)
            let tasksForThisSprint = min(numberOfTasksInSprint, taskList.count)
            
            // Generate the tasks that will have our sprint
            let tasksIndexRange = 0..<tasksForThisSprint
            sprintTasks.append(contentsOf: (tasksIndexRange).map { taskIndex in
                taskList[taskIndex].projectId = projectId
                taskList[taskIndex].sprintId = sprintId
                taskList[taskIndex].color = sprintColor!
                
                return taskList[taskIndex]
            })
            // Remove the tasks from the taskList for the next iteration
            taskList.removeSubrange(tasksIndexRange)
            
            let sprint = KanbanSprint(
                project: projectId,
                projectColor: sprintColor!,
                sprintNum: sprintId,
                tasks: sprintTasks
            )
            // Append the new sprint to the sprint list
            sprints.append(sprint)
        }while !taskList.isEmpty
        
        return sprints
    }
    
    func startWardenMonitoring() {
        Task {
            while true {
                if round > 2 {
                    let watchTime = Double.random(in: 3...8)  // Tiempo que el Warden estará observando
                    wardenIsWatching = true
                    try await Task.sleep(nanoseconds: UInt64(watchTime * 1_000_000_000))
                }
                
                wardenIsWatching = false
                let restTime = Double.random(in: 6...20)  // Tiempo que el Warden estará inactivo
                try await Task.sleep(nanoseconds: UInt64(restTime * 1_000_000_000))
            }
        }
    }
    
    func addWarning(causedBy task: KanbanTask) {
        let projectId = task.projectId
        var numberOfWarningsToAdd = 1
        if task.isWarningEnabled {
            numberOfWarningsToAdd *= 2
        }
        if self.wardenIsWatching {
            numberOfWarningsToAdd *= 2
        }
        var warningInfo = self.warningList.getOrCreate(id: projectId)
        warningInfo.numberOfWarnings += numberOfWarningsToAdd
        warningInfo.projectColor = task.color
        
        // Actualizamos el array con el nuevo valor
        self.warningList.update(warningInfo)
    }
}
