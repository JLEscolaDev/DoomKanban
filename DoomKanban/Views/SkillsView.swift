//
//  SkillsView.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 6/8/24.
//

import SwiftUI
struct SkillsView: View {
    struct Skill: Identifiable {
        let id = UUID()
        let icon: Image
        let coolDown: Int
        let action: () -> Void
    }
    
    let skills: [Skill]
    var orientation: Orientation = .horizontal
    @State var counter = 0
    
    var body: some View {
        GeometryReader { geometry in
            ConditionalOrientationView(orientation: orientation) {
                ForEach(Array(skills.enumerated()), id: \.element.id) {
                    index,
                    skill in
                    
                    let shadowOffset: (x: CGFloat, y: CGFloat) = shadowOffset(index: index, geometry: geometry)
                    
                    Button(
                        action: skill.action,
                        label: {
                            GeometryReader { geometry in
                                CountDownCircle(
                                    count: skill.coolDown,
                                    withIcon: skill.icon,
                                    showCountText: false,
                                    style: .continuousCountdown
                                ){skill.action()}
                            .shadowOffset(x: shadowOffset.x, y: shadowOffset.y)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                    })
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private func shadowOffset(index: Int, geometry: GeometryProxy) -> (x: CGFloat, y: CGFloat) {
        var shadowOffset: (x: CGFloat, y: CGFloat) = (0,0)
        if orientation == .horizontal {
            let xOffset = geometry.size.width * 0.008
            shadowOffset = index == 0 ? (-xOffset, 0) : index == skills.count - 1 ? (xOffset, 0) : (0, 0)
        } else {
            let xOffset = geometry.size.width * 0.06
            let initialYOffset = geometry.size.height * -0.03
            let yOffset = geometry.size.height * 0.015
            shadowOffset = index == 0 ? (xOffset, initialYOffset - yOffset) : index == skills.count - 1 ? (xOffset, initialYOffset + yOffset) : (xOffset, initialYOffset)
        }
        return shadowOffset
    }
}

#Preview {
    SkillsView_Preview()
}

fileprivate struct SkillsView_Preview: View {
    @State private var chronoCounter: Int = 0
    @State private var ancientKnoeledgeIluminationCounter: Int = 0
    @State private var augustWorkCounter: Int = 0
    @State private var clientContactCounter: Int = 0
    @State private var companyExpertiseCounter: Int = 0
    @State private var finalDeliveryCounter: Int = 0
    @State private var priorizationCounter: Int = 0
    @State private var programmerAscensionCounter: Int = 0
    @State private var programmerAscension2Counter: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            //        HStack {
            SkillsView(skills: [
                SkillsView.Skill(icon: Image(.chrono), coolDown: 2, action: {chronoCounter = 5}),
                SkillsView.Skill(icon: Image(.ancientKnoeledgeIlumination), coolDown: 3, action: {ancientKnoeledgeIluminationCounter = 2}),
                SkillsView.Skill(icon: Image(.augustWork), coolDown: 5, action: {augustWorkCounter = 3})
            ]).frame(
                width: 500,
                height: 200
            )
            
            SkillsView(skills: [
                SkillsView.Skill(icon: Image(.clientContact), coolDown: 1, action: {clientContactCounter = 3}),
                SkillsView.Skill(icon: Image(.companyExpertise), coolDown: 3, action: {companyExpertiseCounter = 7}),
                SkillsView.Skill(icon: Image(.finalDelivery), coolDown: 7, action: {finalDeliveryCounter = 4})
            ]).frame(
                width: 500,
                height: 200
            )
            SkillsView(skills: [
                SkillsView.Skill(icon: Image(.priorization), coolDown: 2, action: {priorizationCounter = 4}),
                SkillsView.Skill(icon: Image(.programmerAscension), coolDown: 4, action: {programmerAscensionCounter = 3}),
                SkillsView.Skill(icon: Image(.programmerAscension), coolDown: 6, action: {programmerAscension2Counter = 2})
            ], orientation: .vertical).frame(
                width: 200,
                height: 300
            )
            //        }
        }
    }
}
