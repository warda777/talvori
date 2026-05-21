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
      if let text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        self.storePendingSharedText(text, type: self.sharedType(for: text))
        self.openContainingApp()
        self.extensionContext?.completeRequest(returningItems: nil)
      } else {
        self.extensionContext?.cancelRequest(
          withError: NSError(
            domain: "TalvoriShareExtension",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "No text was shared."]
          )
        )
      }
    }
  }

  private func loadSharedText(completion: @escaping (String?) -> Void) {
    let items = extensionContext?.inputItems.compactMap { $0 as? NSExtensionItem } ?? []
    let providers = items.flatMap { $0.attachments ?? [] }
    loadText(from: providers[...], completion: completion)
  }

  private func loadText(
    from providers: ArraySlice<NSItemProvider>,
    completion: @escaping (String?) -> Void
  ) {
    guard let provider = providers.first else {
      completion(nil)
      return
    }

    let plainTextType = kUTTypePlainText as String
    let urlType = kUTTypeURL as String

    if provider.hasItemConformingToTypeIdentifier(plainTextType) {
      provider.loadItem(forTypeIdentifier: plainTextType, options: nil) { item, _ in
        DispatchQueue.main.async {
          if let text = item as? String {
            completion(text)
          } else if let data = item as? Data, let text = String(data: data, encoding: .utf8) {
            completion(text)
          } else {
            self.loadText(from: providers.dropFirst(), completion: completion)
          }
        }
      }
      return
    }

    if provider.hasItemConformingToTypeIdentifier(urlType) {
      provider.loadItem(forTypeIdentifier: urlType, options: nil) { item, _ in
        DispatchQueue.main.async {
          if let url = item as? URL {
            completion(url.absoluteString)
          } else if let text = item as? String {
            completion(text)
          } else {
            self.loadText(from: providers.dropFirst(), completion: completion)
          }
        }
      }
      return
    }

    loadText(from: providers.dropFirst(), completion: completion)
  }

  private func sharedType(for rawText: String) -> String {
    if let url = URL(string: rawText.trimmingCharacters(in: .whitespacesAndNewlines)),
       url.scheme != nil {
      return "url"
    }
    return "text"
  }

  private func storePendingSharedText(_ rawText: String, type: String) {
    let text = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !text.isEmpty else { return }

    let shareId = UUID().uuidString
    let defaults = UserDefaults(suiteName: appGroupId)
    defaults?.set(text, forKey: pendingTextKey)
    defaults?.set(shareId, forKey: pendingIdKey)
    defaults?.set(Date().timeIntervalSince1970, forKey: pendingCreatedAtKey)
    defaults?.set("ios_share_extension", forKey: pendingSourceKey)
    defaults?.set(type, forKey: pendingTypeKey)
    defaults?.synchronize()
    NSLog("TalvoriShareExtension wrote payload id=%@", shareId)
  }

  private func openContainingApp() {
    guard let url = URL(string: "talvori://share") else { return }
    extensionContext?.open(url, completionHandler: nil)
  }
}
