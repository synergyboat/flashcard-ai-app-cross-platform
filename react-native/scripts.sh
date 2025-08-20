# Run the app on a specific device
npx react-native run-ios --mode Release --device 00008140-001C4C56149B001C

# Monitor device logs
idevicesyslog -u 00008140-001C4C56149B001C -m Benchmark

# List all connected devices
xcrun xctrace list devices

# Set Java 17 home
export JAVA_HOME=$(/usr/libexec/java_home -v 17)

