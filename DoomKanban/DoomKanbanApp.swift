//
//  DoomKanbanApp.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 1/8/24.
//

import SwiftUI

@main
struct DoomKanbanApp: App {
    var body: some Scene {
        WindowGroup(id: "KanbanBoard") {
            GeometryReader { geometry in
                DoomKanbanLayout()
                    .frame(width: geometry.size.width - 100, height: geometry.size.height - 100)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }.keepAspectRatio()
        }
        .defaultSize(width: 1200, height: 1200)
        
        WindowGroup(id: "RunningSprints") {
            GeometryReader { geometry in
                SprintsLayoutView(runningSprints: [
                    RunningSprintIndicatorView(project: 1, sprint: 4, leftColor: .blue),
                    RunningSprintIndicatorView(project: 2, sprint: 2, isNextSprintTheLastOne: true, leftColor: .yellow)
                ])
                .frame(width: 320, height: geometry.size.height > 320 ? geometry.size.height : 320)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
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
    }
}
