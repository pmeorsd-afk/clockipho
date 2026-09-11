import SwiftUI
import AVFoundation

@main
struct ShabbatAlarmApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            AlarmListView()
                .preferredColorScheme(.dark)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        // Setup audio session for background playback and silent-switch bypass
        SoundPlayerService.shared.configureAudioSession()
        
        // Setup User Notification Center Delegate
        UNUserNotificationCenter.current().delegate = self
        AlarmScheduler.shared.requestNotificationPermissions()
        
        return true
    }
    
    // Present notification banner even when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}
