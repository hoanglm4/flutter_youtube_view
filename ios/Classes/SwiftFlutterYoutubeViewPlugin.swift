import Flutter
import UIKit

public class SwiftFlutterYoutubeViewPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    registrar.register(YoutubeFactory(_registrar: registrar),
                       withId: "plugins.hoanglm.com/youtube")
  }
}
