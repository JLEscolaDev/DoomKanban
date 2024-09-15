//
//  DoomKanbanLayout.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 3/8/24.
//

import SwiftUI

struct DoomKanbanLayout: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
//    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(KanbanAppVM.self) var kanbanVM
    
    @State private var audioManager = AudioPlayerManager() // Manages audio playback
    @AppStorage("isMusicPlaying") private var isMusicPlaying: Bool = true  // Tracks whether the music is currently playing and persists between app launches
    
    var body: some View {
        KanbanBoard()
            .onAppear {
                openWindow(id: "RunningSprints")
                openWindow(id: "SkillsView")
                openWindow(id: "PointsVolumetric")
//                Task {
//                    await openImmersiveSpace(id: "Points")
//                }
                // Play or resume music if it's supposed to be playing
                if isMusicPlaying {
                    audioManager.playCurrentSong()
                }
            }
            .onDisappear {
                dismissWindow(id: "RunningSprints")
                dismissWindow(id: "SkillsView")
                dismissWindow(id: "PointsVolumetric")
                audioManager.stopMusic()  // Stops music and saves the playback position
                // Reset the main model to clean old data from previous games
                kanbanVM.reset()
            }
            .ornament(
                visibility: .visible,
                attachmentAnchor: .scene(.bottomTrailing),
                contentAlignment: .bottomTrailing
            ) {
                HStack {
                    Image(systemName: "music.note")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                    Button(action: {
                        // Toggle music playback
                        isMusicPlaying.toggle()
                        if isMusicPlaying {
                            audioManager.playCurrentSong()  // Resume the current song
                        } else {
                            audioManager.stopMusic()  // Pause the music
                        }
                    }) {
                        Image(systemName: isMusicPlaying ? "stop.circle.fill" : "play.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)  // Adjust icon size
                            .foregroundColor(isMusicPlaying ? .red : .green)  // Change color based on state
                    }
                }.padding(.trailing, 10)
            }
    }
}

#Preview {
    DoomKanbanLayout()
}
