//
//  DoomKanbanApp.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 1/8/24.
//

import SwiftUI

extension Color {
    static let lime = Color(red: 0.75, green: 1.0, blue: 0.0)
    static let olive = Color(red: 0.5, green: 0.5, blue: 0.0)
    static let coral = Color(red: 1.0, green: 0.5, blue: 0.31)
    static let chartreuse = Color(red: 0.5, green: 1.0, blue: 0.0)
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
    static let silver = Color(red: 0.75, green: 0.75, blue: 0.75)
    static let plum = Color(red: 0.87, green: 0.63, blue: 0.87)
    static let violet = Color(red: 0.93, green: 0.51, blue: 0.93)
    static let navy = Color(red: 0.0, green: 0.0, blue: 0.5)
    static let peach = Color(red: 1.0, green: 0.85, blue: 0.73)
    static let aqua = Color(red: 0.0, green: 1.0, blue: 1.0)
    static let turquoise = Color(red: 0.25, green: 0.88, blue: 0.82)
    static let lavender = Color(red: 0.9, green: 0.9, blue: 0.98)
    static let scarlet = Color(red: 1.0, green: 0.14, blue: 0.0)
    static let crimson = Color(red: 0.86, green: 0.08, blue: 0.24)
    static let magenta = Color(red: 1.0, green: 0.0, blue: 1.0)
}

extension KanbanAppVM: Equatable {
    static func == (lhs: KanbanAppVM, rhs: KanbanAppVM) -> Bool {
        return lhs.sprints == rhs.sprints && lhs.mixedTasks == rhs.mixedTasks
    }
}

@Observable
class KanbanAppVM {
    init() {
        print("SE REINICIA EL KanbanAppVM 💩")
        self.sprints = []
        self.originalTasks = []
        self.mixedTasks = []
        toDoTasks = []
        inProgressTasks = []
        testingTasks = []
        doneTasks = []
        startNewRound()  // Inicializa la primera ronda al iniciar
        startWardenMonitoring()
    }

    var round: Int = 0
    let roundAdvanceModifier: CGFloat = 0.25
    
    var wardenIsWatching = false

    // --- Kanban Content -----
    var sprints: [KanbanSprint]
    @ObservationIgnored var originalTasks: [KanbanTask]
    var mixedTasks: [KanbanTask]
    
    @ObservationIgnored var draggedCard: KanbanTask?
    var toDoTasks: [KanbanTask]
    var inProgressTasks: [KanbanTask]
    var testingTasks: [KanbanTask]
    var doneTasks: [KanbanTask]
    // ------------------------ //

    
    // --- Task drop animation
    var nextTaskAnimationTime: CGFloat {
        return max(0.25, 2 - (roundAdvanceModifier / 2) * CGFloat(round))
    }
    var counter: CGFloat {
        return max(1, 3 - roundAdvanceModifier * CGFloat(round))
    }
    // ----------------------- //
}

// - MARK: KanbanBoard Content Generation
extension KanbanAppVM {
    func startNewRound() {
        round += 1
        sprints = KanbanAppVM.generateSprints(for: round)
        
        let shuffledTasksSortedBySprint = sprints.reduce(into: [KanbanTask]()) { result, sprint in
            result.append(contentsOf: sprint.tasks)
        }.shuffled().sorted(by: {$0.sprintId < $1.sprintId})
        
//        var tasksWithSprintNum: [(task: KanbanTask, sprintNum: Int)] = []
//        for sprint in sprints {
//            for task in sprint.tasks {
//                tasksWithSprintNum.append((task: task, sprintNum: sprint.sprintNum))
//            }
//        }
//
//        let shuffledTasksWithSprintNum = tasksWithSprintNum.shuffled()
//        let sortedTasks = shuffledTasksWithSprintNum.sorted(by: { $0.sprintNum < $1.sprintNum }).map { $0.task }

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
    
//    func startNewRound() {
//        round += 1
//        sprints = Self.generateSprints()
//        // Aquí puedes añadir lógica adicional para generar nuevos sprints o mezclar las tareas
//    }
    
    private func startWardenMonitoring() {
            Task {
                while true {
                    let watchTime = Double.random(in: 3...8)  // Tiempo que el Warden estará observando
                    wardenIsWatching = true
                    try await Task.sleep(nanoseconds: UInt64(watchTime * 1_000_000_000))
                    
                    wardenIsWatching = false
                    let restTime = Double.random(in: 6...20)  // Tiempo que el Warden estará inactivo
                    try await Task.sleep(nanoseconds: UInt64(restTime * 1_000_000_000))
                }
            }
        }
}

extension KanbanAppVM {
    @MainActor
    func update(task: KanbanTask) {
        if let index = toDoTasks.firstIndex(where: { $0.id == task.id }) {
            toDoTasks[index] = task
        } else if let index = inProgressTasks.firstIndex(where: { $0.id == task.id }) {
            inProgressTasks[index] = task
        } else if let index = testingTasks.firstIndex(where: { $0.id == task.id }) {
            testingTasks[index] = task
        } else if let index = doneTasks.firstIndex(where: { $0.id == task.id }) {
            doneTasks[index] = task
        }
//        print("👹 La task recivida es: \(task.isComplete) . Task updated inProgress and new state isComplete is: \(inProgressTasks.first(where: {task.id == $0.id})?.isComplete)")
    }
    
    @MainActor
    func performAction(on column: KanbanColumn.KanbanColumnType, action: (inout [KanbanTask]) -> Void) {
        switch column {
        case .ToDo:
            action(&toDoTasks)
        case .Doing:
            action(&inProgressTasks)
        case .Testing:
            action(&testingTasks)
        case .Done:
            action(&doneTasks)
        }
    }

    @MainActor
    func performActionWithResult<T>(on column: KanbanColumn.KanbanColumnType, action: (inout [KanbanTask]) -> T) -> T {
        switch column {
        case .ToDo:
            return action(&toDoTasks)
        case .Doing:
            return action(&inProgressTasks)
        case .Testing:
            return action(&testingTasks)
        case .Done:
            return action(&doneTasks)
        }
    }

    @MainActor
    func add(_ task: KanbanTask, to column: KanbanColumn.KanbanColumnType) {
        performAction(on: column) { taskList in
            taskList.append(task)
        }
    }
    
    @MainActor
    func updateTask(id: UUID, update: (inout KanbanTask) -> Void) {
        if let index = toDoTasks.firstIndex(where: { $0.id == id }) {
            update(&toDoTasks[index])
        } else if let index = inProgressTasks.firstIndex(where: { $0.id == id }) {
            update(&inProgressTasks[index])
        } else if let index = testingTasks.firstIndex(where: { $0.id == id }) {
            update(&testingTasks[index])
        } else if let index = doneTasks.firstIndex(where: { $0.id == id }) {
            update(&doneTasks[index])
        }
    }

    @MainActor
    func move(task: KanbanTask?, from initialColumn: KanbanColumn.KanbanColumnType, to finalColumn: KanbanColumn.KanbanColumnType, at index: Int? = nil) {
        if let task {
            remove(task, from: initialColumn)
            move(task: task, to: finalColumn, at: index)
        }
    }
    
    @MainActor
    func move(task: KanbanTask?, to finalColumn: KanbanColumn.KanbanColumnType, at index: Int? = nil) {
        if let task {
            performAction(on: finalColumn) { taskList in
                if let index {
                    taskList.insert(task, at: index)
                } else {
                    taskList.append(task)
                }
            }
        }
    }
    
    @MainActor
    func remove(_ task: KanbanTask, from column: KanbanColumn.KanbanColumnType) {
        performAction(on: column) { taskList in
            if let index = taskList.firstIndex(of: task) {
                taskList.remove(at: index)
            }
        }
    }
    
    @MainActor
    func remove(from column: KanbanColumn.KanbanColumnType, at index: Int) -> KanbanTask {
        performActionWithResult(on: column) { taskList in
            return taskList.remove(at: index)
        }
    }
    
}

@main
struct DoomKanbanApp: App {
    @State var appVM: KanbanAppVM = KanbanAppVM()
    @State private var mixedTasks: [KanbanTask] = []
    
    let defaultSize = Size3D(width: 2, height: 2, depth: 2)
    
    // Hide bottom bar controls. We encourage the user to use the provided window size, but they will still be able to resize or move the window if they choose to.
    // This is also intended to hide the close button, which cannot be removed or disabled in VisionOS 2.0 and could disrupt our game.
    // Although we could attempt to reopen a new view after closing, this might interfere with our countdown logic and other features, so we have decided against it.
    // The user will be responsible for not closing their windows while playing.
    private var bottomWindowControlsVisibility: Visibility = .hidden
    @State private var points = 0
    
    var body: some Scene {
        WindowGroup(id: "InitialMenu") {
                InitialMenuView()
        }
        .defaultSize(width: 1200, height: 1200)
        
        WindowGroup(id: "KanbanBoard") {
            GeometryReader { geometry in
                DoomKanbanLayout()
                    .frame(width: geometry.size.width - 100, height: geometry.size.height - 100)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .kanbanVM(appVM)
                    .pointsCounter($points)
            }.keepAspectRatio()
        }
        .defaultSize(width: 1200, height: 1200)
        
        ImmersiveSpace(id: "Points") {
            ExtrudedPointCounterImmersiveView()
                .pointsCounter($points)
        }.defaultSize(width: 1200, height: 1200)
        
        WindowGroup(id: "RunningSprints") {
            GeometryReader { geometry in
                SprintsLayoutView()
                    .frame(width: 320, height: max(geometry.size.height, 320))
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .kanbanVM(appVM)
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
        
        WindowGroup(id: "Shelf") {
            Shelf3DView(defaultSize: defaultSize)
        }
        .windowStyle(.volumetric)
        .defaultSize(defaultSize, in: .meters)
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


//extension Array {
//    mutating func removeFirst(where predicate: (Element) -> Bool) -> Element? {
//        if let index = firstIndex(where: predicate) {
//            return remove(at: index)
//        }
//        return nil
//    }
//}
