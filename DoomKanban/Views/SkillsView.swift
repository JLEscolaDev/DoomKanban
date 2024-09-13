//
//  SkillsView.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 6/8/24.
//

import SwiftUI

enum SkillType {
    case chronoMaster
    case businessMan
    case companyExpert
    case prioritisation
    case ancientKnowledgeIllumination
    case programmerAscension
    case august
    case finalDelivery
}
struct SkillsView: View {
    struct Skill: Identifiable {
        let id = UUID()
        let icon: Image
        let coolDown: Int
        let type: SkillType
    }
    
    @Environment(KanbanAppVM.self) var kanbanVM
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
                        action:
                            {},
                        label: {
                            GeometryReader { geometry in
                                CountDownCircle(
                                    count: skill.coolDown,
                                    withIcon: skill.icon,
                                    showCountText: false,
                                    style: .continuousCountdown
                                ){
                                    performAction(from: skill.type)
                                }
                                .shadowOffset(Offset(x: shadowOffset.x, y: shadowOffset.y))
                            .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                    })
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    func performAction(from type: SkillType) {
        switch type {
        case .chronoMaster:
                showNextTaskCountDown()
        case .businessMan:
                reduceNextTasksToHalf()
        case .companyExpert:
            // To be implemented
            break
        case .prioritisation:
                // To be implemented
                break
        case .ancientKnowledgeIllumination:
                // To be implemented
                break
        case .programmerAscension:
                // To be implemented
                break
        case .august:
                // To be implemented
                break
        case .finalDelivery:
                // To be implemented
                break
        }
    }
    
    /// Allows the user to see the next task countdown for 9 seconds
    private func showNextTaskCountDown() {
        kanbanVM.showNextTaskCounterView = true
        
        Task {
            try await Task.sleep(nanoseconds: 9_000_000_000)
            kanbanVM.showNextTaskCounterView = false
        }
    }
    
    /// Reduces the next tasks to half
    private func reduceNextTasksToHalf() {
        let halfCount = kanbanVM.mixedTasks.count / 2
        kanbanVM.mixedTasks = Array(kanbanVM.mixedTasks.prefix(halfCount))
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
    @State private var prioritisationCounter: Int = 0
    @State private var programmerAscensionCounter: Int = 0
    @State private var programmerAscension2Counter: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            //        HStack {
            SkillsView(skills: [
                SkillsView.Skill(icon: Image(.chrono), coolDown: 10, type: .chronoMaster),
                SkillsView.Skill(icon: Image(.ancientKnoeledgeIlumination), coolDown: 3, type: .ancientKnowledgeIllumination),
                SkillsView.Skill(icon: Image(.augustWork), coolDown: 5, type: .august)
            ]).frame(
                width: 500,
                height: 200
            )
            
            SkillsView(skills: [
                SkillsView.Skill(icon: Image(.clientContact), coolDown: 1, type: .businessMan),
                SkillsView.Skill(icon: Image(.companyExpertise), coolDown: 3, type: .companyExpert),
                SkillsView.Skill(icon: Image(.finalDelivery), coolDown: 7, type: .finalDelivery)
            ]).frame(
                width: 500,
                height: 200
            )
            SkillsView(skills: [
                SkillsView.Skill(icon: Image(.prioritisation), coolDown: 2, type: .prioritisation),
                SkillsView.Skill(icon: Image(.programmerAscension), coolDown: 4, type: .programmerAscension),
                SkillsView.Skill(icon: Image(.programmerAscension), coolDown: 6, type: .programmerAscension)
            ], orientation: .vertical).frame(
                width: 200,
                height: 300
            )
            //        }
        }
    }
}
