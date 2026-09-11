import SwiftUI

struct ShabbatNightstandView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var soundPlayer = SoundPlayerService.shared
    @ObservedObject var scheduler = AlarmScheduler.shared
    
    @State private var currentTime = Date()
    @State private var brightnessLevel: Double = 0.15 // Default ultra-dim for bedtime
    @State private var showControls: Bool = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // True OLED Black Background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Top header with subtle status
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.right")
                            Text("חזרה לרשימה")
                        }
                        .font(.footnote)
                        .foregroundColor(.gray.opacity(0.6))
                        .padding(8)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("מצב שבת פעיל")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.gray.opacity(0.8))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .opacity(showControls ? 1.0 : 0.25)
                
                Spacer()
                
                // Ringing State Banner (If alarm is actively firing)
                if soundPlayer.isRinging {
                    VStack(spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: "bell.fill")
                                .font(.title)
                                .foregroundColor(.yellow)
                            Text(soundPlayer.activeAlarm?.title ?? "שעון מעורר")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        // Auto-silence countdown badge
                        HStack(spacing: 8) {
                            Image(systemName: "timer")
                                .foregroundColor(.orange)
                            Text("כיבוי אוטומטי בעוד: \(formattedRemainingTime(soundPlayer.remainingSeconds))")
                                .font(.headline)
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.15))
                        .cornerRadius(10)
                        
                        Text("אין צורך לגעת במכשיר כלל • הצליל יפסק מעצמו")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Huge Minimalist OLED Digital Clock
                VStack(spacing: 6) {
                    Text(timeString(from: currentTime))
                        .font(.system(size: 76, weight: .light, design: .monospaced))
                        .foregroundColor(Color.white.opacity(max(0.2, brightnessLevel)))
                    
                    Text(dateString(from: currentTime))
                        .font(.callout)
                        .foregroundColor(Color.gray.opacity(max(0.2, brightnessLevel * 0.8)))
                }
                
                Spacer()
                
                // Next upcoming alarm indicator
                if let next = scheduler.nextAlarmInfo {
                    VStack(spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "alarm")
                                .foregroundColor(.cyan.opacity(0.8))
                            Text("שעון קרוב: \(next.alarm.formattedTime)")
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.8))
                            Text("(\(next.alarm.title))")
                                .foregroundColor(.gray)
                        }
                        .font(.subheadline)
                        
                        Text("יצלצל ויכבה אוטומטית לאחר \(next.alarm.formattedSilenceDuration)")
                            .font(.caption2)
                            .foregroundColor(.gray.opacity(0.7))
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(20)
                } else {
                    Text("אין שעונים פעילים בקרוב")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.4))
                }
                
                // Brightness & Dimmer Control (Shown on tap or faint)
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        Image(systemName: "moon.fill")
                            .foregroundColor(.gray.opacity(0.5))
                            .font(.caption)
                        
                        Slider(value: $brightnessLevel, in: 0.05...1.0)
                            .accentColor(.yellow.opacity(0.7))
                        
                        Image(systemName: "sun.max.fill")
                            .foregroundColor(.gray.opacity(0.5))
                            .font(.caption)
                    }
                    .frame(maxWidth: 240)
                    
                    Text("עמעום מסך לשינה (טאפ בכל מקום להצגת/הסתרת פקדים)")
                        .font(.system(size: 10))
                        .foregroundColor(.gray.opacity(0.4))
                }
                .padding(.bottom, 16)
                .opacity(showControls ? 1.0 : 0.2)
            }
            .padding()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.25)) {
                showControls.toggle()
            }
        }
        .onReceive(timer) { input in
            currentTime = input
        }
        .onAppear {
            // Keep the screen awake all night
            #if canImport(UIKit)
            UIApplication.shared.isIdleTimerDisabled = true
            #endif
        }
        .onDisappear {
            // Restore default screen timeout behavior
            #if canImport(UIKit)
            UIApplication.shared.isIdleTimerDisabled = false
            #endif
        }
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "he_IL")
        formatter.dateFormat = "EEEE, d בMMMM"
        return formatter.string(from: date)
    }
    
    private func formattedRemainingTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
