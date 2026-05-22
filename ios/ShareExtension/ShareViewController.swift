import UIKit
import MobileCoreServices

final class ShareViewController: UIViewController {
  private let appGroupId = "group.com.talvori.talvori"
  private let pendingTextKey = "pendingSharedText"
  private let pendingIdKey = "pendingSharedTextId"
  private let pendingCreatedAtKey = "pendingSharedTextCreatedAt"
  private let pendingSourceKey = "pendingSharedTextSource"
  private let pendingTypeKey = "pendingSharedTextType"
  private let pendingSourceUrlKey = "pendingSharedTextSourceUrl"
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
    loadSharedInput { [weak self] input in
      guard let self else { return }
      let trimmed = input.text?.trimmingCharacters(in: .whitespacesAndNewlines)
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

      self.storePendingSharedText(trimmed, sourceUrl: input.sourceUrl)
      self.openContainingApp()
      self.extensionContext?.completeRequest(returningItems: nil)
    }
  }

  private func loadSharedInput(completion: @escaping (SharedInput) -> Void) {
    let items = extensionContext?.inputItems.compactMap { $0 as? NSExtensionItem } ?? []
    let providers = items.flatMap { $0.attachments ?? [] }
    let plainTextType = kUTTypePlainText as String
    let urlType = kUTTypeURL as String
    let group = DispatchGroup()
    var foundText: String?
    var foundUrl: String?

    for provider in providers {
      if provider.hasItemConformingToTypeIdentifier(plainTextType) {
        group.enter()
        provider.loadItem(forTypeIdentifier: plainTextType, options: nil) { item, _ in
          DispatchQueue.main.async {
            if let text = item as? String {
              foundText = foundText ?? text
            } else if let data = item as? Data,
                      let text = String(data: data, encoding: .utf8) {
              foundText = foundText ?? text
            } else {
              foundText = foundText
            }
            group.leave()
          }
        }
      }
    }

    for provider in providers {
      if provider.hasItemConformingToTypeIdentifier(urlType) {
        group.enter()
        provider.loadItem(forTypeIdentifier: urlType, options: nil) { item, _ in
          DispatchQueue.main.async {
            if let url = item as? URL {
              foundUrl = foundUrl ?? self.webUrl(from: url.absoluteString)
              foundText = foundText ?? url.absoluteString
            } else if let text = item as? String {
              foundUrl = foundUrl ?? self.webUrl(from: text)
              foundText = foundText ?? text
            } else {
              foundUrl = foundUrl
            }
            group.leave()
          }
        }
      }
    }

    group.notify(queue: .main) {
      let textUrl = foundText.flatMap { self.webUrl(from: $0) }
      completion(
        SharedInput(
          text: foundText,
          sourceUrl: foundUrl ?? textUrl
        )
      )
    }
  }

  private func storePendingSharedText(_ text: String, sourceUrl: String?) {
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
    if let sourceUrl, !sourceUrl.isEmpty {
      defaults.set(sourceUrl, forKey: pendingSourceUrlKey)
    } else {
      defaults.removeObject(forKey: pendingSourceUrlKey)
    }
    defaults.synchronize()
    NSLog(
      "TalvoriShareExtension wrote text payload id=%@ hasSourceUrl=%@",
      shareId,
      sourceUrl == nil ? "false" : "true"
    )
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

private struct SharedInput {
  let text: String?
  let sourceUrl: String?
}
