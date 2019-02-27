import Flutter
import UIKit

public class SwiftFlutterYoutubePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    registrar.register(YoutubeFactory(_registrar: registrar),
                       withId: "plugins.hoanglm.com/youtube")
  }
}
