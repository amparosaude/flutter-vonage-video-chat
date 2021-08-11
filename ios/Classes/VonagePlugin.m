#import "VonagePlugin.h"
#if __has_include(<vonage/vonage-Swift.h>)
#import <vonage/vonage-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "vonage-Swift.h"
#endif

@implementation VonagePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftVonagePlugin registerWithRegistrar:registrar];
}
@end
