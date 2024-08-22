//
//  WarningStack.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 4/8/24.
//

import SwiftUI

struct WarningStack<T: View>: View {
    var warnings: [T]
    /// Spacing between the warnings
    var offset: CGFloat

    var body: some View {
        ZStack {
            ForEach((0...warnings.count-1).reversed(), id: \.self) { index in
                warnings[index]
                    .offset(x: CGFloat(index) * offset, y: 0)
            }
        }.frame(alignment: .leading)
    }
}

#Preview {
    WarningStack(warnings: [
        WarningTriangle(image: Image(.shout)),
        WarningTriangle(image: Image(.shout))
    ], offset: 30).frame(width: 200, height: 100)
}
