//
//  CalendarHeaderView.swift
//  Calendar
//
//  Created by Peter Hartnett on 9/6/22.
//

import SwiftUI

struct CalendarHeaderView: View {
    let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    var font: Font = .body
    var body: some View {
        HStack{
            ForEach(daysOfWeek, id: \.self) {dayOfWeek in
                Text(dayOfWeek)
                    .font(font)
                    .fontWeight(.black)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

struct CalendarHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarHeaderView()
    }
}
