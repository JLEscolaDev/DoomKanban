//
//  DoomKanbanApp.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 1/8/24.
//

import SwiftUI

@main
struct DoomKanbanApp: App {
    @State var appVM: KanbanAppVM = KanbanAppVM()
    /// Bottom window control visibility to hide certain UI controls
    private var bottomWindowControlsVisibility: Visibility = .hidden
    let defaultSize = Size3D(width: 2, height: 2, depth: 2)
    @State var canDismissImmersiveSpace = true

    var body: some Scene {
        WindowGroup(id: "InitialMenu") {
            InitialMenuView(canDismissImmersiveSpace: $canDismissImmersiveSpace)
        }
        .defaultSize(width: 1200, height: 1200)

        kanbanBoardWindow
        pointsVolumetricWindow
        runningSprintsWindow
        skillsViewWindow
        shelfWindow
        immersiveSpace
        podiumWindow
    }
    

    // Window group for the Kanban board
    private var kanbanBoardWindow: some Scene {
        WindowGroup(id: "KanbanBoard") {
            GeometryReader { geometry in
                DoomKanbanLayout(canDismissImmersiveSpace: $canDismissImmersiveSpace)
                    .frame(width: geometry.size.width - 100, height: geometry.size.height - 100)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .environment(appVM)
            }
            .keepAspectRatio()
        }
        .defaultSize(width: 1200, height: 1200)
    }

    // Window group for points in a volumetric space
    private var pointsVolumetricWindow: some Scene {
        WindowGroup(id: "PointsVolumetric") {
            ExtrudedPointCounterImmersiveView(points: appVM.points)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 2500, height: 100, depth: 100)
        .defaultWindowPlacement { content, context in
            if let mainWindow = context.windows.first(where: { $0.id == "KanbanBoard" }) {
                return WindowPlacement(.below(mainWindow))
            } else {
                print("No window with ID 'KanbanBoard' found!")
                return WindowPlacement()
            }
        }
    }

    // Window group for the sprints list when playing the game
    private var runningSprintsWindow: some Scene {
        WindowGroup(id: "RunningSprints") {
            GeometryReader { geometry in
                SprintsLayoutView()
                    .frame(width: 320, height: max(geometry.size.height, 320))
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .environment(appVM)
            }
        }
        .windowStyle(.plain)
        .defaultSize(width: 320, height: 1000)
        .defaultWindowPlacement { content, context in
            if let mainWindow = context.windows.first(where: { $0.id == "KanbanBoard" }) {
                return WindowPlacement(.leading(mainWindow))
            } else {
                print("No window with ID 'KanbanBoard' found!")
                return WindowPlacement()
            }
        }
        .persistentSystemOverlays(bottomWindowControlsVisibility)
    }

    // Window group for the skills view that can be used while playing
    private var skillsViewWindow: some Scene {
        WindowGroup(id: "SkillsView") {
            SkillsView(.init(skills: [
                Skill(icon: Image(.chrono), coolDown: 10, type: .chronoMaster),
                Skill(icon: Image(.clientContact), coolDown: 15, type: .businessMan),
                Skill(icon: Image(.programmerAscension), coolDown: 20, type: .programmerAscension)
            ], orientation: .vertical))
            .environment(appVM)
        }
        .windowStyle(.plain)
        .defaultSize(width: 320, height: 1200)
        .defaultWindowPlacement { content, context in
            if let mainWindow = context.windows.first(where: { $0.id == "KanbanBoard" }) {
                return WindowPlacement(.trailing(mainWindow))
            } else {
                print("No window with ID 'KanbanBoard' found!")
                return WindowPlacement()
            }
        }
        .persistentSystemOverlays(bottomWindowControlsVisibility)
    }

    // Window group for the 3D shelf view
    private var shelfWindow: some Scene {
        WindowGroup(id: "Shelf") {
            Shelf3DView(defaultSize: defaultSize)
        }
        .windowStyle(.volumetric)
        .defaultSize(defaultSize, in: .meters)
    }

    // Office Immersive space configuration
    private var immersiveSpace: some Scene {
        ImmersiveSpace(id: "fireImmersiveSpace") {
            ImmersiveSpaceView()
                .environment(appVM)
        }.immersionStyle(selection: .constant(.full), in: .full)
    }

    // Window group for the podium view
    private var podiumWindow: some Scene {
        WindowGroup(id: "PodiumView") {
            PodiumView()
        }
        .defaultSize(width: 800, height: 800)
    }
}
