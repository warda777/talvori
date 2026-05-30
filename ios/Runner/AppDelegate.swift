import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let shareMethodChannel = "talvori/share"
  private let appGroupId = "group.eu.talvori.app"
  private let pendingTextKey = "pendingSharedText"
  private let pendingIdKey = "pendingSharedTextId"
  private let pendingCreatedAtKey = "pendingSharedTextCreatedAt"
  private let pendingSourceKey = "pendingSharedTextSource"
  private let pendingTypeKey = "pendingSharedTextType"
  private let pendingSourceUrlKey = "pendingSharedTextSourceUrl"
  private let pendingPayloadsKey = "pendingSharedPayloads"
  private var shareChannelsConfigured = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    GeneratedPluginRegistrant.register(with: self)
    if let shareRegistrar = registrar(forPlugin: "TalvoriShareChannel") {
      configureShareChannels(binaryMessenger: shareRegistrar.messenger())
    }
    let didFinish = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    return didFinish
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if url.scheme == "talvori", url.host == "share" {
      NSLog("Talvori share AppDelegate openURL %@", url.absoluteString)
      return true
    }
    return super.application(app, open: url, options: options)
  }

  private func configureShareChannels(binaryMessenger messenger: FlutterBinaryMessenger) {
    guard !shareChannelsConfigured else { return }
    shareChannelsConfigured = true
    FlutterMethodChannel(name: shareMethodChannel, binaryMessenger: messenger)
      .setMethodCallHandler { [weak self] call, result in
        guard let self else {
          result(nil)
          return
        }
        switch call.method {
        case "getInitialSharedText":
          result(self.consumePendingSharedPayloads())
        default:
          result(FlutterMethodNotImplemented)
        }
      }
  }

  private func consumePendingSharedPayloads() -> [[String: Any]] {
    guard let defaults = UserDefaults(suiteName: appGroupId) else {
      NSLog("Talvori share runner pending payload found=false reason=no_app_group_defaults")
      return []
    }

    if let queuedPayloads = defaults.array(forKey: pendingPayloadsKey) as? [[String: Any]],
       !queuedPayloads.isEmpty {
      clearPendingSharedPayload(defaults)
      NSLog(
        "Talvori share runner pending queue found=true count=%d",
        queuedPayloads.count
      )
      return queuedPayloads
    }

    let rawText = defaults.string(forKey: pendingTextKey)
    let text = rawText?.trimmingCharacters(in: .whitespacesAndNewlines)
    guard let text, !text.isEmpty else {
      NSLog("Talvori share runner pending payload found=false reason=no_text")
      return []
    }

    let id = defaults.string(forKey: pendingIdKey) ?? UUID().uuidString
    let createdAt = defaults.object(forKey: pendingCreatedAtKey) as? Double
      ?? Date().timeIntervalSince1970
    let source = defaults.string(forKey: pendingSourceKey) ?? "ios_share_extension"
    let type = defaults.string(forKey: pendingTypeKey) ?? "text"
    let rawSourceUrl = defaults.string(forKey: pendingSourceUrlKey)
    let sourceUrl = rawSourceUrl?.trimmingCharacters(in: .whitespacesAndNewlines)
    clearPendingSharedPayload(defaults)
    NSLog(
      "Talvori share runner pending text payload found=true shareId=%@ hasSourceUrl=%@",
      id,
      sourceUrl == nil || sourceUrl!.isEmpty ? "false" : "true"
    )

    var payload: [String: Any] = [
      "id": id,
      "text": text,
      "createdAt": createdAt,
      "source": source,
      "type": type,
    ]
    if let sourceUrl, !sourceUrl.isEmpty {
      payload["sourceUrl"] = sourceUrl
    }
    return [payload]
  }

  private func clearPendingSharedPayload(_ defaults: UserDefaults) {
    defaults.removeObject(forKey: pendingTextKey)
    defaults.removeObject(forKey: pendingIdKey)
    defaults.removeObject(forKey: pendingCreatedAtKey)
    defaults.removeObject(forKey: pendingSourceKey)
    defaults.removeObject(forKey: pendingTypeKey)
    defaults.removeObject(forKey: pendingSourceUrlKey)
    defaults.removeObject(forKey: pendingPayloadsKey)
    defaults.synchronize()
  }
}
