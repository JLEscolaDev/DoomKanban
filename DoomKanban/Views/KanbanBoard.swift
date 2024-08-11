//
//  KanbanBoard.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 3/8/24.
//

import SwiftUI
import Algorithms

struct KanbanBoard: View {
    private let nextTaskAnimationTime: Int = 2
    @State private var counter = 3
    @State private var nextTaskPosition: CGPoint = .zero
    @State private var animateNextTask: Bool = false
    @State private var doingColumnIsTargeted: Bool = false
    @State private var testingColumnIsTargeted: Bool = false
    @State private var doneColumnIsTargeted: Bool = false
    
    @State private var nextCards: [KanbanTask] = [
        .init(title: "Esto es un test", color: .blue, value: 3),
        .init(title: "Esto es un test", color: .yellow, value: 3),
        .init(title: "Esto es un test", color: .green, value: 3),
        .init(title: "Esto es un test", color: .red, value: 5)
    ]
    
    @State private var toDoTasks: [KanbanTask] = [
    ]
    @State private var inProgressTasks: [KanbanTask] = [
    ]
    @State private var testingTasks: [KanbanTask] = [
    ]
    @State private var doneTasks: [KanbanTask] = [
    ]
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack(spacing: 0) {
                    VStack(spacing: 5) {
                        ZStack {
                            Text("Next task")
                                .foregroundStyle(.black)
                                .bold()
                                .font(.system(size: geometry.size.height * 0.04))
                        }
                        let kanbanCardWidth = geometry.size.width / 5
                        let kanbanCardHeight = geometry.size.height * 0.13
                        let kanbanCardInitialYPosition: CGFloat = 50
                        let kanbanCardInitialXPosition: CGFloat = kanbanCardWidth / 2
                        let kanbanCardFinalYPosition = kanbanCardInitialYPosition + geometry.size.height * 0.75
                        let kanbanCardInitialPosition = CGPoint(x: kanbanCardWidth / 2, y: kanbanCardInitialYPosition)
                        
                        ZStack {
                            if nextCards.count > 1 {
                                //                                let card2Position = nextTaskPosition == kanbanCardInitialPosition ? CGPoint(x: kanbanCardInitialXPosition, y: kanbanCardFinalYPosition) : kanbanCardInitialPosition
                                KanbanCard(task: nextCards[1])
                                    .frame(depth: 30)
                                    .background {
                                        VStack {
                                            Spacer()
                                            LinearGradient(
                                                gradient: Gradient(stops: [
                                                    .init(color: .black.opacity(0.4), location: 0.52),
                                                    .init(color: .gray.opacity(0.8), location: 1.0)
                                                ]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                            .frame(width: geometry.size.width / 7, height: geometry.size.height * 0.07)
                                            .shadow(color: .black, radius: 2, y: geometry.size.height * 0.06)
                                            Spacer()
                                        }
                                    }
                                    .position(kanbanCardInitialPosition)
                                    .opacity(animateNextTask ? 1 : 0)
                            }
                            
                            if let card = nextCards.first {
                                KanbanCard(task: card)
                                    .frame(depth: 1)
                                    .background {
                                        VStack {
                                            Spacer()
                                            LinearGradient(
                                                gradient: Gradient(stops: [
                                                    .init(color: .black.opacity(0.4), location: 0.52),
                                                    .init(color: .gray.opacity(0.8), location: 1.0)
                                                ]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                            .frame(width: geometry.size.width / 7, height: geometry.size.height * 0.07)
                                            .shadow(color: .black, radius: 2, y: geometry.size.height * 0.06)
                                            Spacer()
                                        }
                                    }
                                    .draggable(card)
                                    .position(nextTaskPosition)
                                //                                .opacity(useCard1 ? 0 : 1)
                            }
                            
                        }
                        .frame(width: kanbanCardWidth, height: kanbanCardHeight)
                        .padding(.top, 15)
                        .onChange(of: animateNextTask) {_, newValue in
                            if newValue == true {
                                
                                withAnimation(.easeInOut(duration: TimeInterval(nextTaskAnimationTime))) {
                                    var finalPosition = kanbanCardInitialPosition
                                    finalPosition.y = kanbanCardFinalYPosition
                                    nextTaskPosition = finalPosition
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + Double(nextTaskAnimationTime)) {
                                    //                                        useCard1.toggle()
                                    if let task = nextCards.first {
                                        toDoTasks.append(task)
                                        nextCards.removeFirst()
                                    }
                                    nextTaskPosition = kanbanCardInitialPosition
                                }
                            }
                        }
                        .onAppear {
                            nextTaskPosition = kanbanCardInitialPosition
                        }
                    }
                    .padding(.leading, geometry.size.width * 0.035)
                    .padding(.trailing, geometry.size.width * 0.025)
                    .overlay {
                        if counter != 0 {
                            addCountDownView(geometry: geometry)
                                .opacity(nextCards.isEmpty ? 0 : 1)
                                .allowsHitTesting(false) // Disable user interaction so the user can drag and drop the card
                        }
                    }
                    
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.white)
                        .stroke(.black.opacity(0.5), lineWidth: 2)
                        .overlay {
                            VStack(alignment: .leading, spacing: 5) {
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
                                }.padding(.top, 30)
                                RoundedRectangle(cornerRadius: geometry.size.height * 0.05)
                                    .fill(.black)
                                    .frame(width: .infinity, height: geometry.size.height * 0.001)
                                HStack {
                                    WarningStack(warnings: [
                                        WarningTriangle(image: Image("shout")).accentColor(Color(red: 135 / 255, green: 199 / 255, blue: 235 / 255))
                                            .foregroundStyle(.blue)
                                            .tint(.blue)
                                            .frame(depth: 2),
                                        WarningTriangle(image: Image("shout")).accentColor(Color(red: 135 / 255, green: 199 / 255, blue: 235 / 255))
                                            .foregroundStyle(.blue)
                                            .tint(.blue)
                                            .frame(depth: 2)
                                        
                                    ], offset: geometry.size.width * 0.025)
                                    .frame(width: geometry.size.width * 0.13, height: geometry.size.height * 0.08)
                                    
                                    WarningStack(warnings: [
                                        WarningTriangle(image: Image("shout")).accentColor(Color(red: 135 / 255, green: 199 / 255, blue: 235 / 255))
                                            .foregroundStyle(.blue)
                                            .tint(.blue)
                                            .frame(depth: 2),
                                        WarningTriangle(image: Image("shout")).accentColor(Color(red: 135 / 255, green: 199 / 255, blue: 235 / 255))
                                            .foregroundStyle(.blue)
                                            .tint(.blue)
                                            .frame(depth: 2)
                                    ], offset: geometry.size.width * 0.025)
                                    .frame(width: geometry.size.width * 0.13, height: geometry.size.height * 0.08)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, geometry.size.height * 0.02)
                                
                                Spacer()
                            }.padding(.horizontal, 20)
                        }
                }.padding(.vertical, 10)
                    .padding(.trailing, 10)
                Spacer()
                ZStack {
                    HStack(spacing: 0) {
                        KanbanColumn(title: "To Do", color: .red, tasks: toDoTasks) {
                            Rectangle()
                            .dropDestination(for: KanbanTask.self) { kanbanTasks, location in

                                for task in kanbanTasks {
                                    inProgressTasks.removeAll { $0 == task }
                                    testingTasks.removeAll { $0 == task }
                                    doneTasks.removeAll { $0 == task}
                                }
                                let totalTasks = toDoTasks + kanbanTasks
                                // We use .uniqued() instead of Array(Set(totalTasks)).sorted() because uniqued() keeps the same order. Complexity without needing the same exact order should be the same O(n)
                                toDoTasks = Array(totalTasks.uniqued())
                                
                                return true
                            }
                        }
                        
                        KanbanColumn(title: "Doing", color: .cyan, tasks: inProgressTasks) {
                            Rectangle()
                                .dropDestination(for: KanbanTask.self) { kanbanTasks, location in
                                    
                                    for task in kanbanTasks {
                                        toDoTasks.removeAll { $0 == task }
                                        testingTasks.removeAll { $0 == task }
                                        doneTasks.removeAll { $0 == task}
                                    }
                                    let totalTasks = inProgressTasks + kanbanTasks
                                    // We use .uniqued() instead of Array(Set(totalTasks)).sorted() because uniqued() keeps the same order. Complexity without needing the same exact order should be the same O(n)
                                    inProgressTasks = Array(totalTasks.uniqued())
                                    
                                    return true
                                } isTargeted: { isTargeted in
                                    doingColumnIsTargeted = isTargeted
                                }
                        }
                        
                        KanbanColumn(title: "Testing", color: .blue, tasks: testingTasks) {
                            Rectangle()
                                .dropDestination(for: KanbanTask.self) { kanbanTasks, location in
                                    
                                    for task in kanbanTasks {
                                        toDoTasks.removeAll { $0 == task }
                                        inProgressTasks.removeAll { $0 == task }
                                        doneTasks.removeAll { $0 == task }
                                    }
                                    let totalTasks = testingTasks + kanbanTasks
                                    // We use .uniqued() instead of Array(Set(totalTasks)).sorted() because uniqued() keeps the same order. Complexity without needing the same exact order should be the same O(n)
                                    testingTasks = Array(totalTasks.uniqued())
                                    
                                    return true
                                } isTargeted: { isTargeted in
                                    testingColumnIsTargeted = isTargeted
                                }
                        }
                        
                        KanbanColumn(title: "Done", color: .green, tasks: doneTasks) {
                            Rectangle()
                                .dropDestination(for: KanbanTask.self) { kanbanTasks, location in
                                            var allowDragAndDrop = true

                                            // Verificar si alguna de las tareas arrastradas está en "To Do"
                                            for task in kanbanTasks {
                                                if toDoTasks.contains(task) || inProgressTasks.contains(task) {
                                                    allowDragAndDrop = false
                                                    break // No necesitamos seguir revisando si ya hemos encontrado que no es válido
                                                }
                                            }

                                            // Si el drop es permitido, procedemos con la operación
                                            if allowDragAndDrop {
                                                for task in kanbanTasks {
                                                    inProgressTasks.removeAll { $0 == task }
                                                    testingTasks.removeAll { $0 == task }
                                                    
                                                    doneTasks.append(task)
                                                }
                                            }
                                            
                                            return allowDragAndDrop
                                        } isTargeted: { isTargeted in
                                            doneColumnIsTargeted = isTargeted
                                        }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
                    KanbanBoardShape()
                        .foregroundStyle(.black)
                }
                .background {
                    RoundedRectangle(cornerRadius: 25.0)
                        .fill(.white.opacity(0.8))
                }
                .frame(height: geometry.size.height * 0.75)
            }
        }.onAppear {
            animateNextTasksSequentially()
        }
    }
    
    private func animateNextTasksSequentially() {
        for index in nextCards.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index * counter)) {
                animateNextTask = true
                //                    animateNextTask = false
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(nextTaskAnimationTime)) {
                    animateNextTask = false
                }
            }
        }
    }
    
    private enum Column {
        case ToDo
        case Doing
        case Testing
        case Done
    }
    
    private func addCountDownView(geometry: GeometryProxy) -> some View {
        let nextKanbanCardSize = geometry.size.width / 5
        let minSize = min(geometry.size.width, geometry.size.height)
        let counterSize = minSize * 0.11
        let countDown = CountDownCircle(
            count: counter,
            startOnAppear: true,
            action: {
                print("Pendiente de implementar el lanzamiento de la carta y el reinicio del contador")
                animateNextTask = false
            })
        
        return countDown
            .frame(width: counterSize, height: counterSize)
            .frame(depth: 1)
            .offset(x: nextKanbanCardSize / 2 - 15, y: -10)
    }
}

#Preview(windowStyle: .plain) {
    KanbanBoard().frame(width: 700, height: 700)
}


struct KanbanColumn<Content: View>: View {
    let title: String
    let color: Color
    let tasks: [KanbanTask]
    var dropDestination: () -> Content
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .top, spacing: 0) {
                VStack(spacing: 0) {
                    ZStack {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: color, location: 0.52),
                                        .init(color: color.darker(by: 0.4), location: 1.0)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        Text(title)
                            .font(.title)
                            .fontDesign(.serif)
                            .foregroundStyle(.black)
                    }
                    .frame(height: geometry.size.height * 0.145)
                    
                    dropDestination()
                        .overlay {
                            VStack(spacing: geometry.size.height*0.04) {
                                Spacer(minLength: 0)
                                ForEach(Array(tasks.reversed().enumerated()), id: \.element.id) { index, task in
                                    KanbanCard(task: task)
                                        .frame(height: geometry.size.height*0.17)
                                        .draggable(task)
                                        .allowsHitTesting(true)
                                }
                            }
                            .padding(.bottom, geometry.size.height*0.05)
                            .padding(.horizontal, geometry.size.height*0.03)
                        }
                }
                Rectangle()
                    .foregroundStyle(.black.opacity(0.9))
                    .frame(width: geometry.size.width * 0.005)
            }
        }
    }
}
