import Foundation
import Combine

class AlarmStore: ObservableObject {
    @Published var alarms: [AlarmItem] = [] {
        didSet {
            saveAlarms()
        }
    }
    
    private let storageKey = "ShabbatAlarmApp_StoredAlarms_v1"
    
    init() {
        loadAlarms()
    }
    
    func addAlarm(_ alarm: AlarmItem) {
        alarms.append(alarm)
        sortAlarms()
    }
    
    func updateAlarm(_ alarm: AlarmItem) {
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            alarms[index] = alarm
            sortAlarms()
        }
    }
    
    func deleteAlarm(at offsets: IndexSet) {
        alarms.remove(atOffsets: offsets)
    }
    
    func deleteAlarm(id: UUID) {
        alarms.removeAll { $0.id == id }
    }
    
    func toggleAlarm(id: UUID) {
        if let index = alarms.firstIndex(where: { $0.id == id }) {
            alarms[index].isEnabled.toggle()
        }
    }
    
    private func sortAlarms() {
        alarms.sort { ($0.hour * 60 + $0.minute) < ($1.hour * 60 + $1.minute) }
    }
    
    private func saveAlarms() {
        do {
            let data = try JSONEncoder().encode(alarms)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save alarms: \(error.localizedDescription)")
        }
    }
    
    private func loadAlarms() {
        if let data = UserDefaults.standard.data(forKey: storageKey) {
            do {
                let decoded = try JSONDecoder().decode([AlarmItem].self, from: data)
                self.alarms = decoded
                return
            } catch {
                print("Failed to decode saved alarms: \(error.localizedDescription)")
            }
        }
        
        // Defaults if first time opening the app:
        self.alarms = [
            AlarmItem(
                title: "שחרית שבת (כיבוי 2 דקות)",
                hour: 7,
                minute: 30,
                isEnabled: true,
                autoSilenceSeconds: 120, // 2 minutes auto silence
                repeatDays: Weekday.shabbatGroup,
                soundId: "shofar",
                fadeInSeconds: 15,
                disableVibration: true
            ),
            AlarmItem(
                title: "השכמה יומית (כיבוי 2 דקות)",
                hour: 6,
                minute: 45,
                isEnabled: true,
                autoSilenceSeconds: 120, // 2 minutes auto silence
                repeatDays: Weekday.weekdaysGroup,
                soundId: "gentle_morning",
                fadeInSeconds: 10,
                disableVibration: false
            )
        ]
        saveAlarms()
    }
}
