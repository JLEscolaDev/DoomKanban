//
//  WarningTriangle.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 2/8/24.
//

import SwiftUI

/// Warning signal with an optional image inside it. 
///
/// ℹ️ To color it notice that you can tint the stroke with .foreground, the inside with .secondaryColor and the image with .tint
struct WarningTriangle: View {
    @Environment(\.secondaryColor) var secondaryColor
    let image: Image?
    
    init(image: Image? = nil) {
        self.image = image
    }
    
    var body: some View {
        GeometryReader { geometry in
            let mandatorySize = min(geometry.size.width, geometry.size.height)
            ZStack {
                triangleBackground(mandatorySize: mandatorySize)
                triangleForeground(mandatorySize: mandatorySize)
                    .overlay {
                        if let image = image {
                            triangleImage(mandatorySize: mandatorySize, image: image)
                        }
                    }
            }
        }
    }
}

// MARK: - Extracted Views
extension WarningTriangle {
    // Background triangle with shadow
    private func triangleBackground(mandatorySize: CGFloat) -> some View {
        Triangle(cornerRadius: mandatorySize * 0.08, shouldForceEquilateral: true)
            .frame(width: mandatorySize, height: mandatorySize)
            .background {
                Triangle(cornerRadius: mandatorySize * 0.08, shouldForceEquilateral: true)
                    .shadow(color: .black.opacity(0.6), radius: 2, x: mandatorySize * 0.03)
            }
    }
    
    // Foreground triangle
    private func triangleForeground(mandatorySize: CGFloat) -> some View {
        Triangle(cornerRadius: mandatorySize * 0.03, shouldForceEquilateral: true)
            .foregroundStyle(secondaryColor)
            .frame(width: mandatorySize * 0.75, height: mandatorySize * 0.75)
            .offset(y: mandatorySize * 0.025)
    }
    
    // Image overlay inside the triangle
    private func triangleImage(mandatorySize: CGFloat, image: Image) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(.tint)
            .frame(width: mandatorySize * 0.45, height: mandatorySize * 0.45)
            .offset(y: mandatorySize * 0.12)
    }
}

#Preview {
    WarningTriangle(image: Image(.shout))
        .secondaryColor(.blue.lighter())
        .foregroundStyle(.blue)
        .tint(.blue)
        .frame(width: 200, height: 200)
}

