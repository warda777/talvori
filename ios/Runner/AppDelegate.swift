import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let shareMethodChannel = "talvori/share"
  private let appGroupId = "group.com.talvori.talvori"
  private let pendingTextKey = "pendingSharedText"
  private let pendingIdKey = "pendingSharedTextId"
  private let pendingCreatedAtKey = "pendingSharedTextCreatedAt"
  private let pendingSourceKey = "pendingSharedTextSource"
  private let pendingTypeKey = "pendingSharedTextType"
  private var shareChannelsConfigured = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    let didFinish = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    if let controller = window?.rootViewController as? FlutterViewController {
      configureShareChannels(binaryMessenger: controller.binaryMessenger)
    }
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

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    configureShareChannels(binaryMessenger: engineBridge.applicationRegistrar.messenger())
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
          result(self.consumePendingSharedPayload())
        default:
          result(FlutterMethodNotImplemented)
        }
      }
  }

  private func consumePendingSharedPayload() -> [String: Any]? {
    guard let defaults = UserDefaults(suiteName: appGroupId) else {
      NSLog("Talvori share runner pending payload found=false reason=no_app_group_defaults")
      return nil
    }
    let rawText = defaults.string(forKey: pendingTextKey)
    let text = rawText?.trimmingCharacters(in: .whitespacesAndNewlines)
    guard let text, !text.isEmpty else {
      NSLog("Talvori share runner pending payload found=false reason=no_text")
      return nil
    }

    let id = defaults.string(forKey: pendingIdKey) ?? UUID().uuidString
    let createdAt = defaults.object(forKey: pendingCreatedAtKey) as? Double
      ?? Date().timeIntervalSince1970
    let source = defaults.string(forKey: pendingSourceKey) ?? "ios_share_extension"
    let type = defaults.string(forKey: pendingTypeKey) ?? "text"
    clearPendingSharedPayload(defaults)
    NSLog(
      "Talvori share runner pending text payload found=true shareId=%@",
      id
    )

    return [
      "id": id,
      "text": text,
      "createdAt": createdAt,
      "source": source,
      "type": type,
    ]
  }

  private func clearPendingSharedPayload(_ defaults: UserDefaults) {
    defaults.removeObject(forKey: pendingTextKey)
    defaults.removeObject(forKey: pendingIdKey)
    defaults.removeObject(forKey: pendingCreatedAtKey)
    defaults.removeObject(forKey: pendingSourceKey)
    defaults.removeObject(forKey: pendingTypeKey)
    defaults.synchronize()
  }
}
