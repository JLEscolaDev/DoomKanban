//
//  SaveScoreView.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 15/9/24.
//

import GameKit
import SwiftUI

struct SaveScoreView: View {
    @Environment(\.dismissWindow) private var dismissWindow
    @State private var vm = SaveScoreViewModel()
    
    init(points: Int) {
        vm.playerPoints = points
    }
    
    var body: some View {
        createSaveScoreView
    }

    // - MARK: Subviews
    // Main layout for the view
    private var createSaveScoreView: some View {
        VStack {
            gameOverTitle
            playerNameTextfield
            nameAvailabilityStatus
            pointsText
            saveButton
        }
        .padding()
        .onChange(of: vm.isNameAvailable) {
            handleSaveOnChange()
        }
        .onAppear {
            handleOnAppear()
        }
    }

    // Title view for "Game Over"
    private var gameOverTitle: some View {
        Text("Game Over")
            .font(.extraLargeTitle)
            .padding(.top, 20)
            .padding(.bottom, 30)
    }

    // TextField for entering the player's name
    private var playerNameTextfield: some View {
        TextField("Player Name", text: $vm.playerName)
            .font(.title)
            .foregroundStyle(.black)
            .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
    }

    // View to display the availability status of the player's name
    private var nameAvailabilityStatus: some View {
        if let isAvailable = vm.isNameAvailable {
            return AnyView(
                Text(vm.gameCenterHelper.needsAuthentication ?
                    "GameCenter login necessary for saving" :
                    isAvailable ? "Name is available" : "Name is not available")
                .foregroundColor(isAvailable ? .green : .red)
            )
        }
        return AnyView(EmptyView())
    }

    // View to display the player's points
    private var pointsText: some View {
        Text("Points: \(vm.playerPoints)")
            .font(.extraLargeTitle2)
            .padding()
    }

    // Button to save the score
    private var saveButton: some View {
        Button("Save Score") {
            vm.checkNameAvailability()
        }
        .disabled(vm.gameCenterHelper.needsAuthentication || vm.playerName.isEmpty)
        .padding()
    }
}

// - MARK: View events
extension SaveScoreView {
    // Handles logic when name availability changes
    private func handleSaveOnChange() {
        Task {
            await vm.handleSaveScore { success, message in
                if success {
                    dismissWindow(id: "KanbanBoard")
                }
                vm.isNameAvailable = nil
            }
        }
    }

    // Handles actions when the view appears
    private func handleOnAppear() {
        if vm.gameCenterHelper.needsAuthentication {
            Task {
                await vm.gameCenterHelper.authenticatePlayer()
            }
        }
    }
}
