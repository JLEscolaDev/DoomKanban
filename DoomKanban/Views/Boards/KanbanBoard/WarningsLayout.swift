//
//  WarningsLayout.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 15/9/24.
//

import SwiftUI

struct WarningsLayout: View {
    @Environment(KanbanAppVM.self) var kanbanVM
    let geometry: GeometryProxy
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(.white)
            .stroke(.black.opacity(0.5), lineWidth: 2)
            .overlay {
                VStack(alignment: .leading, spacing: 5) {
                    warningHeader
                    separator
                    warningList
                }
                .padding(.horizontal, 20)
            }
    }
    
    // Header showing the title and WardenEye
    private var warningHeader: some View {
        HStack {
            Text("Warnings")
                .font(.system(size: geometry.size.height * 0.05))
                .bold()
                .foregroundStyle(.black)
            
            Spacer()
            WardenEye()
                .foregroundStyle(.red)
                .tint(.black)
                .frame(width: geometry.size.height * 0.06, height: geometry.size.height * 0.06)
                .padding(.trailing, geometry.size.width * 0.02)
                .frame(depth: 5)
                .opacity(kanbanVM.wardenIsWatching ? 1 : 0)
        }
        .padding(.top, 30)
    }
    
    // Separator between header and warning list
    private var separator: some View {
        RoundedRectangle(cornerRadius: geometry.size.height * 0.05)
            .fill(.black)
            .frame(height: geometry.size.height * 0.001)
    }
    
    // Warning list that displays warning triangles
    private var warningList: some View {
        HStack {
            let warningStacks: [AnyView] = kanbanVM.warningList.compactMap { warningInfo in
                let triangles: [AnyView] = (0..<warningInfo.numberOfWarnings).map { _ in
                    AnyView(
                        WarningTriangle(image: Image(.shout))
                            .secondaryColor(warningInfo.projectColor.lighter())
                            .foregroundStyle(warningInfo.projectColor)
                            .tint(warningInfo.projectColor)
                            .frame(depth: 2)
                    )
                }
                
                if !triangles.isEmpty {
                    return AnyView(
                        WarningStack(warnings: triangles, offset: geometry.size.width * 0.025)
                            .frame(width: geometry.size.width * 0.13, height: geometry.size.height * 0.08)
                    )
                } else {
                    return nil
                }
            }
            
            // Display the warning stacks
            ForEach(0..<warningStacks.count, id: \.self) { index in
                warningStacks[index]
            }
        }
        .frame(alignment: .leading)
        .padding(.bottom, geometry.size.height * 0.02)
    }
}
