//
//  test.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 8/8/24.
//

//import SwiftUI
//import RealityKit
//
//struct test: View {
//    var body: some View {
//        Model3D(named: "FirstWinTrophy") { model in
//                        model
//                            .resizable()
//                            .aspectRatio(contentMode:.fit)
//                            .frame(width: 380)
//                    } placeholder: {
//                        ProgressView()
//                    }
//        
//    }
//}
//
//#Preview {
//    test()
//}



//  Desglose de tareas:
//
//    skills [PENDIENTE DE DEFINIR]
//
//    Estados Card: flag, exclamation y complete.
    //    - complete: añadir temporizador (no sé si al padre o al hijo) y cuando acaba debe actualizarse el estado de la vista (con un binding? o debería ser la vista quien dispare el temporizador random definido con un tiempo por el padre?) El temporizador debe hacer algo en el padre? o sólo actualizar la tarea?
    //
    //    - Exclamation:
        //     PENDIENTE: Generación automática de tareas con este parámetro randomizado.
        //     PENDIENTE: Da el doble de puntos.


    //    - Flag: Si la tarea tiene una flag se debe entrar a la pantalla del chat para poder completarse y avanzar a la siguiente columna. La tarea con flag no puede completarse ni moverse (tengo que deshabilitar el valid drop)
            //PENDIENTE: mover el openWindow del kanbanLayout al KanbanBoard
            //PENDIENTE: Crear una pool de mensajes para la conversación.
            //PENDIENTE: no permitir que una tarea con flag avance a columnas con índices superiores
            //PENDIENTE: meter un multigesture para que, si la tarea tiene un flag, al pulsar puedas abrir el móvil.
            //PENDIENTE: Mirar si puedo cerrar el window del móvil una vez que se complete la conversación.
            //PENDIENTE: Debería dar puntos solucionar el flag? yo diría que sí. Cuando se soluciona el flag la tarea pasa automáticamente a complete (ES IMPORTANTE NO USAR UN TOGGLE PARA NO TENER UN DATA RACE SI LA TAREA SE COMPLETASE A POSTERIORI Y SE HICIERA EL TOGGLE DOS VECES)
            //OPTATIVO: Intentar dar profundidad al móvil


// PENDIENTE: Crear contador aleatorio para activar y desactivar el ojo del supervisor en el kanbanBoard

// PENDIENTE: Crear texto 3d GAME OVER cuando tienes 3 warnings del mismo tipo.
