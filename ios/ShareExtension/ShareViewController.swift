import UIKit
import MobileCoreServices

final class ShareViewController: UIViewController {
  private let appGroupId = "group.com.talvori.talvori"
  private let pendingTextKey = "pendingSharedText"
  private let pendingIdKey = "pendingSharedTextId"
  private let pendingCreatedAtKey = "pendingSharedTextCreatedAt"
  private let pendingSourceKey = "pendingSharedTextSource"
  private let pendingTypeKey = "pendingSharedTextType"
  private var didStartProcessing = false

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(red: 0.02, green: 0.04, blue: 0.07, alpha: 1)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    guard !didStartProcessing else { return }
    didStartProcessing = true
    processSharedInput()
  }

  private func processSharedInput() {
    loadSharedText { [weak self] text in
      guard let self else { return }
      let trimmed = text?.trimmingCharacters(in: .whitespacesAndNewlines)
      guard let trimmed, !trimmed.isEmpty else {
        self.extensionContext?.cancelRequest(
          withError: NSError(
            domain: "TalvoriShareExtension",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "No text was shared."]
          )
        )
        return
      }

      self.storePendingSharedText(trimmed)
      self.openContainingApp()
      self.extensionContext?.completeRequest(returningItems: nil)
    }
  }

  private func loadSharedText(completion: @escaping (String?) -> Void) {
    let items = extensionContext?.inputItems.compactMap { $0 as? NSExtensionItem } ?? []
    let providers = items.flatMap { $0.attachments ?? [] }
    let plainTextType = kUTTypePlainText as String
    let urlType = kUTTypeURL as String

    for provider in providers {
      if provider.hasItemConformingToTypeIdentifier(plainTextType) {
        provider.loadItem(forTypeIdentifier: plainTextType, options: nil) { item, _ in
          DispatchQueue.main.async {
            if let text = item as? String {
              completion(text)
            } else if let data = item as? Data,
                      let text = String(data: data, encoding: .utf8) {
              completion(text)
            } else {
              completion(nil)
            }
          }
        }
        return
      }
    }

    for provider in providers {
      if provider.hasItemConformingToTypeIdentifier(urlType) {
        provider.loadItem(forTypeIdentifier: urlType, options: nil) { item, _ in
          DispatchQueue.main.async {
            if let url = item as? URL {
              completion(url.absoluteString)
            } else if let text = item as? String {
              completion(text)
            } else {
              completion(nil)
            }
          }
        }
        return
      }
    }

    completion(nil)
  }

  private func storePendingSharedText(_ text: String) {
    guard let defaults = UserDefaults(suiteName: appGroupId) else {
      NSLog("TalvoriShareExtension pending text write skipped reason=no_app_group_defaults")
      return
    }

    let shareId = UUID().uuidString
    defaults.set(text, forKey: pendingTextKey)
    defaults.set(shareId, forKey: pendingIdKey)
    defaults.set(Date().timeIntervalSince1970, forKey: pendingCreatedAtKey)
    defaults.set("ios_share_extension", forKey: pendingSourceKey)
    defaults.set(webUrl(from: text) == nil ? "text" : "url", forKey: pendingTypeKey)
    defaults.synchronize()
    NSLog("TalvoriShareExtension wrote text payload id=%@", shareId)
  }

  private func openContainingApp() {
    guard let url = URL(string: "talvori://share") else { return }
    extensionContext?.open(url, completionHandler: nil)
  }

  private func webUrl(from rawText: String) -> String? {
    let trimmed = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
    guard let url = URL(string: trimmed),
          let scheme = url.scheme?.lowercased(),
          scheme == "http" || scheme == "https" else {
      return nil
    }
    return trimmed
  }
}
