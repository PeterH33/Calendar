//
//  StreakView.swift
//  Calendar
//
//  Created by Peter Hartnett on 9/1/22.
//

import SwiftUI
import CoreData

struct StreakView: View {
    
    //note this fetch request limits the length of streak to just monthly
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Day.date, ascending: true)],
        predicate: NSPredicate(format: "(date >= %@) AND (date <= %@)",
                               Date().startOfMonth as CVarArg,
                               Date().endOfMonth as CVarArg
                              ),
        animation: .default)
    private var days: FetchedResults<Day>
    
    @State private var streakValue = 0
    var body: some View {
        VStack{
            Text("\(streakValue)")
                .font(.system(size: 200, weight: .bold, design: .rounded))
                .foregroundColor(streakValue > 0 ? .orange : .secondary)
            Text("Current Streak")
                .font(.title2)
                .bold()
                .foregroundColor(.secondary)
        }
        .onAppear { streakValue = calculateStreakValue()}
    }
    
    func calculateStreakValue() -> Int {
        guard !days.isEmpty else {return 0}
        
        let nonFutureDays = days.filter {$0.date!.dayInt <= Date().dayInt}
        var streakCount = 0
        
        for day in nonFutureDays.reversed() {
            if day.didStudy {
                streakCount += 1
            } else {
                if day.date!.dayInt != Date().dayInt{
                break
                }
            }
        }
        return streakCount
    }
}

struct StreakView_Previews: PreviewProvider {
    static var previews: some View {
        StreakView()
    }
}
