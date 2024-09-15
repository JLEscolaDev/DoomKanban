//
//  LeaderboardEntry.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 15/9/24.
//

import GameKit
import SwiftUI

@Observable
class UserPodiumViewModel {
    var leaderboardEntries: [LeaderboardEntry] = [] // Filled with CloudKit data
    var currentUser: LeaderboardEntry?
    let cloudKitManager = CloudKitManager()
    let gameCenterHelper = GameCenterHelper.shared
    
    // Load users from CloudKit and Game Center
    func loadPodiumData() async {
        await gameCenterHelper.authenticatePlayer() // Esperamos a que se complete la autenticación

        if GKLocalPlayer.local.isAuthenticated {
            let player = GKLocalPlayer.local
            // Asigna el jugador actual
            self.currentUser = LeaderboardEntry(gameCenterId: player.gamePlayerID, displayName: player.alias, score: 0)
            
            // Cargar los datos de CloudKit
            self.cloudKitManager.fetchLeaderboardEntries { entries, error in
                if let entries = entries {
                    // Ordenar por puntaje
                    self.leaderboardEntries = entries.sorted(by: { $0.score > $1.score })
                    
                    // Si el jugador actual no está en el leaderboard, lo añadimos
                    if !self.leaderboardEntries.contains(where: { $0.gameCenterId == self.currentUser?.gameCenterId }) {
                        if let currentUser = self.currentUser {
                            self.leaderboardEntries.append(currentUser)
                        }
                    }
                } else if let error = error {
                    print("Error fetching leaderboard entries: \(error.localizedDescription)")
                }
            }
        } else {
            print("No Game Center user authenticated")
        }
    }
}
