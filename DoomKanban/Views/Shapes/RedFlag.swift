//
//  RedFlag.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 1/8/24.
//

import SwiftUI

struct RedFlag: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        
        // Primer subpath para el triángulo
        path.move(to: CGPoint(x: 0, y: 0.2774*height))
        path.addLine(to: CGPoint(x: 0.95*width, y: 0))
        path.addLine(to: CGPoint(x: 0.95*width, y: 0.48993*height))
        path.addLine(to: CGPoint(x: 0, y: 0.2774*height))
        path.closeSubpath()
        
        // Segundo subpath para el rectángulo
        path.move(to: CGPoint(x: 0.95*width, y: 0))
        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0.95*width, y: height))
        path.addLine(to: CGPoint(x: 0.95*width, y: 0.48993*height))
        path.addLine(to: CGPoint(x: 0.95*width, y: 0))
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    RedFlag()
        .fill(Color.red)
        .frame(width: 150, height: 130)
}
