import SwiftUI

struct AlarmListView: View {
    @StateObject private var store = AlarmStore()
    @ObservedObject private var scheduler = AlarmScheduler.shared
    @ObservedObject private var soundPlayer = SoundPlayerService.shared
    
    @State private var showingAddSheet = false
    @State private var editingAlarm: AlarmItem? = nil
    @State private var showingShabbatMode = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Shabbat Banner / Quick Start
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("שעון מעורר לשבת")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("כיבוי אוטומטי • ללא מגע יד • מותאם לכל השבוע")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            
                            // Nightstand Launcher Button
                            Button(action: {
                                showingShabbatMode = true
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "moon.stars.fill")
                                    Text("מצב שבת")
                                }
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.purple)
                                .cornerRadius(20)
                                .shadow(color: .purple.opacity(0.3), radius: 4, y: 2)
                            }
                        }
                        
                        // Active Alarm Alert Banner (if ringing)
                        if soundPlayer.isRinging {
                            HStack {
                                Image(systemName: "bell.badge.fill")
                                    .foregroundColor(.yellow)
                                Text("מצלצל כעת! יכבה בעוד \(soundPlayer.remainingSeconds) שנ׳")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                Spacer()
                                Button("הפסק (חול)") {
                                    soundPlayer.stopRinging(isUserIntervention: true)
                                }
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white)
                                .foregroundColor(.red)
                                .cornerRadius(6)
                            }
                            .padding(10)
                            .background(Color.orange.opacity(0.85))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    
                    // Alarms List
                    if store.alarms.isEmpty {
                        VStack(spacing: 16) {
                            Spacer()
                            Image(systemName: "alarm")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.4))
                            Text("אין עדיין שעונים מעוררים")
                                .font(.title3)
                                .foregroundColor(.secondary)
                            Button("הוסף שעון ראשון") {
                                showingAddSheet = true
                            }
                            .buttonStyle(.borderedProminent)
                            Spacer()
                        }
                    } else {
                        List {
                            Section {
                                ForEach(store.alarms) { alarm in
                                    AlarmCardRow(
                                        alarm: alarm,
                                        onToggle: {
                                            store.toggleAlarm(id: alarm.id)
                                            scheduler.updateNextAlarm(from: store.alarms)
                                        },
                                        onTap: {
                                            editingAlarm = alarm
                                        }
                                    )
                                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                }
                                .onDelete { offsets in
                                    store.deleteAlarm(at: offsets)
                                    scheduler.updateNextAlarm(from: store.alarms)
                                }
                            } header: {
                                HStack {
                                    Text("השעונים שלך")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text("החלק למחיקה")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            // Quick Action: Test 10-Second Alarm
                            Section {
                                Button(action: {
                                    testQuickAlarm()
                                }) {
                                    HStack {
                                        Image(systemName: "play.circle.fill")
                                            .foregroundColor(.green)
                                        Text("בדיקת צלצול וכיבוי אוטומטי (10 שניות)")
                                            .font(.footnote)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text("ניסיון")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            } footer: {
                                Text("מאפשר לך לוודא שהשמע פועל והכיבוי האוטומטי מתבצע בצורה חלקה.")
                                    .font(.caption2)
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                }
            }
            .navigationTitle("שעון לשבת ולימי חול")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "info.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AlarmEditView(store: store)
            }
            .sheet(item: $editingAlarm) { alarm in
                AlarmEditView(store: store, existingAlarm: alarm)
            }
            .fullScreenCover(isPresented: $showingShabbatMode) {
                ShabbatNightstandView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .environment(\.layoutDirection, .rightToLeft)
            .onAppear {
                scheduler.updateNextAlarm(from: store.alarms)
            }
        }
    }
    
    private func testQuickAlarm() {
        let testAlarm = AlarmItem(
            title: "בדיקת כיבוי אוטומטי",
            hour: 0,
            minute: 0,
            isEnabled: true,
            autoSilenceSeconds: 10,
            repeatDays: [],
            soundId: "gentle_morning",
            fadeInSeconds: 2,
            disableVibration: true
        )
        soundPlayer.startRinging(for: testAlarm)
    }
}

// MARK: - Alarm Card Row
struct AlarmCardRow: View {
    let alarm: AlarmItem
    let onToggle: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(alarm.formattedTime)
                            .font(.system(size: 38, weight: .semibold, design: .rounded))
                            .foregroundColor(alarm.isEnabled ? .primary : .secondary)
                        
                        Text(alarm.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 8) {
                        // Auto-silence badge
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                                .font(.caption2)
                            Text("יכבה אחרי \(alarm.formattedSilenceDuration)")
                                .font(.caption2)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.orange.opacity(0.15))
                        .foregroundColor(.orange)
                        .cornerRadius(6)
                        
                        // Repeat days badge
                        Text(alarm.formattedDays)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(alarm.repeatDays == Weekday.shabbatGroup ? Color.purple.opacity(0.15) : Color.blue.opacity(0.12))
                            .foregroundColor(alarm.repeatDays == Weekday.shabbatGroup ? .purple : .blue)
                            .cornerRadius(6)
                    }
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { alarm.isEnabled },
                    set: { _ in onToggle() }
                ))
                .labelsHidden()
            }
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.04), radius: 3, y: 1)
        }
        .buttonStyle(.plain)
    }
}
