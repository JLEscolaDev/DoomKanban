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
    @Environment(KanbanAppVM.self) var kanbanVM
    @Binding var canDismissImmersiveSpace: Bool
    
    @State private var audioManager = AudioPlayerManager() // Manages audio playback
    @AppStorage("isMusicPlaying") private var isMusicPlaying: Bool = true  // Tracks whether the music is currently playing and persists between app launches
    
    var body: some View {
        KanbanBoard()
            .onAppear {
                openWindow(id: "RunningSprints")
                openWindow(id: "SkillsView")
                openWindow(id: "PointsVolumetric")
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
                enableAutoDismissImmersiveSpace()
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

extension DoomKanbanLayout{
    /// Controls the canDismissImmersiveSpace boolean control that allows dismissing the Office 3d model ONLY when the system triggers the phase .inactive or .background and it is not a normal app use (for example, closing the app)
    private func enableAutoDismissImmersiveSpace() {
        Task {
            // We add one extra second because the same scenePhase that is triggered by closing the app is the same that is triggered when going back to the InitialMenu and we need to reset the canDismissImmersiveSpace to true without closing the Office immersive space each time we navigate throw the app.
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            canDismissImmersiveSpace = true
        }
    }
}

#Preview {
    DoomKanbanLayout(canDismissImmersiveSpace: .constant(false))
}
