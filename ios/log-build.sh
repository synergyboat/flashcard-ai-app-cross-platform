
UDID="00008140-001C4C56149B001C"
BUNDLE="com.flashcardai.app"
DERIVED="build/FlashcardAI-Derived"
APP="$DERIVED/Build/Products/Debug-iphoneos/FlashcardAI.app"

xcodebuild \
  -workspace FlashcardAI.xcworkspace \
  -scheme FlashcardAI \
  -configuration Debug \
  -destination "generic/platform=iOS" \
  -derivedDataPath "$DERIVED" \
  build &&

xcrun devicectl device install app --device "$UDID" "$APP" &&
xcrun devicectl device process launch --device "$UDID" "$BUNDLE"

