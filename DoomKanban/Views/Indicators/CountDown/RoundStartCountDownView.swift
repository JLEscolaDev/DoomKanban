//
//  RoundStartCountDown.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 13/9/24.
//

import SwiftUI

struct RoundCountdownView: View {
    @State private var isCountingDown = true // Estado para saber si sigue la cuenta regresiva
    let round: Int // Environment para obtener el view model
    @State var countdown: Int = 3 // Estado para la cuenta regresiva
    let completionHandler: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Round \(round)") // Número de ronda
                .font(.extraLargeTitle)
                .fontWeight(.heavy)
                .foregroundColor(.blue.darker())

            if isCountingDown {
                Text("\(countdown)") // Mostramos la cuenta regresiva
                    .font(.system(size: 80))
                    .bold()
                    .foregroundColor(.red)
            } else {
                Text("GO!") // Mostramos 'GO!' al final de la cuenta regresiva
                    .font(.system(size: 80))
                    .fontWeight(.heavy)
                    .foregroundColor(.green)
            }
        }
        .onAppear {
            startCountdown() // Iniciamos la cuenta regresiva al cargar la vista
        }
    }
    
    // Función para manejar la cuenta regresiva de 3 a 0
    func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer.invalidate() // Detenemos el timer cuando llegue a 0
                isCountingDown = false
                completionHandler?()
            }
        }
    }
}

#Preview {
    RoundCountdownView(round: 1, countdown: 3) {
       print("START")
    }
}
