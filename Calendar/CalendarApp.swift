//
//  CalendarApp.swift
//  Calendar
//
//  Created by Peter Hartnett on 8/31/22.
//

import SwiftUI

// Setting up the main app like this lets us hold our tab view in a nice easy place and control the widget taps at the same time, a good way to isolate some navigation functionality of the app in general

@main
struct CalendarApp: App {
    
    let persistenceController = PersistenceController.shared
    @State private var selectedTab = 0
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab){
                CalendarView()
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
                    .tag(0)
                StreakView()
                    .tabItem {
                        Label("Streak", systemImage: "swift")
                    }
                    .tag(1)
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .onOpenURL{ url in
                selectedTab = url.absoluteString == "calendar" ? 0 : 1
            }
        }
    }
}
