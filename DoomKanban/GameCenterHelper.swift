//
//  GameCenterHelper.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 15/9/24.
//

import GameKit
import SwiftUI

@Observable
class GameCenterHelper: NSObject {
    static let shared = GameCenterHelper()
    var needsAuthentication = true
        
    func authenticatePlayer() async {
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let vc = viewController {
                // Present the Game Center sign-in view
                DispatchQueue.main.async {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootViewController = windowScene.windows.first?.rootViewController {
                        rootViewController.present(vc, animated: true, completion: nil)
                    }
                }
            } else if GKLocalPlayer.local.isAuthenticated {
                print("Player authenticated: \(GKLocalPlayer.local.alias)")
                self.needsAuthentication = false
            } else if let error = error {
                print("Game Center authentication error: \(error.localizedDescription)")
                self.needsAuthentication = true
            }
        }
    }
    
    func reportScore(_ score: Int, leaderboardID: String) {
        let leaderboardScore = GKLeaderboardScore()
        leaderboardScore.leaderboardID = leaderboardID
        leaderboardScore.value = score
        // Asynchronously submit the score
        GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [leaderboardID]) { error in
            if let error = error {
                print("Error reporting score: \(error.localizedDescription)")
            } else {
                print("Score submitted successfully")
            }
        }
    }
    
    func showLeaderboard() {
        // Initialize the Game Center view controller for a specific leaderboard
        let viewController = GKGameCenterViewController(leaderboardID: "doomkanban_leaderboard", playerScope: .global, timeScope: .allTime)
        viewController.gameCenterDelegate = self
        
        // Retrieve the relevant window scene and present the view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.keyWindow?.rootViewController?.present(viewController, animated: true, completion: nil)
        }
    }
    
    // Load achievements using a completion block
    func loadAchievements(completion: @escaping ([GKAchievement]?) -> Void) {
        GKAchievement.loadAchievements { achievements, error in
            if let error = error {
                print("Error loading achievements: \(error.localizedDescription)")
                completion(nil)
            } else {
                completion(achievements)
            }
        }
    }
    
    func unlockAchievement(identifier: String, percentComplete: Double = 100.0) {
        let achievement = GKAchievement(identifier: identifier)
        achievement.percentComplete = percentComplete // Completar al 100%
        achievement.showsCompletionBanner = true // Mostrar la notificación de logro desbloqueado

        GKAchievement.report([achievement]) { error in
            if let error = error {
                print("Error reporting achievement: \(error.localizedDescription)")
            } else {
                print("Achievement \(identifier) unlocked successfully!")
            }
        }
    }
}

extension GameCenterHelper: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
