import Foundation

// MARK: - Weekday Enum
enum Weekday: Int, Codable, CaseIterable, Identifiable, Comparable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    var id: Int { rawValue }
    
    var shortNameHe: String {
        switch self {
        case .sunday: return "א׳"
        case .monday: return "ב׳"
        case .tuesday: return "ג׳"
        case .wednesday: return "ד׳"
        case .thursday: return "ה׳"
        case .friday: return "ו׳"
        case .saturday: return "שבת"
        }
    }
    
    var fullNameHe: String {
        switch self {
        case .sunday: return "יום ראשון"
        case .monday: return "יום שני"
        case .tuesday: return "יום שלישי"
        case .wednesday: return "יום רביעי"
        case .thursday: return "יום חמישי"
        case .friday: return "יום שישי"
        case .saturday: return "שבת קודש"
        }
    }
    
    static func < (lhs: Weekday, rhs: Weekday) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    static var weekdaysGroup: Set<Weekday> {
        [.sunday, .monday, .tuesday, .wednesday, .thursday]
    }
    
    static var shabbatGroup: Set<Weekday> {
        [.saturday]
    }
    
    static var weekendGroup: Set<Weekday> {
        [.friday, .saturday]
    }
    
    static var everydayGroup: Set<Weekday> {
        Set(Weekday.allCases)
    }
}

// MARK: - Alarm Sound Option
struct AlarmSound: Identifiable, Hashable, Codable {
    let id: String
    let nameHe: String
    let fileName: String
    let isSynthFallback: Bool
    
    static let availableSounds: [AlarmSound] = [
        AlarmSound(id: "shofar", nameHe: "קול שופר (תקיעה)", fileName: "shofar.mp3", isSynthFallback: true),
        AlarmSound(id: "gentle_morning", nameHe: "בוקר רגוע (פסנתר)", fileName: "gentle_morning.mp3", isSynthFallback: true),
        AlarmSound(id: "chimes", nameHe: "פעמוני שחרית", fileName: "chimes.mp3", isSynthFallback: true),
        AlarmSound(id: "birds", nameHe: "ציוץ ציפורים וטבע", fileName: "birds.mp3", isSynthFallback: true),
        AlarmSound(id: "classic_alarm", nameHe: "שעון מעורר קלאסי", fileName: "classic_alarm.mp3", isSynthFallback: true),
        AlarmSound(id: "loud_buzzer", nameHe: "צפירה חזקה", fileName: "loud_buzzer.mp3", isSynthFallback: true)
    ]
}

// MARK: - Alarm Item Model
struct AlarmItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var hour: Int       // 0 - 23
    var minute: Int     // 0 - 59
    var isEnabled: Bool = true
    
    // Auto silence duration in seconds (e.g., 120 = 2 minutes)
    var autoSilenceSeconds: Int = 120
    
    // Days to repeat
    var repeatDays: Set<Weekday> = []
    
    // Sound configuration
    var soundId: String = "gentle_morning"
    
    // Fade in duration in seconds (0 = immediate full volume)
    var fadeInSeconds: Int = 10
    
    // Zero vibration for Shabbat compliance
    var disableVibration: Bool = true
    
    // Time formatting helper
    var formattedTime: String {
        String(format: "%02d:%02d", hour, minute)
    }
    
    // Auto-silence display string
    var formattedSilenceDuration: String {
        if autoSilenceSeconds < 60 {
            return "\(autoSilenceSeconds) שניות"
        } else {
            let mins = autoSilenceSeconds / 60
            let remainder = autoSilenceSeconds % 60
            if remainder == 0 {
                return mins == 1 ? "דקה אחת" : (mins == 2 ? "2 דקות" : "\(mins) דקות")
            } else {
                return "\(mins) דק׳ ו-\(remainder) שנ׳"
            }
        }
    }
    
    // Days display string
    var formattedDays: String {
        if repeatDays.isEmpty {
            return "פעם אחת"
        }
        if repeatDays == Weekday.everydayGroup {
            return "כל יום"
        }
        if repeatDays == Weekday.weekdaysGroup {
            return "ימי חול (א׳-ה׳)"
        }
        if repeatDays == Weekday.shabbatGroup {
            return "שבת בלבד"
        }
        if repeatDays == Weekday.weekendGroup {
            return "סופ״ש (שישי-שבת)"
        }
        
        return repeatDays.sorted().map { $0.shortNameHe }.joined(separator: ", ")
    }
    
    // Calculates the next trigger Date from a given anchor Date
    func nextTriggerDate(from now: Date = Date()) -> Date? {
        let calendar = Calendar.current
        
        if repeatDays.isEmpty {
            // One-time alarm
            var components = calendar.dateComponents([.year, .month, .day], from: now)
            components.hour = hour
            components.minute = minute
            components.second = 0
            
            guard let scheduledDate = calendar.date(from: components) else { return nil }
            if scheduledDate > now {
                return scheduledDate
            } else {
                // If the time already passed today, schedule for tomorrow
                return calendar.date(byAdding: .day, value: 1, to: scheduledDate)
            }
        } else {
            // Repeating alarm on specific days of the week
            var candidateDates: [Date] = []
            
            for weekday in repeatDays {
                var components = DateComponents()
                components.hour = hour
                components.minute = minute
                components.second = 0
                components.weekday = weekday.rawValue
                
                if let nextDate = calendar.nextDate(after: now, matching: components, matchingPolicy: .nextTime) {
                    candidateDates.append(nextDate)
                }
            }
            
            return candidateDates.min()
        }
    }
}
