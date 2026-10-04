import Foundation
import UIKit
import UserNotifications

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    var onOpen: ((String) -> Void)?

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let blockID = response.notification.request.identifier
        onOpen?(blockID)
        completionHandler()
    }
}

enum NotificationService {
    static let delegate = NotificationDelegate()

    static func setDelegate(_ onOpen: @escaping (String) -> Void) {
        delegate.onOpen = onOpen
        UNUserNotificationCenter.current().delegate = delegate
    }

    static var authorizationStatus: UNAuthorizationStatus {
        var status: UNAuthorizationStatus = .notDetermined
        let semaphore = DispatchSemaphore(value: 0)
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            status = settings.authorizationStatus
            semaphore.signal()
        }
        semaphore.wait()
        return status
    }

    static func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func scheduleNudge(blockID: String, title: String, body: String, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = ["blockID": blockID]

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: blockID,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    static func cancelNudge(blockID: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [blockID])
    }

    static func removeAllPendingNudges() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}