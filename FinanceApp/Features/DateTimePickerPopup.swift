//
//  DateTimePickerPopup.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 11.07.2025.
//

import SwiftUI

enum DatePickerConstants {
    static let popupSize = CGSize(width: 320, height: 520)
}

struct DateTimePickerPopup: View {
    @Binding var date: Date
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Выбор даты и времени")
                    .font(.headline)
                Spacer()
                Button("Готово") {
                    isPresented = false
                }
                .bold()
            }
            .padding()

            Divider()

            // Календарный выбор даты
            DatePicker(
                "",
                selection: $date,
                displayedComponents: [.date]
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .labelsHidden()
            .padding(.horizontal)

            Divider()

            // Колёсный выбор времени
            DatePicker(
                "",
                selection: $date,
                displayedComponents: [.hourAndMinute]
            )
            .datePickerStyle(WheelDatePickerStyle())
            .labelsHidden()
            .frame(maxHeight: 150)
            .clipped()

            Spacer()
        }
        .tint(Color("AccentColor"))
    }
}

struct DateTimePickerPopup_Previews: PreviewProvider {
    @State static var sampleDate = Date()
    @State static var shown = true

    static var previews: some View {
        DateTimePickerPopup(date: $sampleDate, isPresented: $shown)
            .frame(width: 320, height: 400)
            .background(Color(.systemBackground))
    }
}
