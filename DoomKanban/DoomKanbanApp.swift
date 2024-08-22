//
//  DoomKanbanApp.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 1/8/24.
//

import SwiftUI

@Observable
class KanbanAppVM: Equatable {
    static func == (lhs: KanbanAppVM, rhs: KanbanAppVM) -> Bool {
        return lhs.sprints == rhs.sprints && lhs.tasks == rhs.tasks
    }
    
    var sprints: [KanbanSprint]
    
    @ObservationIgnored private var originalTasks: [KanbanTask]
    private var tasks: [KanbanTask]

    init() {
        let sprints = Self.generateSprints()
        self.sprints = sprints

        // Asociar cada tarea con su sprintNum
        var tasksWithSprintNum: [(task: KanbanTask, sprintNum: Int)] = []
        for sprint in sprints {
            for task in sprint.tasks {
                tasksWithSprintNum.append((task: task, sprintNum: sprint.sprintNum))
            }
        }

        // Mezclar las tareas
        let shuffledTasksWithSprintNum = tasksWithSprintNum.shuffled()

        // Ordenar las tareas mezcladas por sprintNum
        let sortedTasks = shuffledTasksWithSprintNum.sorted(by: { $0.sprintNum < $1.sprintNum }).map { $0.task }

        // Asignar las tareas mezcladas y ordenadas
        originalTasks = sortedTasks
        tasks = sortedTasks
    }

    var mixedTasks: [KanbanTask] {
        get { tasks }
        set { tasks = newValue }
    }
    
    static func generateSprints() -> [KanbanSprint] {
        [
            KanbanSprint(project: 1, projectColor: .blue, sprintNum: 1, tasks: [
                KanbanTask(projectId: 1, sprintId: 1,title: "Esto es un test", color: .blue, value: 1, isFlagged: true),
                KanbanTask(projectId: 1, sprintId: 1,title: "Segunda tarea", color: .blue, value: 1),
                KanbanTask(projectId: 1, sprintId: 1,title: "Título: Tercera tarea", color: .blue, value: 1)
            ]),
            KanbanSprint(project: 1, projectColor: .blue, sprintNum: 2, tasks: [
                KanbanTask(projectId: 1, sprintId: 2,title: "Esto es un test", color: .blue, value: 3),
                KanbanTask(projectId: 1, sprintId: 2,title: "Segunda tarea", color: .blue, value: 4, isFlagged: true),
                KanbanTask(projectId: 1, sprintId: 2,title: "Título: Tercera tarea", color: .blue, value: 2)
            ]),
            KanbanSprint(project: 2, projectColor: .red, sprintNum: 1, tasks: [
                KanbanTask(projectId: 2, sprintId: 1,title: "Project 2 - Prueba 1", color: .red, value: 3, isWarningEnabled: true),
                KanbanTask(projectId: 2, sprintId: 1,title: "P2.Segunda tarea", color: .red, value: 4)
            ]),
            KanbanSprint(project: 3, projectColor: .yellow, sprintNum: 2, tasks: [
                KanbanTask(projectId: 3, sprintId: 2,title: "Esto es un test", color: .yellow, value: 3),
                KanbanTask(projectId: 3, sprintId: 2,title: "Segunda tarea", color: .yellow, value: 4),
                KanbanTask(projectId: 3, sprintId: 2,title: "Título: Tercera tarea", color: .yellow, value: 2, isWarningEnabled: true),
                KanbanTask(projectId: 3, sprintId: 2,title: "4: La tarea final", color: .yellow, value: 5)
            ])
        ]
    }
}

@main
struct DoomKanbanApp: App {
    @State var appVM: KanbanAppVM = KanbanAppVM()
    @State private var mixedTasks: [KanbanTask] = []
    
    // Hide bottom bar controls. We encourage the user to use the provided window size, but they will still be able to resize or move the window if they choose to.
    // This is also intended to hide the close button, which cannot be removed or disabled in VisionOS 2.0 and could disrupt our game.
    // Although we could attempt to reopen a new view after closing, this might interfere with our countdown logic and other features, so we have decided against it.
    // The user will be responsible for not closing their windows while playing.
    private var bottomWindowControlsVisibility: Visibility = .hidden
    @State private var points = 0
    
    var body: some Scene {
        WindowGroup(id: "KanbanBoard") {
            GeometryReader { geometry in
                DoomKanbanLayout()
                    .frame(width: geometry.size.width - 100, height: geometry.size.height - 100)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .kanbanVM($appVM)
                    .pointsCounter($points)
            }.keepAspectRatio()
        }
        .defaultSize(width: 1200, height: 1200)
        
        WindowGroup(id: "RunningSprints") {
            GeometryReader { geometry in
                SprintsLayoutView()
                    .frame(width: 320, height: max(geometry.size.height, 320))
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .kanbanVM($appVM)
            }
        }
        .windowStyle(.plain)
        .defaultSize(width: 320, height: 1000)
        .defaultWindowPlacement { content, context in
            if let mainWindow = context.windows.first(where: { $0.id == "KanbanBoard" }) {
                return WindowPlacement(.leading(mainWindow))
            } else {
                print("No window with ID 'main' found!")
                return WindowPlacement() // Use default placement if main window doesn't exist
            }
        }
        .persistentSystemOverlays(bottomWindowControlsVisibility)
        
        WindowGroup(id: "SkillsView") {
            SkillsView(skills: [
                SkillsView.Skill(icon: Image(.chrono), coolDown: 5, action: {}),
                SkillsView.Skill(icon: Image(.ancientKnoeledgeIlumination), coolDown: 10, action: {}),
                SkillsView.Skill(icon: Image(.augustWork), coolDown: 15, action: {})
            ], orientation: .vertical)
        }
        .windowStyle(.plain)
        .defaultSize(width: 320, height: 1200)
        .defaultWindowPlacement { content, context in
            if let mainWindow = context.windows.first(where: { $0.id == "KanbanBoard" }) {
                return WindowPlacement(.trailing(mainWindow))
            } else {
                print("No window with ID 'main' found!")
                return WindowPlacement() // Use default placement if main window doesn't exist
            }
        }
        .persistentSystemOverlays(bottomWindowControlsVisibility)
        
        ImmersiveSpace(id: "Points") {
            ExtrudedPointCounterImmersiveView()
                .pointsCounter($points)
        }.defaultSize(width: 1200, height: 1200)
//        WindowGroup(id: "MobileChat") {
//            FakeMobileChat()
//        }
//        .windowStyle(.plain)
//        .defaultSize(width: 150, height: 600)
//        .defaultWindowPlacement { content, context in
//            if let mainWindow = context.windows.first(where: { $0.id == "KanbanBoard" }) {
//                return WindowPlacement(.below(mainWindow))
//            } else {
//                print("No window with ID 'main' found!")
//                return WindowPlacement() // Use default placement if main window doesn't exist
//            }
//        }
////        .persistentSystemOverlays(bottomWindowControlsVisibility)
    }
}
