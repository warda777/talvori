import UIKit
import MobileCoreServices

final class ShareViewController: UIViewController {
  private let appGroupId = "group.eu.talvori.app"
  private let pendingTextKey = "pendingSharedText"
  private let pendingIdKey = "pendingSharedTextId"
  private let pendingCreatedAtKey = "pendingSharedTextCreatedAt"
  private let pendingSourceKey = "pendingSharedTextSource"
  private let pendingTypeKey = "pendingSharedTextType"
  private let pendingSourceUrlKey = "pendingSharedTextSourceUrl"
  private let pendingPayloadsKey = "pendingSharedPayloads"
  private let successDisplayDuration: TimeInterval = 2.8
  private var didStartProcessing = false
  private let statusLabel = UILabel()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(red: 0.02, green: 0.04, blue: 0.07, alpha: 1)
    statusLabel.translatesAutoresizingMaskIntoConstraints = false
    statusLabel.text = "Wort wird gespeichert …"
    statusLabel.textColor = .white
    statusLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
    statusLabel.textAlignment = .center
    view.addSubview(statusLabel)
    NSLayoutConstraint.activate([
      statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
      statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
      statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
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
      self.finishWithSuccess()
    }
  }

  private func finishWithSuccess() {
    statusLabel.text = "Gespeichert in Meine Wörter"
    DispatchQueue.main.asyncAfter(deadline: .now() + successDisplayDuration) { [weak self] in
      self?.extensionContext?.completeRequest(returningItems: nil)
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
    let createdAt = Date().timeIntervalSince1970
    let type = webUrl(from: text) == nil ? "text" : "url"
    var payload: [String: Any] = [
      "id": shareId,
      "text": text,
      "createdAt": createdAt,
      "source": "ios_share_extension",
      "type": type,
      "platform": "ios",
      "sharedTextPreview": String(text.prefix(120))
    ]
    if let sourceUrl, !sourceUrl.isEmpty {
      payload["sourceUrl"] = sourceUrl
    }
    var pendingPayloads = defaults.array(forKey: pendingPayloadsKey) as? [[String: Any]] ?? []
    pendingPayloads.append(payload)
    defaults.set(pendingPayloads, forKey: pendingPayloadsKey)

    // Keep the legacy single-payload keys for older app builds. The current
    // Flutter side consumes the queue above and can import several shares later.
    defaults.set(text, forKey: pendingTextKey)
    defaults.set(shareId, forKey: pendingIdKey)
    defaults.set(createdAt, forKey: pendingCreatedAtKey)
    defaults.set("ios_share_extension", forKey: pendingSourceKey)
    defaults.set(type, forKey: pendingTypeKey)
    if let sourceUrl, !sourceUrl.isEmpty {
      defaults.set(sourceUrl, forKey: pendingSourceUrlKey)
    } else {
      defaults.removeObject(forKey: pendingSourceUrlKey)
    }

    defaults.synchronize()
    NSLog(
      "TalvoriShareExtension queued text payload id=%@ count=%d hasSourceUrl=%@",
      shareId,
      pendingPayloads.count,
      sourceUrl == nil ? "false" : "true"
    )
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
