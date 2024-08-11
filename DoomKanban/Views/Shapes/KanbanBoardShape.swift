//
//  KanbanBoard.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 2/8/24.
//

import SwiftUI

struct KanbanBoardShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0, y: 0.01025*height))
        path.addCurve(to: CGPoint(x: 0.01681*width, y: 0.0001*height), control1: CGPoint(x: 0, y: 0.00509*height), control2: CGPoint(x: 0.0073*width, y: 0.00081*height))
        path.addLine(to: CGPoint(x: 0.01681*width, y: 0.01025*height))
        path.addLine(to: CGPoint(x: 0.01681*width, y: 0.01318*height))
        path.addLine(to: CGPoint(x: 0.01681*width, y: 0.95922*height))
        path.addCurve(to: CGPoint(x: 0.03165*width, y: 0.98115*height), control1: CGPoint(x: 0.01681*width, y: 0.97163*height), control2: CGPoint(x: 0.01582*width, y: 0.98115*height))
        path.addLine(to: CGPoint(x: 0.97073*width, y: 0.98115*height))
        path.addCurve(to: CGPoint(x: 0.98418*width, y: 0.96454*height), control1: CGPoint(x: 0.98259*width, y: 0.98115*height), control2: CGPoint(x: 0.98418*width, y: 0.97695*height))
        path.addLine(to: CGPoint(x: 0.98319*width, y: 0.0345*height))
        path.addCurve(to: CGPoint(x: 0.96519*width, y: 0.01773*height), control1: CGPoint(x: 0.98319*width, y: 0.02128*height), control2: CGPoint(x: 0.98418*width, y: 0.01773*height))
        path.addLine(to: CGPoint(x: 0.2577*width, y: 0.01773*height))
        path.addLine(to: CGPoint(x: 0.2577*width, y: 0.14539*height))
        path.addLine(to: CGPoint(x: 0.24188*width, y: 0.14539*height))
        path.addLine(to: CGPoint(x: 0.24188*width, y: 0))
        path.addLine(to: CGPoint(x: 0.2577*width, y: 0))
        path.addLine(to: CGPoint(x: 0.27215*width, y: 0))
        path.addLine(to: CGPoint(x: 0.96519*width, y: 0))
        path.addCurve(to: CGPoint(x: width, y: 0.0345*height), control1: CGPoint(x: 0.98319*width, y: 0), control2: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: width, y: 0.96454*height))
        path.addCurve(to: CGPoint(x: 0.97073*width, y: height), control1: CGPoint(x: width, y: 0.99113*height), control2: CGPoint(x: 0.98734*width, y: height))
        path.addLine(to: CGPoint(x: 0.03165*width, y: height))
        path.addCurve(to: CGPoint(x: 0, y: 0.96809*height), control1: CGPoint(x: 0.01681*width, y: height), control2: CGPoint(x: 0, y: 0.99645*height))
        path.addLine(to: CGPoint(x: 0, y: 0.01025*height))
        path.closeSubpath()
        return path
    }
}

#Preview {
    KanbanBoardShape().frame(width: 500, height: 300)
}
