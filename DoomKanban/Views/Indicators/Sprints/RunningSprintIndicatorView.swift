//
//  RunningSprintIndicatorView.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 2/8/24.
//

import SwiftUI

struct RunningSprintIndicatorView: View {
    let sprintVM: RunningSprintVM

    init(_ sprint: RunningSprintVM) {
        self.sprintVM = sprint
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
                if sprintVM.isNextSprintTaskTheLastOne {
                    lastTaskRoundedRectangleShape(geometry: geometry, width: rightRectangleWidth, height: rightRectangleHeight, offset: rightRectangleOffset)
                        
                } else {
                    remainingTasksOfSprintArrowShape(geometry: geometry, width: rightFlowArrowWidth, height: rightFlowArrowHeight, offset: rightFlowArrowOffset)
                }
                sprintProjectArrowShape(geometry: geometry, width: leftFlowArrowWidth, height: leftFlowArrowHeight, offset: leftFlowArrowOffset)
                
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    
    
    
}

extension RunningSprintIndicatorView {
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
        Text("\(sprintVM.sprint.sprintNum)")
            .font(.system(size: geometry.size.height*0.45))
            .bold()
            .fontDesign(.serif)
            .foregroundStyle(.black)
    }
    
    private func remainingTasks(geometry: GeometryProxy) -> some View {
        Text("\(sprintVM.customRemainingTasksCount ?? sprintVM.sprint.tasks.count)")
            .font(.system(size: geometry.size.height*0.3))
            .bold()
            .foregroundStyle(.black)
    }
    
    /// Rounded rectangle that is displayed on the right part of the indicator to show the las task of the sprint
    private func lastTaskRoundedRectangleShape(
        geometry: GeometryProxy,
        width: CGFloat,
        height: CGFloat,
        offset: CGFloat
    ) -> some View {
        RoundedRectangle(cornerRadius: geometry.size.height*0.1)
            .fill(sprintVM.rightColor ?? .white)
            .stroke(.black, lineWidth: geometry.size.height*0.015)
            .shadow(radius: 2)
            .overlay {
                GeometryReader { rectangleGeometry in
                    addContent(title: "Last task", geometry: rectangleGeometry, parentViewHeight: geometry)
                        .padding(.trailing, geometry.size.width*0.2)
                        .padding(.top, geometry.size.height*0.05)
                        .offset(x: rectangleGeometry.size.width*0.13)
                }.offset(x: geometry.size.width*0.05)
            }
            .overlay {
                remainingTasks(geometry: geometry)
                    .offset(x: geometry.size.width*0.05)
            }
            .frame(width: width, height: height)
            .offset(x: offset)
    }
    
    /// Arrow shape displayed at the right part of the indicator to show the remaining tasks to finish the current sprint
    fileprivate func remainingTasksOfSprintArrowShape(
        geometry: GeometryProxy,
        width: CGFloat,
        height: CGFloat,
        offset: CGFloat
    ) -> some View {
        return FlowArrow()
            .fill(sprintVM.rightColor ?? Color(UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1)) )
            .stroke(.black, lineWidth: geometry.size.height*0.015)
            .shadow(radius: 2)
            .overlay {
                GeometryReader { arrowGeometry in
                    addContent(title: "Ends in", geometry: arrowGeometry, parentViewHeight: geometry)
                        .padding(.trailing, geometry.size.width*0.18)
                        .padding(.top, geometry.size.height*0.1)
                }
            }
            .overlay {
                remainingTasks(geometry: geometry)
            }
            .frame(width: width, height: height)
            .offset(x: offset)
    }
    
    /// Arrow shape displayed on the left part of the indicator that displays the proyect number
    fileprivate func sprintProjectArrowShape(
        geometry: GeometryProxy,
        width: CGFloat,
        height: CGFloat,
        offset: CGFloat
    ) -> some View {
        return FlowArrow()
            .fill(sprintVM.leftColor)
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
            .frame(width: width, height: height)
            .offset(x: offset)
    }
}

#Preview {
    let tasks1: [KanbanTask] = [
        .init(projectId: 1, sprintId: 3,title: "Esto es un test", color: .blue, value: 3),
        .init(projectId: 1, sprintId: 3,title: "Segunda tarea", color: .blue, value: 4),
        .init(projectId: 1, sprintId: 3,title: "Título: Tercera tarea", color: .blue, value: 2)
    ]
    
    let tasks2: [KanbanTask] = [
        .init(projectId: 2, sprintId: 1,title: "Project 2 - Prueba 1", color: .red, value: 3),
        .init(projectId: 2, sprintId: 1,title: "P2.Segunda tarea", color: .red, value: 4)
    ]
    
    let tasks3: [KanbanTask] = [
        .init(projectId: 3, sprintId: 1,title: "Project 3: First Task", color: .green, value: 2),
        .init(projectId: 3, sprintId: 1,title: "Project 3: La tarea final", color: .green, value: 5)
    ]
    
    VStack {
        RunningSprintIndicatorView(
            RunningSprintVM(sprint:
                                KanbanSprint(project: 1,
                                             projectColor: .blue,
                                             sprintNum: 3,
                                             tasks: tasks1)
                            )
        ).frame(width: 100, height: 80)
        
        RunningSprintIndicatorView(
            RunningSprintVM(sprint:
                                KanbanSprint(project: 2,
                                             projectColor: .red,
                                             sprintNum: 1,
                                             tasks: tasks2)
                            )
        ).frame(width: 300, height: 190)
        
        RunningSprintIndicatorView(
            RunningSprintVM(sprint:
                                KanbanSprint(project: 3,
                                             projectColor: .yellow,
                                             sprintNum: 1,
                                             tasks: tasks3)
                            )
        ).frame(width: 300, height: 190)
    }
    
}
