#import "DynamicPhotoCropperPlugin.h"
#if __has_include(<dynamic_photo_cropper/dynamic_photo_cropper-Swift.h>)
#import <dynamic_photo_cropper/dynamic_photo_cropper-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "dynamic_photo_cropper-Swift.h"
#endif

@implementation DynamicPhotoCropperPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDynamicPhotoCropperPlugin registerWithRegistrar:registrar];
}
@end
