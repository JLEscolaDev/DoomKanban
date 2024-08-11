//
//  View+AspectRatio.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 8/8/24.
//

import SwiftUI

extension View {
    func keepAspectRatio() -> some View {
        self.onAppear {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                return
            }
                
            windowScene.requestGeometryUpdate(.Vision(resizingRestrictions: UIWindowScene.ResizingRestrictions.uniform))
        }
    }
}
