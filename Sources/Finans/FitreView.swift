import SwiftUI

struct FitreView: View {
    @AppStorage("fitrePerPersonTRY") private var perPersonText: String = ""
    @AppStorage("fitreAileUyesi") private var familySize: Int = 1
    @AppStorage("fitreHatirlatmaCuma") private var weeklyReminderOn = false
    @AppStorage("fitreHatirlatmaAyBasi") private var monthlyReminderOn = false

    private var perPerson: Double { Double(perPersonText) ?? 0 }
    private var total: Double { perPerson * Double(familySize) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Fitre & Sadaka")
                    .font(ZumrutFont.display(20))
                    .foregroundColor(ZumrutColors.ink)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                fitreCard
                reminderSection
            }
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(ZumrutColors.paper)
    }

    private var fitreCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Kişi Başı Fitre (₺)").font(ZumrutFont.mono(11)).foregroundColor(.white.opacity(0.85))
                Spacer()
                TextField("0", text: $perPersonText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.white)
                    .frame(width: 80)
            }
            Text("Diyanet'in bu yılki açıkladığı tutarı girin.")
                .font(ZumrutFont.mono(9))
                .foregroundColor(.white.opacity(0.7))

            HStack {
                Text("Aile Üyesi").font(ZumrutFont.body(13)).foregroundColor(.white)
                Spacer()
                Stepper("\(familySize)", value: $familySize, in: 1...20)
                    .fixedSize()
                    .colorScheme(.dark)
            }

            Divider().background(Color.white.opacity(0.3))

            HStack {
                Text("Toplam").font(ZumrutFont.body(14, weight: .semibold)).foregroundColor(.white)
                Spacer()
                Text(String(format: "%.0f ₺", total)).font(ZumrutFont.display(20)).foregroundColor(.white)
            }
        }
        .padding(16)
        .background(ZumrutColors.teal)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
    }

    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("SADAKA HATIRLATICI")
                .font(ZumrutFont.mono(10))
                .foregroundColor(ZumrutColors.muted)
                .padding(.horizontal, 20)
                .padding(.bottom, 6)
                .padding(.top, 6)

            toggleRow(title: "Her Cuma hatırlat", isOn: $weeklyReminderOn) { isOn in
                setWeeklyReminder(isOn)
            }
            toggleRow(title: "Her ayın 1'i hatırlat", isOn: $monthlyReminderOn) { isOn in
                setMonthlyReminder(isOn)
            }
        }
    }

    private func toggleRow(title: String, isOn: Binding<Bool>, onChange: @escaping (Bool) -> Void) -> some View {
        HStack {
            Text(title).font(ZumrutFont.body(13)).foregroundColor(ZumrutColors.ink)
            Spacer()
            Toggle("", isOn: Binding(
                get: { isOn.wrappedValue },
                set: { newValue in
                    isOn.wrappedValue = newValue
                    onChange(newValue)
                }
            ))
            .labelsHidden()
            .tint(ZumrutColors.teal)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) { Rectangle().fill(ZumrutColors.line).frame(height: 1) }
    }

    private func setWeeklyReminder(_ isOn: Bool) {
        if isOn {
            Task {
                let granted = await NotificationService.requestAuthorization()
                if granted {
                    NotificationService.scheduleWeeklyReminder(
                        weekday: 6, hour: 10, identifier: "sadaka-weekly",
                        title: "Zümrüt", body: "Bugün cuma — bir sadaka vermeyi unutma."
                    )
                } else {
                    weeklyReminderOn = false
                }
            }
        } else {
            NotificationService.cancelReminder(identifier: "sadaka-weekly")
        }
    }

    private func setMonthlyReminder(_ isOn: Bool) {
        if isOn {
            Task {
                let granted = await NotificationService.requestAuthorization()
                if granted {
                    NotificationService.scheduleMonthlyReminder(
                        day: 1, hour: 10, identifier: "sadaka-monthly",
                        title: "Zümrüt", body: "Yeni ay başladı — sadaka ve bağışlarını gözden geçir."
                    )
                } else {
                    monthlyReminderOn = false
                }
            }
        } else {
            NotificationService.cancelReminder(identifier: "sadaka-monthly")
        }
    }
}
