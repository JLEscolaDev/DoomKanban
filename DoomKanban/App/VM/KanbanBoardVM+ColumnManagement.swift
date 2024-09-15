//
//  KanbanBoardVM+ColumnManagement.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 15/9/24.
//

import Foundation

// - MARK: KanbanBoard Column Management
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
        } else if let draggedCard, draggedCard.id == task.id {
            self.draggedCard = task
        }
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
            if let index = taskList.firstIndex(where: {$0.id == task.id}) {
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
    
    /// Removes all tasks that are from the selected project
    func removeAllTasksFrom(project id: Int) {
        mixedTasks.removeAll { $0.projectId == id }
        toDoTasks.removeAll { $0.projectId == id }
        inProgressTasks.removeAll { $0.projectId == id }
        testingTasks.removeAll { $0.projectId == id }
        doneTasks.removeAll { $0.projectId == id }
        removeAllTasksFromSelectedProject = false
    }
}
