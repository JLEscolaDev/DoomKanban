//
//  PodiumView.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 15/9/24.
//

import SwiftUI

struct PodiumView: View {
    @State private var vm = UserPodiumViewModel()
    
    var body: some View {
        VStack(spacing: 10) {
            if vm.leaderboardEntries.isEmpty {
                leaderboardEmptyState
            } else {
                leaderboardEntriesView
            }
        }
        .padding()
        .onAppear {
            handleOnAppear()
        }
        .onChange(of: vm.gameCenterHelper.needsAuthentication) {
            handleOnAuthenticationChange()
        }
    }
}


// - MARK: Subviews
extension PodiumView {
    // View for when the leaderboard is empty or the user needs authentication
    private var leaderboardEmptyState: some View {
        if vm.gameCenterHelper.needsAuthentication {
            Text("You must log in your game center account to see the ranking")
        } else {
            Text("Loading leaderboard...")
        }
    }
    
    // View for the leaderboard entries
    private var leaderboardEntriesView: some View {
        ForEach(vm.leaderboardEntries.prefix(10).enumerated().map({ $0 }), id: \.1.id) { index, entry in
            HStack {
                Text("\(index + 1).")
                Text(entry.displayName)
                    .font(.title3)
                
                Spacer()
                
                Text("\(entry.score) pts")
                    .font(.title3)
            }
            .padding()
            .background(entryBackgroundColor(index: index, entry: entry))
            .cornerRadius(10)
        }
    }
    
    // Function to determine the background color of each leaderboard entry
    private func entryBackgroundColor(index: Int, entry: LeaderboardEntry) -> Color {
        if vm.currentUser?.gameCenterId == entry.gameCenterId {
            return Color.blue.opacity(0.5)
        } else {
            switch index {
                case 0:
                    return Color.green.opacity(0.8)
                case 1:
                    return Color.green.opacity(0.5)
                case 2:
                    return Color.green.opacity(0.2)
                default:
                    return Color.clear
            }
        }
    }
}

// MARK: - Extracted event handling
extension PodiumView {
    // Handles the logic for `onAppear`
    private func handleOnAppear() {
        Task {
            await vm.gameCenterHelper.authenticatePlayer()
            loadPodium()
        }
    }

    // Handles the logic for `onChange`
    private func handleOnAuthenticationChange() {
        loadPodium()
    }
    
    private func loadPodium() {
        Task {
            if !vm.gameCenterHelper.needsAuthentication {
                await vm.loadPodiumData()
            }
        }
    }
}
