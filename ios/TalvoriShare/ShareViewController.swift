import UIKit
import Social
import UniformTypeIdentifiers

final class ShareViewController: SLComposeServiceViewController {

  override func isContentValid() -> Bool { true }

  override func didSelectPost() {
    var picked: String?

    if let items = extensionContext?.inputItems as? [NSExtensionItem] {
      for item in items {
        for provider in item.attachments ?? [] {
          if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { obj, _ in
              if let s = obj as? String { picked = s }
            }
          } else if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { obj, _ in
              if let u = obj as? URL { picked = u.absoluteString }
            }
          }
        }
      }
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
      let text = (picked ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
      let short = String(text.prefix(200))
      if let enc = short.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
         let url = URL(string: "talvori://share?text=\(enc)") {
        self.extensionContext?.open(url, completionHandler: nil)
      }
      self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
  }

  override func configurationItems() -> [Any]! { [] }
}
