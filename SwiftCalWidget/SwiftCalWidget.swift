//
//  SwiftCalWidget.swift
//  SwiftCalWidget
//
//  Created by Peter Hartnett on 9/2/22.
//

import WidgetKit
import SwiftUI
import CoreData

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> CalendarEntry {
        CalendarEntry(date: Date(), days: [])
    }

    let viewContext = PersistenceController.shared.container.viewContext
    var dayFetchRequest: NSFetchRequest<Day> {
        let request = Day.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Day.date, ascending: true)]
        request.predicate = NSPredicate(format: "(date >= %@) AND (date <= %@)",
                                        Date().startOfCalendarWithPrefixDays as CVarArg,
                                        Date().endOfMonth as CVarArg)
        return request
    }
    
    func getSnapshot(in context: Context, completion: @escaping (CalendarEntry) -> ()) {
        
        do {
            let days = try viewContext.fetch(dayFetchRequest)
            let entry = CalendarEntry(date: Date(), days: days)
            completion(entry)
        } catch {
            print("Widget failed to fetch days")
        }
        
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        do {
            let days = try viewContext.fetch(dayFetchRequest)
            let entry = CalendarEntry(date: Date(), days: days)
            
            let timeline = Timeline(entries: [entry], policy: .after(.now.endOfDay))
            completion(timeline)
        } catch {
            print("Widget failed to fetch days")
        }

        
    }
}

struct CalendarEntry: TimelineEntry {
    let date: Date
    let days: [Day]
}

struct SwiftCalWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        HStack{
            //on medium and large widgets you can wrap a view in a link to make the taps on the widget go to a specific page of an app on a small widget you add a .widgeturl modifier to the view stack.
            Link(destination: URL(string: "streak")!) {
                VStack{
                    Text("\(calculateStreakValue())")
                        .font(.system(size: 70, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                    Text("day streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
            }
            
            Link(destination: URL(string: "calendar")!) {
            VStack{
                CalendarHeaderView(font: .caption)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 7) {
                    ForEach(entry.days) {day in
                        if day.date!.monthInt != Date().monthInt{
                            Text(" ")
                        } else {
                            
                            Text(day.date!.formatted(.dateTime.day()))
                                .font(.caption2)
                                .bold()
                                .frame(maxWidth: .infinity)
                            
                                .foregroundColor(day.didStudy ? .orange : .secondary)
                                .background(
                                    Circle()
                                        .foregroundColor(.orange.opacity(day.didStudy ? 0.3 : 0.0))
                                        .scaleEffect(1.4)
                                )
                        }
                    }
                }
            }
            }
            .padding(.leading, 6)
        }
        .padding()
    }
    
    func calculateStreakValue() -> Int {
        guard !entry.days.isEmpty else {return 0}
        
        let nonFutureDays = entry.days.filter {$0.date!.dayInt <= Date().dayInt}
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

@main
struct SwiftCalWidget: Widget {
    let kind: String = "SwiftCalWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SwiftCalWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Swift Study Calendar")
        .description("Track your study streak.")
        .supportedFamilies([.systemMedium])
    }
}

struct SwiftCalWidget_Previews: PreviewProvider {
    static var previews: some View {
        SwiftCalWidgetEntryView(entry: CalendarEntry(date: Date(), days: []))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
