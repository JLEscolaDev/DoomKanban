//
//  VisionProPoseç.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 15/9/24.
//

import SwiftUI
import ARKit

// Class to manage the ARKit session and retrieve the device's position
@Observable
class VisionProPose {
    let session = ARKitSession()            // Initialize ARKit session
    let worldTracking = WorldTrackingProvider() // World tracking provider for tracking the device position
    
    // Limits for the user's movement in the space
    let forwardLimit: Float = 2.0
    let backwardLimit: Float = -1.0
    
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
