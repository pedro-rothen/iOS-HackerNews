//
//  HackerNewsApp.swift
//  HackerNews
//
//  Created by Pedro on 08-08-24.
//

import SwiftUI

@main
struct HackerNewsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
