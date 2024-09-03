//
//  InitialMenu.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 3/9/24.
//

import SwiftUI

struct InitialMenuView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.pushWindow) private var pushWindow

    var body: some View {
        VStack(spacing: 30) {
            Text("DOOM KANBAN")
                .font(.system(size: 100, weight: .bold))
                .fontDesign(.serif)
                .padding()
                .padding(.bottom, 200)

            Button(action: {
                pushWindow(id: "KanbanBoard")
            }) {
                Text("Abrir Kanban Layout")
                    .font(.system(size: 40, weight: .medium))
                    .frame(maxWidth: .infinity, minHeight: 120)
                    .padding()
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }

            Button(action: {
                openWindow(id: "Shelf")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    dismissWindow(id: "InitialMenu")
                }
            }) {
                Text("Abrir Window Volumétrico")
                    .font(.system(size: 40, weight: .medium))
                    .frame(maxWidth: .infinity, minHeight: 120)
                    .padding()
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
        }
        .padding()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                dismissWindow(id: "Shelf")
            }
        }
    }
}


struct InitialMenuView_Previews: PreviewProvider {
    static var previews: some View {
        InitialMenuView()
    }
}
