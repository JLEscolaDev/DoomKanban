//
//  WardenEye.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 5/8/24.
//

import SwiftUI

struct WardenEye: View {
    private enum EyePosition {
        case topLeft
        case bottomLeft
        case center
        case bottomRight
        case topRight
    }
    
    private enum DefaultPositionMultipliers {
        static let xTrailing: CGFloat = 0.08
        static let yTop: CGFloat = 0.13
        static let xCenter: CGFloat = -0.005
        static let yCenter: CGFloat = 0.17
        static let yBottom: CGFloat = 0.25
    }
    
    @State private var animationTimer: Timer?
    @State private var eyePosition: EyePosition = .center
    
    var body: some View {
        GeometryReader { geometry in
            Image(.eye)
                .resizable()
                .background {
                    Circle()
                        .frame(width: geometry.size.width*0.16, height: geometry.size.height*0.16)
                        .foregroundStyle(.tint)
                        .offset(
                            x: getEyePosition(geometry: geometry).x,
                            y: getEyePosition(geometry: geometry).y
                        )
                }
        }.onAppear {
            animationTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                nextEyePosition()
                                }
            
        }.onDisappear {
            animationTimer?.invalidate()
        }
    }
    
    private func nextEyePosition() {
        let position: EyePosition = switch eyePosition {
            case .center:
                .topLeft
            case .topLeft:
                .bottomLeft
            case .bottomLeft:
                .topRight
            case .topRight:
                .bottomRight
            case .bottomRight:
                .center
        }
        withAnimation {
            eyePosition = position
        }
    }
    
    private func getEyePosition(geometry: GeometryProxy) -> (x: CGFloat, y: CGFloat) {
        let (xMulti, yMulti): (CGFloat, CGFloat) = switch eyePosition {
            case .center:
            (DefaultPositionMultipliers.xCenter, DefaultPositionMultipliers.yCenter)
            case .topLeft:
            (-DefaultPositionMultipliers.xTrailing, DefaultPositionMultipliers.yTop)
            case .bottomLeft:
            (-DefaultPositionMultipliers.xTrailing, DefaultPositionMultipliers.yBottom)
            case .topRight:
            (DefaultPositionMultipliers.xTrailing, DefaultPositionMultipliers.yTop)
            case .bottomRight:
            (DefaultPositionMultipliers.xTrailing, DefaultPositionMultipliers.yBottom)
        }
        return (xMulti*geometry.size.width, yMulti*geometry.size.height)
    }
}

#Preview {
    WardenEye()
        .foregroundStyle(.black)
        .tint(.red)
        .frame(width: 600, height: 600)
}
