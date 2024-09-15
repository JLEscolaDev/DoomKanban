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
    @State var isImmersiveSpaceOpen = false
    
    var body: some View {
        VStack(spacing: 30) {
            gameTitle
            immersiveSpaceButton
            newGameButton
            achievementsButton
            podiumButton
        }
        .padding()
        .onAppear {
            handleOnAppear()
        }
    }
    
    
    // - MARK: Subviews
    // Game title
    private var gameTitle: some View {
        Text("DOOM KANBAN")
            .font(.system(size: 100, weight: .bold))
            .fontDesign(.serif)
            .padding()
            .padding(.bottom, 180)
    }
    
    // Immersive space button
    private var immersiveSpaceButton: some View {
        Button(action: toggleImmersiveSpace) {
            Text("\(isImmersiveSpaceOpen ? "Desactivar" : "Activar") espacio inmersivo")
                .font(.system(size: 40, weight: .medium))
                .frame(maxWidth: .infinity, minHeight: 120)
                .padding()
                .foregroundColor(.white)
                .cornerRadius(20)
        }
    }
    
    // New game button
    private var newGameButton: some View {
        Button(action: {
            pushWindow(id: "KanbanBoard")
        }) {
            Text("Nueva partida")
                .font(.system(size: 40, weight: .medium))
                .frame(maxWidth: .infinity, minHeight: 120)
                .padding()
                .foregroundColor(.white)
                .cornerRadius(20)
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
                .font(.system(size: 40, weight: .medium))
                .frame(maxWidth: .infinity, minHeight: 120)
                .padding()
                .foregroundColor(.white)
                .cornerRadius(20)
        }
    }
    
    // Podium button
    private var podiumButton: some View {
        Button(action: {
            openWindow(id: "PodiumView")
        }) {
            Text("Podio")
                .font(.system(size: 40, weight: .medium))
                .frame(maxWidth: .infinity, minHeight: 120)
                .padding()
                .foregroundColor(.white)
                .cornerRadius(20)
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
}

#Preview {
    InitialMenuView()
}
