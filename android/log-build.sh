PACKAGE="com.synergyboat.flashcardAi"
LAUNCHER=".MainActivity"

/usr/bin/time -l bash -lc '
  ./gradlew assembleDebug --no-daemon &&
  adb install -r app/build/outputs/apk/debug/app-debug.apk &&
  adb shell am start -n "'"$PACKAGE/$LAUNCHER"'"
'
