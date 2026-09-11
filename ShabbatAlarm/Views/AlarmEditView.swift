import SwiftUI

struct AlarmEditView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var store: AlarmStore
    
    var existingAlarm: AlarmItem?
    
    @State private var title: String
    @State private var selectedDate: Date
    @State private var autoSilenceSeconds: Int
    @State private var repeatDays: Set<Weekday>
    @State private var selectedSoundId: String
    @State private var fadeInSeconds: Int
    @State private var disableVibration: Bool
    
    // Auto-silence preset options (30s, 1m, 2m, 3m, 5m, 10m)
    let silencePresets = [
        (30, "30 שנ׳"),
        (60, "1 דקה"),
        (120, "2 דקות (מומלץ)"),
        (180, "3 דקות"),
        (300, "5 דקות"),
        (600, "10 דקות")
    ]
    
    init(store: AlarmStore, existingAlarm: AlarmItem? = nil) {
        self.store = store
        self.existingAlarm = existingAlarm
        
        let initialHour = existingAlarm?.hour ?? 7
        let initialMinute = existingAlarm?.minute ?? 30
        
        var comp = DateComponents()
        comp.hour = initialHour
        comp.minute = initialMinute
        let date = Calendar.current.date(from: comp) ?? Date()
        
        _title = State(initialValue: existingAlarm?.title ?? "השכמה לשבת")
        _selectedDate = State(initialValue: date)
        _autoSilenceSeconds = State(initialValue: existingAlarm?.autoSilenceSeconds ?? 120) // Default 2 min
        _repeatDays = State(initialValue: existingAlarm?.repeatDays ?? Weekday.shabbatGroup)
        _selectedSoundId = State(initialValue: existingAlarm?.soundId ?? "shofar")
        _fadeInSeconds = State(initialValue: existingAlarm?.fadeInSeconds ?? 10)
        _disableVibration = State(initialValue: existingAlarm?.disableVibration ?? true)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Section 1: Time Picker
                Section {
                    DatePicker("", selection: $selectedDate, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .center)
                } header: {
                    Text("שעת השכמה")
                }
                
                // Section 2: Title
                Section {
                    TextField("שם השעון (לדוגמה: שחרית, קימה)", text: $title)
                } header: {
                    Text("כותרת")
                }
                
                // Section 3: Auto-silence Duration
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("הצלצול יכבה מעצמו בדיוק לאחר:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Preset Pills Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(silencePresets, id: \.0) { preset in
                                Button(action: {
                                    autoSilenceSeconds = preset.0
                                }) {
                                    HStack {
                                        Text(preset.1)
                                            .font(.footnote)
                                            .fontWeight(autoSilenceSeconds == preset.0 ? .bold : .regular)
                                        Spacer()
                                        if autoSilenceSeconds == preset.0 {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(autoSilenceSeconds == preset.0 ? Color.blue.opacity(0.12) : Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("כיבוי אוטומטי לשבת ולימי חול")
                } footer: {
                    Text("מותאם לשבת: אין צורך במגע במסך או לחיצה על כפתורים. הצליל יפסק לחלוטין בתום הזמן שנבחר.")
                        .font(.caption)
                }
                
                // Section 4: Days of Week
                Section {
                    // Quick preset buttons
                    HStack(spacing: 8) {
                        Button("שבת בלבד") {
                            repeatDays = Weekday.shabbatGroup
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(repeatDays == Weekday.shabbatGroup ? .purple : .gray.opacity(0.2))
                        
                        Button("ימי חול (א׳-ה׳)") {
                            repeatDays = Weekday.weekdaysGroup
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(repeatDays == Weekday.weekdaysGroup ? .blue : .gray.opacity(0.2))
                        
                        Button("כל יום") {
                            repeatDays = Weekday.everydayGroup
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(repeatDays == Weekday.everydayGroup ? .green : .gray.opacity(0.2))
                    }
                    .padding(.vertical, 4)
                    
                    // Individual Day Toggle Circles
                    HStack {
                        ForEach(Weekday.allCases) { day in
                            let isSelected = repeatDays.contains(day)
                            Button(action: {
                                if isSelected {
                                    repeatDays.remove(day)
                                } else {
                                    repeatDays.insert(day)
                                }
                            }) {
                                Text(day.shortNameHe)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .frame(width: 38, height: 38)
                                    .background(isSelected ? (day == .saturday ? Color.purple : Color.blue) : Color(.systemGray5))
                                    .foregroundColor(isSelected ? .white : .primary)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 4)
                } header: {
                    Text("חזרתיות וימים")
                }
                
                // Section 5: Sound & Volume
                Section {
                    Picker("צליל השכמה", selection: $selectedSoundId) {
                        ForEach(AlarmSound.availableSounds) { sound in
                            Text(sound.nameHe).tag(sound.id)
                        }
                    }
                    
                    Toggle("הגברה הדרגתית (Fade-In)", isOn: Binding(
                        get: { fadeInSeconds > 0 },
                        set: { fadeInSeconds = $0 ? 15 : 0 }
                    ))
                    
                    if fadeInSeconds > 0 {
                        HStack {
                            Text("משך עליית הווליום: \(fadeInSeconds) שניות")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            Spacer()
                            Stepper("", value: $fadeInSeconds, in: 5...30, step: 5)
                                .labelsHidden()
                        }
                    }
                    
                    Toggle("ביטול רטט (מומלץ לשבת)", isOn: $disableVibration)
                } header: {
                    Text("שמע והתנהגות")
                } footer: {
                    Text("ביטול הרטט מונע רעש טלטול על השידה ומותאם לדיני שבת.")
                }
            }
            .navigationTitle(existingAlarm == nil ? "הוספת שעון מעורר" : "עריכת שעון")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("ביטול") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("שמור") {
                        saveAlarm()
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
        }
    }
    
    private func saveAlarm() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: selectedDate)
        let minute = calendar.component(.minute, from: selectedDate)
        
        let newOrUpdated = AlarmItem(
            id: existingAlarm?.id ?? UUID(),
            title: title.isEmpty ? "שעון מעורר" : title,
            hour: hour,
            minute: minute,
            isEnabled: true,
            autoSilenceSeconds: autoSilenceSeconds,
            repeatDays: repeatDays,
            soundId: selectedSoundId,
            fadeInSeconds: fadeInSeconds,
            disableVibration: disableVibration
        )
        
        if existingAlarm != nil {
            store.updateAlarm(newOrUpdated)
        } else {
            store.addAlarm(newOrUpdated)
        }
        
        AlarmScheduler.shared.updateNextAlarm(from: store.alarms)
    }
}
