//
//  ContentView.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 1/8/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct SprintsLayoutView: View {
    let runningSprints: [RunningSprintIndicatorView]
    
    var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: geometry.size.width*0.1)
                .overlay {
                    VStack(spacing: 40) {
                        ForEach(runningSprints, id: \.id) { sprint in
                            VStack {
                                Text("Project \(sprint.project)")
                                    .foregroundStyle(.black)
                                    .font(.system(size: geometry.size.width*0.05))
                                sprint
                                    .frame(width: geometry.size.width*0.6, height: geometry.size.width*0.4)
                                    .frame(depth: 5)
                            }
                        }
                        Spacer()
                    }.padding(.vertical, geometry.size.height*0.05)
                }
        }
    }
}

#Preview {
    SprintsLayoutView(runningSprints: [
        RunningSprintIndicatorView(project: 1, sprint: 3, leftColor: .yellow),
        RunningSprintIndicatorView(project: 2, sprint: 2, isNextSprintTheLastOne: true, leftColor: .blue)
    ]).frame(width: 150, height: 700)
}
