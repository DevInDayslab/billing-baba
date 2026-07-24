import Cocoa
import FlutterMacOS
import WebKit

enum TransparentWebViewChannel {
  static let channelName = "billing_baba/transparent_webview"

  static func register(with controller: FlutterViewController) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: controller.engine.binaryMessenger
    )

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "makeWebViewsTransparent":
        if let window = NSApp.mainWindow, let contentView = window.contentView {
          applyTransparentBackground(in: contentView)
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private static func applyTransparentBackground(in view: NSView) {
    if let webView = view as? WKWebView {
      webView.setValue(false, forKey: "drawsBackground")
      webView.wantsLayer = true
      webView.layer?.backgroundColor = NSColor.clear.cgColor
    }

    for subview in view.subviews {
      applyTransparentBackground(in: subview)
    }
  }
}
