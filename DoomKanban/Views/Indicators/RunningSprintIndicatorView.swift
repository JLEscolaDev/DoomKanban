//
//  RunningSprintIndicatorView.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 2/8/24.
//

import SwiftUI

struct RunningSprintIndicatorView: View {
    var id: String {
        "\(project) \(sprint)"
    }
    let project: Int
    let sprint: Int
    let leftColor: Color
    let rightColor: Color?
    var isNextSprintTheLastOne: Bool

    init(project: Int,
         sprint: Int,
        isNextSprintTheLastOne: Bool = false,
         leftColor: Color,
         rightColor: Color? = nil
    ) {
        self.project = project
        self.sprint = sprint
        self.isNextSprintTheLastOne = isNextSprintTheLastOne
        self.leftColor = leftColor
        self.rightColor = rightColor
    }
    
    enum defaultSizes {
        static let defaultWidth: CGFloat = 300
        static let defaultHeight: CGFloat = 200
        static let rightRectangleWidth: CGFloat = 190
        static let rightRectangleHeight: CGFloat = 190
        static let rightRectangleOffset: CGFloat = 50
        static let rightFlowArrowWidth: CGFloat = 200
        static let rightFlowArrowHeight: CGFloat = 200
        static let rightFlowArrowOffset: CGFloat = 35
        static let leftFlowArrowWidth: CGFloat = 160
        static let leftFlowArrowHeight: CGFloat = 200
        static let leftFlowArrowOffset: CGFloat = -65
    }
    
    var body: some View {
        GeometryReader { geometry in
            let rightRectangleWidth: CGFloat = (geometry.size.width * defaultSizes.rightRectangleWidth) / defaultSizes.defaultWidth
            let rightRectangleHeight: CGFloat = (geometry.size.height * defaultSizes.rightRectangleHeight) / defaultSizes.defaultHeight
            let rightRectangleOffset: CGFloat = (geometry.size.width * defaultSizes.rightRectangleOffset) / defaultSizes.defaultWidth
            
            let rightFlowArrowWidth: CGFloat = (geometry.size.width * defaultSizes.rightFlowArrowWidth) / defaultSizes.defaultWidth
            let rightFlowArrowHeight: CGFloat = (geometry.size.height * defaultSizes.rightFlowArrowHeight) / defaultSizes.defaultHeight
            let rightFlowArrowOffset: CGFloat = (geometry.size.width * defaultSizes.rightFlowArrowOffset) / defaultSizes.defaultHeight
            
            let leftFlowArrowWidth: CGFloat = (geometry.size.width * defaultSizes.leftFlowArrowWidth) / defaultSizes.defaultWidth
            let leftFlowArrowHeight: CGFloat = (geometry.size.height * defaultSizes.leftFlowArrowHeight) / defaultSizes.defaultHeight
            let leftFlowArrowOffset: CGFloat = (geometry.size.width * defaultSizes.leftFlowArrowOffset) / defaultSizes.defaultWidth
            
            return ZStack(alignment: .centerLastTextBaseline) {
                if isNextSprintTheLastOne {
                    RoundedRectangle(cornerRadius: geometry.size.height*0.1)
                        .fill(rightColor ?? .white)
                        .stroke(.black, lineWidth: geometry.size.height*0.015)
                        .shadow(radius: 2)
                        .overlay {
                            GeometryReader { rectangleGeometry in
                                addContent(title: "Ends in", geometry: rectangleGeometry, parentViewHeight: geometry)
                                    .padding(.trailing, geometry.size.width*0.2)
                                    .padding(.top, geometry.size.height*0.05)
                                    .offset(x: rectangleGeometry.size.width*0.13)
                            }.offset(x: geometry.size.width*0.05)
                        }
                        .overlay {
                            nextSprintCountDown(geometry: geometry)
                                .offset(x: geometry.size.width*0.05)
                        }
                        .frame(width: rightRectangleWidth, height: rightRectangleHeight)
                        .offset(x: rightRectangleOffset)
                        
                } else {
                    FlowArrow()
                        .fill(rightColor ?? Color(UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1)) )
                        .stroke(.black, lineWidth: geometry.size.height*0.015)
                        .shadow(radius: 2)
                        .overlay {
                            GeometryReader { arrowGeometry in
                                addContent(title: "Next in", geometry: arrowGeometry, parentViewHeight: geometry)
                                    .padding(.trailing, geometry.size.width*0.18)
                                    .padding(.top, geometry.size.height*0.1)
                            }
                        }
                        .overlay {
                            nextSprintCountDown(geometry: geometry)
                        }
                        .frame(width: rightFlowArrowWidth, height: rightFlowArrowHeight)
                        .offset(x: rightFlowArrowOffset)
                }
                FlowArrow()
                    .fill(leftColor)
                    .stroke(.black, lineWidth: geometry.size.height*0.015)
                    .shadow(radius: 2)
                    .overlay {
                        GeometryReader { arrowGeometry in
                            addContent(title: "Sprint", geometry: arrowGeometry, parentViewHeight: geometry)
                                .padding(.trailing, geometry.size.width*0.1)
                                .padding(.top, geometry.size.height*0.1)
                                .offset(x: -arrowGeometry.size.width*0.1)
                        }
                    }
                    .overlay {
                        sprintValue(geometry: geometry)
                    }
                    .offset(x: leftFlowArrowOffset)
                    .frame(width: leftFlowArrowWidth, height: leftFlowArrowHeight)
                
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    /// Here we use the parentViewHeight to match all the font sizes keeping available the scalability of the text (if we use the geometry of the overlay, the sizes does not match and the fonts are different).
    func addContent(title: String, geometry: GeometryProxy, parentViewHeight: GeometryProxy) -> some View {
        HStack {
            Spacer()
            Text(title)
                .font(.system(size: parentViewHeight.size.height*0.1))
                .fontWeight(.black)
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .frame(width: geometry.size.width*0.65)
        }
    }
    
    private func sprintValue(geometry: GeometryProxy) -> some View {
        Text("\(sprint)")
            .font(.system(size: geometry.size.height*0.45))
            .bold()
            .fontDesign(.serif)
            .foregroundStyle(.black)
    }
    
    private func nextSprintCountDown(geometry: GeometryProxy) -> some View {
        Text("\(sprint)")
            .font(.system(size: geometry.size.height*0.3))
            .bold()
            .foregroundStyle(.black)
    }
}

#Preview {
    VStack {
        RunningSprintIndicatorView(project: 1, sprint: 4, leftColor: .blue)
            .frame(width: 100, height: 80)
        RunningSprintIndicatorView(project: 2, sprint: 1, leftColor: .white)
            .frame(width: 300, height: 190)
        RunningSprintIndicatorView(project: 3, sprint: 1, isNextSprintTheLastOne: true, leftColor: .yellow)
            .frame(width: 300, height: 190)
    }
    
}
