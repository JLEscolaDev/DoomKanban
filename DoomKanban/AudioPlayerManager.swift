//
//  Untitled.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 6/9/24.
//

import AVFoundation
import SwiftUI

import AVFoundation

@Observable
class AudioPlayerManager {
    var audioPlayer: AVAudioPlayer?
    var playbackRate: Float = 1.0  // Initial playback rate
    var currentSong: String?  // Tracks the currently playing song
    var savedTime: TimeInterval = 0  // Saves the time at which the song was stopped
    
    // List of song names
    let songList = ["rythm1", "rythm2", "rythm3", "rythm4", "rythm5", "rythm6", "rythm7", "rythm8"]
    
    // Function to play or resume the currently selected song
    func playCurrentSong() {
        if let song = currentSong {
            playSound(songName: song)
        } else {
            playRandomSong()
        }
    }
    
    // Function to select and play a random song
    func playRandomSong() {
        if let randomSong = songList.randomElement() {
            currentSong = randomSong  // Save the song being played
            playSound(songName: randomSong)
        }
    }
    
    // Function to play the selected song and resume from the saved position if available
    func playSound(songName: String) {
        if let soundURL = Bundle.main.url(forResource: songName, withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.enableRate = true  // Allow rate changes
                audioPlayer?.numberOfLoops = -1 // Loop indefinitely
                audioPlayer?.rate = playbackRate  // Set playback speed
                
                if songName == currentSong {
                    audioPlayer?.currentTime = savedTime  // Resume from saved time
                }
                
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                
                currentSong = songName  // Track the current song
                
                // Listen for song completion to increase playback speed
                NotificationCenter.default.addObserver(self, selector: #selector(increasePlaybackSpeed), name: .AVPlayerItemDidPlayToEndTime, object: nil)
                
            } catch {
                print("Error playing sound: \(error)")
            }
        } else {
            print("Sound file not found")
        }
    }
    
    // Function to stop the music and save the current playback position
    func stopMusic() {
        if let player = audioPlayer {
            savedTime = player.currentTime  // Save the current playback time
            player.stop()  // Stop the playback
        }
    }
    
    // Function to increase playback speed after each loop
    @objc func increasePlaybackSpeed() {
        if playbackRate < 2.0 {  // Max playback rate
            playbackRate += 0.2  // Increment playback speed
            audioPlayer?.rate = playbackRate
            audioPlayer?.play()  // Continue playing with new rate
        }
    }
}
