//
//  TestView.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 3/9/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import ARKit

// Class to manage the ARKit session and retrieve the device's position
@Observable
class VisionProPose {
    let session = ARKitSession()            // Initialize ARKit session
    let worldTracking = WorldTrackingProvider() // World tracking provider for tracking the device position

    // Detects if the app is running in the simulator
    var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }

    // Initializes and runs the ARKit session if not running on the simulator
    func runArSession() async {
        if isSimulator {
            // In the simulator, ARKit is not available, so we simulate the ARKit session
            print("Running on the simulator. ARKit session will not start.")
        } else {
            do {
                // Start the ARKit session with world tracking
                try await session.run([worldTracking])
                print("ARKit session started successfully.")
            } catch {
                // Handle any errors that occur when starting the ARKit session
                print("Error starting ARKit session: \(error)")
            }
        }
    }

    // Retrieves the transformation matrix (device's position and orientation)
    // Simulates a default position if running in the simulator
    func getTransform() async -> simd_float4x4? {
        if isSimulator {
            // Simulate a default position when running in the simulator
            print("Simulating device position in simulator.")
            return simd_float4x4(1) // Return an identity matrix (no transformation)
        } else {
                // Query the device anchor to get the device's real-world transform
                guard let deviceAnchor = worldTracking.queryDeviceAnchor(atTimestamp: 2.0) else {
                    print("Error: Could not retrieve the DeviceAnchor")
                    return nil
                }

                // Return the transform matrix from the device anchor
                let transform = deviceAnchor.originFromAnchorTransform
                return transform
        }
    }
}

struct ImmersiveSpaceView: View {
    @Environment(KanbanAppVM.self) var kanbanVM
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openWindow) private var openWindow
    @State private var fireEntities: [Entity?] = [nil, nil, nil] // Prepare for 3 fire entities
    @State private var smokeEntities: [Entity?] = [nil, nil, nil] // Prepare for 3 smoke entities
    @State private var visionProPose = VisionProPose()
    @State private var userPosition: SIMD3<Float> = [0, 0, 0]
    @State private var immersiveSpaceOpen: Bool = false

    // Limits for the user's movement in the space
    let forwardLimit: Float = 2.0
    let backwardLimit: Float = -1.0

    var body: some View {
        RealityView { content in
            Task {
                await visionProPose.runArSession()
            }

            // Load the scene from RealityKit
            if let scene = try? await Entity.load(named: "Scene", in: realityKitContentBundle) {
                content.add(scene)
                
                // Create fire and smoke entities at the beginning
                fireEntities = (1...3).map { scene.findEntity(named: "Fire\($0)") }
                smokeEntities = (1...3).map { scene.findEntity(named: "Smoke\($0)") }

                // Log any missing fire or smoke entities
                fireEntities.enumerated().forEach { index, entity in
                    if entity == nil { print("Fire\(index + 1) entity not found") }
                    else {
                        entity?.isEnabled = false
                    }
                }
                smokeEntities.enumerated().forEach { index, entity in
                    if entity == nil { print("Smoke\(index + 1) entity not found") }
                    else {
                        entity?.isEnabled = false
                    }
                }

                // Subscribe to scene updates to track the user's position
//                content.subscribe(to: SceneEvents.Update.self) { _ in
//                    Task {
//                        if let mtx = await visionProPose.getTransform() {
//                            let position = SIMD3<Float>(mtx.columns.3.x, mtx.columns.3.y, mtx.columns.3.z)
//                            userPosition = position
//
//                            if userPosition.z > forwardLimit || userPosition.z < backwardLimit {
//                                print("User out of bounds. Position: \(userPosition.z)")
//                                
//                                if immersiveSpaceOpen {
//                                    await dismissImmersiveSpace()
//                                    immersiveSpaceOpen = false
//                                }
//                            } else {
//                                print("User within bounds. Position: \(userPosition.z)")
//                            }
//                        }
//                    }
//                }
            } else {
                print("Failed to load the scene")
            }
        }
        .onAppear {
            if !immersiveSpaceOpen {
                immersiveSpaceOpen = true
            }
        }
        .onChange(of: kanbanVM.warningList) {
            let numberOfWarnings = countActiveWarnings()
            // Update fire and smoke entities based on the number of warnings
            fireEntities.enumerated().forEach { index, fireEntity in
                controlParticleEmitter(entity: fireEntity, isActive: index < numberOfWarnings)
            }
            smokeEntities.enumerated().forEach { index, smokeEntity in
                controlParticleEmitter(entity: smokeEntity, isActive: index < numberOfWarnings)
            }
        }
    }

    // Function to control the particle emitter for fire or smoke entities
    private func controlParticleEmitter(entity: Entity?, isActive: Bool) {
        guard let entity = entity, var emitterComponent = entity.components[ParticleEmitterComponent.self] else {
            print("Could not retrieve the particle emitter")
            return
        }

        if isActive {
            // Activate the particle emitter
            entity.isEnabled = true
            emitterComponent.timing = .repeating(warmUp: 2, emit: .init(duration: 10), idle: .init(duration: 3))
        } else {
            // Deactivate the particle emitter
            Task {
                emitterComponent.timing = .once(warmUp: 2, emit: .init(duration: 1))
                entity.components[ParticleEmitterComponent.self] = emitterComponent
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
                emitterComponent.timing = .once(warmUp: 0, emit: .init(duration: 0))
                entity.isEnabled = false
            }
        }
        entity.components[ParticleEmitterComponent.self] = emitterComponent
    }

    // Optimized function to count the number of active warnings (max 3)
    func countActiveWarnings() -> Int {
        kanbanVM.warningList
            .prefix { $0.numberOfWarnings > 0 }
            .reduce(0) { (sum, warning) -> Int in
                let newSum = sum + warning.numberOfWarnings
                return newSum > 3 ? 3 : newSum
            }
    }
}


import CloudKit

@Observable class UserPodiumViewModel {
    var users: [User] = [] // Se llena con los datos de CloudKit
    var currentUser: User?
    let cloudKitManager = CloudKitManager()
    let gameCenterHelper = GameCenterHelper()
    
    // Cargar los usuarios desde CloudKit y Game Center
    func loadPodiumData() {
        // Primero autenticar Game Center
        gameCenterHelper.authenticatePlayer { player in
            guard let player = player else {
                print("No Game Center user authenticated")
                return
            }

            // Asigna el jugador actual
            self.currentUser = User(name: player.alias, points: 0) // Asigna 0 temporalmente

            // Luego carga los datos de CloudKit
            self.cloudKitManager.fetchUsers { users, error in
                if let users = users {
                    // Ordena por puntos
                    self.users = users.sorted(by: { $0.points > $1.points })

                    // Si el jugador actual no está en la lista, lo añadimos
                    if !self.users.contains(where: { $0.name == self.currentUser?.name }) {
                        if let currentUser = self.currentUser {
                            self.users.append(currentUser)
                        }
                    }
                } else if let error = error {
                    print("Error fetching users: \(error.localizedDescription)")
                }
            }
        }
    }
}


struct User: Identifiable {
    let id = UUID()
    let name: String
    let points: Int
}

class CloudKitManager {
    let privateDatabase = CKContainer.default().privateCloudDatabase
    
    func saveUser(name: String, points: Int, completion: @escaping (Error?) -> Void) {
        let record = CKRecord(recordType: "User")
        record["name"] = name
        record["points"] = points
        
        privateDatabase.save(record) { _, error in
            completion(error)
        }
    }
    
    func fetchUsers(completion: @escaping ([User]?, Error?) -> Void) {
        let query = CKQuery(recordType: "User", predicate: NSPredicate(value: true))
        
        privateDatabase.fetch(withQuery: query, inZoneWith: nil, desiredKeys: ["name", "points"], resultsLimit: CKQueryOperation.maximumResults) { result in
            switch result {
            case .success(let (matchResults, _)):
                var users: [User] = []
                for matchResult in matchResults {
                    switch matchResult.1 {
                    case .success(let record):
                        if let name = record["name"] as? String, let points = record["points"] as? Int {
                            print("Fetched user: \(name) with points: \(points)")
                            users.append(User(name: name, points: points))
                        }
                    case .failure(let error):
                        print("Error with record: \(error)")
                    }
                }
                completion(users, nil)
            case .failure(let error):
                print("Error fetching users: \(error.localizedDescription)")
                completion(nil, error)
            }
        }
    }

}




import SwiftUI

struct SaveScoreView: View {
    @State private var playerName = ""
    let playerPoints: Int
    let cloudKitManager = CloudKitManager()

    var body: some View {
        VStack {
            Text("Game Over") // ⚠️ JLE: This code should be updated when winning a game is possible.
                .font(.extraLargeTitle)
                .fontDesign(.serif)
                .foregroundStyle(.red.darker())
                .padding(.top, 20)
                .padding(.bottom, 30)
            
            TextField("Player Name", text: $playerName)
                .font(.title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Text("Points: \(playerPoints)")
                .font(.extraLargeTitle2)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .padding()

            Button("Save Score") {
                cloudKitManager.saveUser(name: playerName, points: playerPoints) { error in
                    if let error = error {
                        print("Error saving to iCloud: \(error.localizedDescription)")
                    } else {
                        print("Successfully saved user to iCloud")
                    }
                }
            }
            .padding()
        }
        .padding()
        .glassBackgroundEffect()
    }
}

#Preview {
    SaveScoreView(playerPoints: 1205)
}

#Preview {
    PodiumView()
}

struct PodiumView: View {
    @State private var viewModel = UserPodiumViewModel()

    var body: some View {
        VStack(spacing: 10) {
            if viewModel.users.isEmpty {
                Text("Loading leaderboard...") // Mensaje mientras se cargan los datos
            } else {
                // Mostrar los primeros 10 usuarios
                ForEach(viewModel.users.prefix(10).enumerated().map({ $0 }), id: \.1.id) { index, user in
                    HStack {
                        Text("\(index+1).")
                        Text(user.name)
                            .font(.title3)
                            .foregroundStyle(.white)

                        Spacer()

                        Text("\(user.points) pts")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                    .padding()
                    .background {
                        if viewModel.currentUser?.name == user.name {
                            Color.blue.opacity(0.5)
                        } else {
                            switch index {
                                case 0:
                                    Color.green.opacity(0.8)
                                case 1:
                                    Color.green.opacity(0.5)
                                case 2:
                                    Color.green.opacity(0.2)
                                default:
                                    Color.clear
                            }
                        }
                    }
                    .glassBackgroundEffect()
                    .cornerRadius(10)
                    .shadow(radius: index < 3 ? 10 : 0)
                }

                // Si el usuario no está en el Top 10, mostramos su posición
                if let currentUser = viewModel.currentUser,
                   !viewModel.users.contains(where: { $0.name == currentUser.name }) {
                    HStack {
                        Text("\(viewModel.users.count + 1).")
                        Text(currentUser.name)
                            .font(.title3)
                            .foregroundStyle(.white)

                        Spacer()

                        Text("\(currentUser.points) pts")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.5))
                    .glassBackgroundEffect()
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.top, 20)
                }
            }
        }
        .padding()
        .onAppear {
                    viewModel.loadPodiumData() // Cargar los datos de CloudKit y Game Center
                }
    }
}



import GameKit

class GameCenterHelper: NSObject, GKGameCenterControllerDelegate {
    static let shared = GameCenterHelper()
    
    func authenticatePlayer() {
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let vc = viewController {
                // Find the active window scene
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    // Present the Game Center sign-in using the keyWindow
                    windowScene.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
                }
            } else if GKLocalPlayer.local.isAuthenticated {
                print("Player authenticated")
            } else if let error = error {
                print("Game Center authentication error: \(error.localizedDescription)")
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

    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
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
    
    func authenticatePlayer(completion: @escaping (GKLocalPlayer?) -> Void) {
            GKLocalPlayer.local.authenticateHandler = { viewController, error in
                if let vc = viewController {
                    // Presentar Game Center si es necesario
                    UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true)
                } else if GKLocalPlayer.local.isAuthenticated {
                    print("Player authenticated: \(GKLocalPlayer.local.alias)")
                    completion(GKLocalPlayer.local)
                } else {
                    print("Game Center authentication error: \(error?.localizedDescription ?? "Unknown error")")
                    completion(nil)
                }
            }
        }
}
