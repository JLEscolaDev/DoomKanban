//
//  CountDownCircle.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 2/8/24.
//

import SwiftUI

struct CircularLoader<Content: View>: View {
    
    var progress: Double
    var customContent: (() -> Content)?
    
    init(progress: Double, @ViewBuilder customContent: @escaping () -> Content) {
        self.progress = progress
        self.customContent = customContent
    }
    
    var body: some View {
        ZStack {
            CircularLoaderBackground {
                // progress
                animatedChronoChart
            }
            // Center value
            if let customContent = customContent {
                customContent()
            }
        }
        .padding()
    }
    
    private var animatedChronoChart: some View {
        PieChart(progress: progress)
            .fill(Color.black.opacity(0.5))
            .rotationEffect(.degrees(-90)) // Rotate the view to start the animation from top
    }
}

@Observable
class CountdownTimerVM {
    var progress: Double
    var count: Int
    var isCounting: Bool = false
    private var initialValue: Int
    var countTo: Int
    var timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    init(count: Int) {
//        print("initialValue: \(initialValue)")
        self.initialValue = 0
        self.countTo = count
        self.count = 0
        self.progress = 0
    }
    
    func startTimer() {
        self.timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
        self.count = countTo
        isCounting = true
    }
    
    func stop() {
        self.timer.upstream.connect().cancel()
        isCounting = false
    }
    
    func reset() {
        count = initialValue
        stop()
        progress = 1.0
    }
    
    func start() {
        startTimer()
        guard isCounting else { return }
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.count != 0 {
                withAnimation {
                    self.count -= 1
                }
            }
            if self.count == 0 {
                timer.invalidate()
                self.stop()
                self.progress = 0
            }
        }
    }
}



struct CountDownCircle: View {
    enum Style {
        /// Animates from 100 to 0 X number of times (where X = count)
        case repeatedSingleCountdown
        
        /// Animates from 100 to 0 during X seconds (where X = count)
        case continuousCountdown
    }
    
    private let style: Self.Style
    @State private var timerVM: CountdownTimerVM
    // Timer which will publish update every tenth of a second (100 milliseconds).
    private let image: Image?
    private let showCountText: Bool
    private let startOnAppear: Bool
    private let action: () -> Void
    
    /// - Parameter action: This block of code will execute on tap if startOnAppear == false and at the end of the countDown if startOnAppear == true
    init(
        count: Int,
        withIcon: Image? = nil,
        showCountText: Bool = true,
        style: Self.Style = .repeatedSingleCountdown,
        startOnAppear: Bool = false,
        action: @escaping (() -> Void) = {}
    ) {
        self.timerVM = CountdownTimerVM(count: count)
        self.image = withIcon
        self.showCountText = showCountText
        self.style = style
        self.startOnAppear = startOnAppear
        self.action = action
    }
    
    var body: some View {
        GeometryReader { geometry in
            Button(action: {
                start()
            }) {
                CircularLoader(progress: timerVM.progress) {
                    ZStack {
                        if let image {
                            image
                                .resizable()
                                .scaledToFit()
                                .padding(geometry.size.width*0.1)
                        }
                        if showCountText && timerVM.count != 0 {
                            numericText("\(timerVM.count)")
                        }
                    }
                }.frame(width: geometry.size.width, height: geometry.size.height)
                
            }.buttonStyle(.plain)
            .disabled(timerVM.count != 0)
        }
        .onReceive(timerVM.timer) { time in
            if (timerVM.isCounting) {
                timerVM.progress = style == .repeatedSingleCountdown ? timerVM.progress-0.01 : timerVM.progress-0.01/Double(timerVM.countTo)
            }
        }
        .onChange(of: timerVM.count) { _, newValue in
            if newValue == 0 && startOnAppear {
                action()
            }
        }
        .onAppear {
            if startOnAppear {
                start()
            }
        }
    }
    
    public func start() {
        if !startOnAppear {
            action()
        }
        if timerVM.isCounting {
            timerVM.reset()
        } else {
            timerVM.start()
        }
    }
    
    private func numericText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 450))
            .minimumScaleFactor(0.01)
            .bold()
            .fontDesign(.serif)
            .foregroundColor(Color.black.opacity(0.7))
    }
}

//struct CountDownCircle: View {
//    private var initialValue: Int
//    @State private var progress: Double = 1.0
//    @State var count: Int
//    @State private var isCounting: Bool = false
//    // Timer which will publish update every tenth of a second (100 milliseconds).
//    @State private var timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
//    private let image: Image?
//    private let showCountText: Bool
//    private let action: () -> Void
//    
//    init(
//        count: Int,
//        withIcon: Image? = nil,
//        showCountText: Bool = true,
//        action: @escaping (() -> Void) = {}
//    ) {
//        self.initialValue = count
//        self.count = count
//        if count == 0 {
//            progress = 0
//        }
//        self.image = withIcon
//        self.showCountText = showCountText
//        self.action = action
//    }
//    
//    var body: some View {
//        GeometryReader { geometry in
//            Button(action: {
//                print("oldValue: \(count)")
//                action()
//                print("newValue: \(count)")
//                if isCounting {
//                    resetTimer()
//                } else {
//                    startCountdown()
//                }
//            }) {
//                CircularLoader(progress: progress) {
//                    ZStack {
//                        if let image {
//                            image
//                                .resizable()
//                                .scaledToFit()
//                                .padding(geometry.size.width*0.05)
//                        }
//                        if showCountText && count != 0 {
//                            numericText("\(count)")
//                        }
//                    }
//                }.frame(width: geometry.size.width, height: geometry.size.height)
//                
//            }.buttonStyle(.plain)
//                .disabled(count != 0)
//        }
//        .onReceive(timer) { time in
//            if (isCounting) {
//                progress = progress-0.01
//            }
//        }
//    }
//    
//    private func numericText(_ text: String) -> some View {
//        Text(text)
//            .font(.system(size: 450))
//            .minimumScaleFactor(0.01)
//            .bold()
//            .fontDesign(.serif)
//            .foregroundColor(Color.black.opacity(0.7))
//    }
//    
//    func startTimer() {
//        self.timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
//        isCounting = true
//    }
//    
//    func stopTimer() {
//        self.timer.upstream.connect().cancel()
//        isCounting = false
//    }
//    
//    func resetTimer() {
//        count = initialValue
//        stopTimer()
//        progress = 1.0
//    }
//    
//    func startCountdown() {
//        startTimer()
//        guard isCounting else { return }
//        
//        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
//            if count != 0 {
//                withAnimation {
//                    count -= 1
//                }
//            } else {
//                timer.invalidate()
////                resetTimer()
//                stopTimer()
//                stopTimer()
//                progress = 0
//            }
//        }
//    }
//}


#Preview {
    CountDownCircle_Preview()
//    VStack {
//        CountDownCircle(count: 5){}.frame(width: 300, height: 300)
//        CountDownCircle(count: 5, withIcon: Image(.chrono)){}.frame(width: 300, height: 300)
//        CountDownCircle(count: 0, withIcon: Image(.chrono)){}.frame(width: 300, height: 300)
//    }
}

struct CountDownCircle_Preview: View {
    var body: some View {
        CountDownCircle(count: 5, withIcon: Image(.chrono)){print("Counter button action")}.frame(width: 300, height: 300)
    }
}
