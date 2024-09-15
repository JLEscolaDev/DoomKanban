//
//  SaveScoreViewModel.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 15/9/24.
//

import GameKit
import SwiftUI

@Observable
class SaveScoreViewModel {
    var playerName = ""
    var isNameAvailable: Bool? = nil
    @ObservationIgnored var playerPoints: Int = 0
    let cloudKitManager = CloudKitManager()
    let gameCenterHelper = GameCenterHelper.shared
}

// - MARK: Utility funcs for BBDD interaction
extension SaveScoreViewModel {
    func checkNameAvailability() {
        cloudKitManager.checkLeaderboardNameAvailability(displayName: playerName) { isAvailable, error in
            if let _ = error {
                self.isNameAvailable = false
            } else {
                self.isNameAvailable = isAvailable
            }
        }
    }
    
    func handleSaveScore(completion: @escaping (Bool, String?) -> Void) async {
        guard let isAvailable = isNameAvailable, isAvailable else {
            completion(false, "Name is not available.")
            return
        }

        if gameCenterHelper.needsAuthentication {
            await gameCenterHelper.authenticatePlayer()
        }

        if !gameCenterHelper.needsAuthentication {
            cloudKitManager.saveLeaderboardEntry(gameCenterId: GKLocalPlayer.local.gamePlayerID,
                                                    displayName: playerName,
                                                    score: playerPoints) { error in
                if let error = error {
                    completion(false, "Error saving leaderBoardEntry to iCloud: \(error.localizedDescription)")
                } else {
                    self.gameCenterHelper.unlockAchievement(identifier: "FirstWin")
                    completion(true, "Successfully saved leaderBoardEntry to iCloud")
                }
            }
        } else {
            completion(false, "Game Center authentication failed.")
        }
    }
}
