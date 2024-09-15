//
//  LeaderboardEntry.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 15/9/24.
//

import SwiftUI

struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let gameCenterId: String // El identificador único del jugador de Game Center
    let displayName: String  // Nombre del jugador que se mostrará en la leaderboard
    let score: Int           // Puntos obtenidos por el jugador
}
