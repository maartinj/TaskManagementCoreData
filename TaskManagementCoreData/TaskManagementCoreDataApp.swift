//
//  TaskManagementCoreDataApp.swift
//  TaskManagementCoreData
//
//  Created by Marcin Jędrzejak on 14/04/2023.
//

import SwiftUI

@main
struct TaskManagementCoreDataApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
