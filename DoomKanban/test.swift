//
//  test.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 8/8/24.
//

import SwiftUI
import RealityKit

struct test: View {
    var body: some View {
        Model3D(named: "FirstWinTrophy") { model in
                        model
                            .resizable()
                            .aspectRatio(contentMode:.fit)
                            .frame(width: 380)
                    } placeholder: {
                        ProgressView()
                    }
        
    }
}

#Preview {
    test()
}
