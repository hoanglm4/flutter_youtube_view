#import "FlutterYoutubeViewPlugin.h"
#import <flutter_youtube_view/flutter_youtube_view-Swift.h>

@implementation FlutterYoutubeViewPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterYoutubeViewPlugin registerWithRegistrar:registrar];
}
@end
