#import "FlutterYoutubePlugin.h"
#import <flutter_youtube/flutter_youtube-Swift.h>

@implementation FlutterYoutubePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterYoutubePlugin registerWithRegistrar:registrar];
}
@end
