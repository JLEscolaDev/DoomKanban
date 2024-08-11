//
//  FlowArrow.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 2/8/24.
//

import SwiftUI

struct FlowArrow: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.08131*width, y: 0.04651*height))
        path.addLine(to: CGPoint(x: 0.62733*width, y: 0.04651*height))
        path.addCurve(to: CGPoint(x: 0.72124*width, y: 0.09922*height), control1: CGPoint(x: 0.66568*width, y: 0.04651*height), control2: CGPoint(x: 0.70126*width, y: 0.06648*height))
        path.addLine(to: CGPoint(x: 0.94191*width, y: 0.46097*height))
        path.addCurve(to: CGPoint(x: 0.94191*width, y: 0.57554*height), control1: CGPoint(x: 0.96337*width, y: 0.49614*height), control2: CGPoint(x: 0.96337*width, y: 0.54036*height))
        path.addLine(to: CGPoint(x: 0.72124*width, y: 0.93728*height))
        path.addCurve(to: CGPoint(x: 0.62733*width, y: 0.99*height), control1: CGPoint(x: 0.70126*width, y: 0.97002*height), control2: CGPoint(x: 0.66568*width, y: 0.99*height))
        path.addLine(to: CGPoint(x: 0.08131*width, y: 0.99*height))
        path.addCurve(to: CGPoint(x: 0.0298*width, y: 0.90042*height), control1: CGPoint(x: 0.03532*width, y: 0.99*height), control2: CGPoint(x: 0.00668*width, y: 0.94014*height))
        path.addLine(to: CGPoint(x: 0.2235*width, y: 0.58652*height))
        path.addCurve(to: CGPoint(x: 0.2235*width, y: 0.44998*height), control1: CGPoint(x: 0.24932*width, y: 0.54467*height), control2: CGPoint(x: 0.24932*width, y: 0.49184*height))
        path.addLine(to: CGPoint(x: 0.0298*width, y: 0.13609*height))
        path.addCurve(to: CGPoint(x: 0.08131*width, y: 0.04651*height), control1: CGPoint(x: 0.00668*width, y: 0.09637*height), control2: CGPoint(x: 0.03532*width, y: 0.04651*height))
        path.closeSubpath()
        return path
    }
}

#Preview {
    ZStack {
        FlowArrow()
            .offset(x: 120)
            .frame(width: 190, height: 200)
        FlowArrow()
            .fill(.gray)
            .frame(width: 170, height: 200)
    }
}
