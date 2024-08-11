//
//  TriangleShape.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 2/8/24.
//

import SwiftUI

struct Triangle: Shape {
    var cornerRadius: CGFloat
    var shouldForceEquilateral: Bool
    
    init(cornerRadius: CGFloat = 0, shouldForceEquilateral: Bool = false) {
        self.cornerRadius = cornerRadius
        self.shouldForceEquilateral = shouldForceEquilateral
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let equilateralSize = min(rect.width, rect.height)
        
        // Calculate height of the triangle
        let triangleHeight = shouldForceEquilateral ? equilateralSize * sqrt(3) / 2 : rect.height
        
        // Calculate center offset
        let yOffset = (rect.height - triangleHeight) / 2
        
        // Create first point in the bottom center of the triangle
        let bottomCenterPoint = CGPoint(x: rect.midX, y: rect.maxY - yOffset)
        
        // Intermediate points to draw triangle arcs
        let topLeftArcStart = shouldForceEquilateral ? CGPoint(x: rect.midX, y: rect.maxY - triangleHeight - yOffset) : CGPoint(x: rect.midX, y: rect.minY + yOffset - cornerRadius)
        // ℹ️ We use the equilateralSize/2 from midX instead of minX or maxX because we want to be able to get the minimum size (from width and height) and then use that to draw the path. Drawing this way we can use bigger height or bigger width and the triangle will keep resizing well.
        let bottomLeftArcStart = CGPoint(x: rect.midX - equilateralSize/2 - cornerRadius / 2, y: rect.maxY - yOffset)
        let bottomRightArcStart = CGPoint(x: rect.midX + equilateralSize/2 + cornerRadius / 2, y: rect.maxY - yOffset)
        
        // Start on the bottom center
        path.move(to: bottomCenterPoint)
        
        // Draw all the path throughout all the points using the arcs to draw the rounded corners
        path.addArc(tangent1End: bottomLeftArcStart, tangent2End: topLeftArcStart, radius: cornerRadius)
        path.addArc(tangent1End: topLeftArcStart, tangent2End: bottomRightArcStart, radius: cornerRadius)
        path.addArc(tangent1End: bottomRightArcStart, tangent2End: bottomLeftArcStart, radius: cornerRadius)
        
        // Once we end the last arc (bottom right) we close the path that will end in the same start position (bottomCenterPoint)
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    HStack(spacing: 20) {
        VStack {
            Text("No equilateral").font(.largeTitle)
            Triangle(cornerRadius: 15)
                .frame(width: 200, height: 500)
        }
        Rectangle()
            .foregroundStyle(.white)
            .frame(width: 2, height: 300)
        VStack {
            Text("Force equilateral").font(.largeTitle)
            Triangle(cornerRadius: 15, shouldForceEquilateral: true)
                .frame(width: 200, height: 500)
        }
    }
}
