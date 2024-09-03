//
//  WarningInfo.swift
//  DoomKanban
//
//  Created by Jose Luis Escolá García on 23/8/24.
//

import SwiftUI

struct WarningsInfo: Identifiable, Equatable {
    /// ProjectId
    var id: Int
    var projectColor: Color
    var numberOfWarnings: Int
}
extension Array where Element == WarningsInfo {
    
    // Obtener o crear un elemento por id
    mutating func getOrCreate(id: Int) -> WarningsInfo {
        if let index = firstIndex(where: { $0.id == id }) {
            return self[index]
        } else {
            let newElement = WarningsInfo(id: id, projectColor: .gray, numberOfWarnings: 0)
            append(newElement)
            return newElement
        }
    }
    
    // Actualizar un elemento existente o agregarlo si no existe
    mutating func update(_ info: WarningsInfo) {
        if let index = firstIndex(where: { $0.id == info.id }) {
            self[index] = info
        } else {
            append(info)
        }
    }
    
    // Eliminar un elemento por id
    mutating func remove(id: Int) {
        if let index = firstIndex(where: { $0.id == id }) {
            remove(at: index)
        }
    }
}

//
//// ℹ️ We implement this to use this in kanbanBoard as an observable dictionary
//extension Array where Element == WarningsInfo {
//    subscript(id: Int) -> WarningsInfo {
//        mutating get {
//            if let index = self.firstIndex(where: { $0.id == id }) {
//                // Encontró el elemento, lo devuelve
//                print("✅ Element found with id: \(id) at index: \(index) with numberOfWarnings: \(self[index].numberOfWarnings)")
//                return self[index]
//            } else {
//                // No encontró el elemento, crea uno nuevo y lo devuelve
//                let newElement = WarningsInfo(id: id, projectColor: .gray, numberOfWarnings: 0)
//                self.append(newElement)
//                print("⚠️ Element not found, appending new element with id: \(id)")
//                return newElement
//            }
//        }
//        set {
//            if let index = self.firstIndex(where: { $0.id == id }) {
//                // Actualiza el elemento existente
//                self[index] = newValue
//                print("🔄 Updated element at index: \(index) with id: \(id) and numberOfWarnings: \(newValue.numberOfWarnings)")
//            } else {
//                // Agrega el nuevo elemento al array
//                self.append(newValue)
//                print("➕ Appended new element with id: \(id) and numberOfWarnings: \(newValue.numberOfWarnings)")
//            }
//        }
//    }
//
//    mutating func remove(id: Element.ID) {
//        if let index = self.firstIndex(where: { $0.id == id }) {
//            self.remove(at: index)
//            print("🗑️ Removed element with id: \(id) at index: \(index)")
//        } else {
//            print("⚠️ Element with id \(id) not found, nothing to remove")
//        }
//    }
//}
