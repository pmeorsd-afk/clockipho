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
        
        _title = State(initialValue: existingAlarm?.title ?? "שחרית שבת")
        _selectedDate = State(initialValue: date)
        _autoSilenceSeconds = State(initialValue: existingAlarm?.autoSilenceSeconds ?? 120) // Default 2 min
        _repeatDays = State(initialValue: existingAlarm?.repeatDays ?? Weekday.shabbatGroup)
        _selectedSoundId = State(initialValue: existingAlarm?.soundId ?? "shofar")
        _fadeInSeconds = State(initialValue: existingAlarm?.fadeInSeconds ?? 10)
        _disableVibration = State(initialValue: existingAlarm?.disableVibration ?? true)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Section 1: Time Picker Card
                        VStack(alignment: .leading, spacing: 10) {
                            Text("שעת השכמה")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                            
                            DatePicker("", selection: $selectedDate, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 8)
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(14)
                        }
                        .padding(.horizontal, 16)
                        
                        // Section 2: Title Card
                        VStack(alignment: .leading, spacing: 8) {
                            Text("כותרת")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                            
                            TextField("שם השעון (לדוגמה: שחרית, קימה)", text: $title)
                                .padding(14)
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 16)
                        
                        // Section 3: Auto-silence Duration Card
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("כיבוי אוטומטי לשבת ולימי חול")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(autoSilenceLabel(autoSilenceSeconds))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                            }
                            .padding(.horizontal, 4)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("הצלצול יכבה מעצמו בדיוק לאחר:")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                
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
                                            .background(autoSilenceSeconds == preset.0 ? Color.blue.opacity(0.15) : Color(.systemGray6))
                                            .cornerRadius(8)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                
                                Text("מותאם לשבת: אין צורך במגע במסך או לחיצה על כפתורים. הצליל יפסק לחלוטין בתום הזמן שנבחר.")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(14)
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(14)
                        }
                        .padding(.horizontal, 16)
                        
                        // Section 4: Days of Week Card
                        VStack(alignment: .leading, spacing: 10) {
                            Text("חזרתיות וימים")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                            
                            VStack(spacing: 12) {
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
                                
                                // Individual Day Toggle Circles
                                HStack(spacing: 8) {
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
                            }
                            .padding(14)
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(14)
                        }
                        .padding(.horizontal, 16)
                        
                        // Section 5: Sound & Volume Card
                        VStack(alignment: .leading, spacing: 10) {
                            Text("שמע והתנהגות")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Text("צליל השכמה")
                                        .font(.subheadline)
                                    Spacer()
                                    Picker("", selection: $selectedSoundId) {
                                        ForEach(AlarmSound.availableSounds) { sound in
                                            Text(sound.nameHe).tag(sound.id)
                                        }
                                    }
                                    .labelsHidden()
                                }
                                
                                Divider()
                                
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
                                
                                Divider()
                                
                                Toggle("ביטול רטט (מומלץ לשבת)", isOn: $disableVibration)
                            }
                            .padding(14)
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(14)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                    .padding(.top, 10)
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
        }
    }
    
    private func autoSilenceLabel(_ sec: Int) -> String {
        if sec < 60 { return "\(sec) שניות" }
        let mins = sec / 60
        return mins == 1 ? "דקה אחת" : (mins == 2 ? "2 דקות" : "\(mins) דקות")
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
