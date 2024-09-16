//
//  InitialMenu.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 3/9/24.
//

import SwiftUI

struct InitialMenuView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.pushWindow) private var pushWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.scenePhase) private var scenePhase // Tracks app lifecycle
    @State var isImmersiveSpaceOpen = false
    @Binding var canDismissImmersiveSpace: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            gameTitle
            Spacer()
            immersiveSpaceButton
            newGameButton
            achievementsButton
            podiumButton
        }
        .padding()
        .onAppear {
            handleOnAppear()
        }
        .onChange(of: scenePhase) { _, newScenePhase in
            handleScenePhaseChange(newScenePhase)
        }
    }
    
    
    // - MARK: Subviews
    // Game title
    private var gameTitle: some View {
        Text("DOOM KANBAN")
            .font(.system(size: 100, weight: .bold))
            .minimumScaleFactor(0.3)
            .fontDesign(.serif)
            .padding()
    }
    
    // Immersive space button
    private var immersiveSpaceButton: some View {
        Button(action: toggleImmersiveSpace) {
            Text("\(isImmersiveSpaceOpen ? "Desactivar" : "Activar") espacio inmersivo")
                .font(.extraLargeTitle2)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, minHeight: 120)
                .padding()
                .foregroundColor(.white)
                .cornerRadius(20)
                .minimumScaleFactor(0.3)
        }
    }
    
    // New game button
    private var newGameButton: some View {
        Button(action: {
            startGame()
        }) {
            Text("Nueva partida")
                .font(.extraLargeTitle2)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, minHeight: 120)
                .padding()
                .foregroundColor(.white)
                .cornerRadius(20)
                .minimumScaleFactor(0.3)
        }
    }
    
    // Achievements button
    private var achievementsButton: some View {
        Button(action: {
            openWindow(id: "Shelf")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                dismissWindow(id: "InitialMenu")
            }
        }) {
            Text("Logros")
                .font(.extraLargeTitle2)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, minHeight: 120)
                .padding()
                .foregroundColor(.white)
                .cornerRadius(20)
                .minimumScaleFactor(0.3)
        }
    }
    
    // Podium button
    private var podiumButton: some View {
        Button(action: {
            openWindow(id: "PodiumView")
        }) {
            Text("Podio")
                .font(.extraLargeTitle2)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, minHeight: 120)
                .padding()
                .foregroundColor(.white)
                .cornerRadius(20)
                .minimumScaleFactor(0.3)
        }
    }
    
    // Actions
    private func toggleImmersiveSpace() {
        Task {
            if isImmersiveSpaceOpen {
                await dismissImmersiveSpace()
            } else {
                await openImmersiveSpace(id: "fireImmersiveSpace")
            }
            isImmersiveSpaceOpen.toggle()
        }
    }
    
    // Handle the window dismiss logic
    private func handleOnAppear() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            dismissWindow(id: "Shelf")
        }
    }
    
    private func startGame() {
        // We use .inactive scenePhase to track when the app has been closed and we must force close the office immersive space.
        // As we close this InitialMenuView, this inactive status will be triggered so we need this extra var to check if we should close the Office.
        canDismissImmersiveSpace = false
        pushWindow(id: "KanbanBoard")
    }
    
    /// Closes the immersive space if we close the app
    private func handleScenePhaseChange(_ newScenePhase: ScenePhase) {
            switch newScenePhase {
            case .background, .inactive:
                // Dismiss immersive space when the app moves to background or becomes inactive
                if isImmersiveSpaceOpen,
                   canDismissImmersiveSpace {
                    Task {
                        await dismissImmersiveSpace()
                        isImmersiveSpaceOpen = false
                    }
                }
            default:
                break
            }
        }
}

#Preview {
    InitialMenuView(canDismissImmersiveSpace: .constant(false))
}
