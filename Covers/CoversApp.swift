//
//  CoversApp.swift
//  Covers
//
//  Created by Michael Dacanay on 8/14/23.
//

import SwiftUI

@main
struct CoversApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
