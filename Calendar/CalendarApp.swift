//
//  CalendarApp.swift
//  Calendar
//
//  Created by Peter Hartnett on 8/31/22.
//

import SwiftUI

@main
struct CalendarApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            TabView{
                CalendarView()
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
                StreakView()
                    .tabItem {
                        Label("Streak", systemImage: "swift")
                    }
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
