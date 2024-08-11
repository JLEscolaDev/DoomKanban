//
//  PieChart.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 2/8/24.
//

import SwiftUI

struct PieChart: Shape {
    var progress: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: .degrees(0), endAngle: .degrees( (progress * 360)), clockwise: false)
        path.closeSubpath()

        return path
    }
}


#Preview {
    PieChart(progress: 0.7)
}
