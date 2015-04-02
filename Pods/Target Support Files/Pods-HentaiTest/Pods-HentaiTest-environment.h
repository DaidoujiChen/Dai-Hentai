
// To check if a library is compiled with CocoaPods you
// can use the `COCOAPODS` macro definition which is
// defined in the xcconfigs so it is available in
// headers also when they are imported in the client
// project.


// Debug build configuration
#ifdef DEBUG

  // KIF
  #define COCOAPODS_POD_AVAILABLE_KIF
  #define COCOAPODS_VERSION_MAJOR_KIF 3
  #define COCOAPODS_VERSION_MINOR_KIF 2
  #define COCOAPODS_VERSION_PATCH_KIF 1

  // KIF/XCTest
  #define COCOAPODS_POD_AVAILABLE_KIF_XCTest
  #define COCOAPODS_VERSION_MAJOR_KIF_XCTest 3
  #define COCOAPODS_VERSION_MINOR_KIF_XCTest 2
  #define COCOAPODS_VERSION_PATCH_KIF_XCTest 1

#endif
