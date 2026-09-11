import Foundation
import UserNotifications
import Combine

class AlarmScheduler: ObservableObject {
    static let shared = AlarmScheduler()
    
    @Published var nextAlarmInfo: (alarm: AlarmItem, date: Date)? = nil
    
    private var checkTimer: Timer?
    private var lastTriggeredKey: String = ""
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        requestNotificationPermissions()
        startMonitoring()
    }
    
    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permissions granted.")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Monitoring Loop
    func startMonitoring() {
        checkTimer?.invalidate()
        // Check every second for exact second-level precision
        checkTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkCurrentTimeAgainstAlarms()
        }
    }
    
    func updateNextAlarm(from alarms: [AlarmItem]) {
        let now = Date()
        var closest: (AlarmItem, Date)? = nil
        
        for alarm in alarms where alarm.isEnabled {
            if let triggerDate = alarm.nextTriggerDate(from: now) {
                if closest == nil || triggerDate < closest!.1 {
                    closest = (alarm, triggerDate)
                }
            }
        }
        
        DispatchQueue.main.async {
            self.nextAlarmInfo = closest
        }
        
        scheduleSystemNotifications(for: alarms)
    }
    
    private func checkCurrentTimeAgainstAlarms() {
        guard !SoundPlayerService.shared.isRinging else { return }
        
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentSecond = calendar.component(.second, from: now)
        let currentWeekday = calendar.component(.weekday, from: now)
        
        // Trigger at 00 seconds of the target minute
        guard currentSecond == 0 else { return }
        
        // Prevent duplicate trigger in the same minute
        let triggerKey = "\(currentHour):\(currentMinute):\(calendar.component(.day, from: now))"
        guard triggerKey != lastTriggeredKey else { return }
        
        guard let alarms = getStoredAlarms() else { return }
        
        for alarm in alarms where alarm.isEnabled {
            if alarm.hour == currentHour && alarm.minute == currentMinute {
                let matchesDay: Bool
                if alarm.repeatDays.isEmpty {
                    // One-time alarm
                    matchesDay = true
                } else {
                    matchesDay = alarm.repeatDays.contains(where: { $0.rawValue == currentWeekday })
                }
                
                if matchesDay {
                    lastTriggeredKey = triggerKey
                    DispatchQueue.main.async {
                        SoundPlayerService.shared.startRinging(for: alarm)
                    }
                    break
                }
            }
        }
    }
    
    private func getStoredAlarms() -> [AlarmItem]? {
        let storageKey = "ShabbatAlarmApp_StoredAlarms_v1"
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let alarms = try? JSONDecoder().decode([AlarmItem].self, from: data) else {
            return nil
        }
        return alarms
    }
    
    // MARK: - Schedule System Notifications as Fallback
    private func scheduleSystemNotifications(for alarms: [AlarmItem]) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        for alarm in alarms where alarm.isEnabled {
            let content = UNMutableNotificationContent()
            content.title = "⏰ " + alarm.title
            content.body = "השעון יכבה אוטומטית בעוד \(alarm.formattedSilenceDuration). שבת שלום ומבורך!"
            content.sound = UNNotificationSound.default
            
            if alarm.repeatDays.isEmpty {
                var components = DateComponents()
                components.hour = alarm.hour
                components.minute = alarm.minute
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                let request = UNNotificationRequest(identifier: alarm.id.uuidString, content: content, trigger: trigger)
                center.add(request)
            } else {
                for day in alarm.repeatDays {
                    var components = DateComponents()
                    components.hour = alarm.hour
                    components.minute = alarm.minute
                    components.weekday = day.rawValue
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                    let reqId = "\(alarm.id.uuidString)_\(day.rawValue)"
                    let request = UNNotificationRequest(identifier: reqId, content: content, trigger: trigger)
                    center.add(request)
                }
            }
        }
    }
}
