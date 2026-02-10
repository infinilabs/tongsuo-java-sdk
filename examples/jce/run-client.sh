#!/bin/bash
#
# Convenience script to run TLS13Client with proper JVM parameters
#

set -e

# Parse options
FORCE_COMPILE=0
while [[ $# -gt 0 ]]; do
  case $1 in
    --force-compile|-f)
      FORCE_COMPILE=1
      shift
      ;;
    *)
      break
      ;;
  esac
done

# Detect Java version
JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)

# Check if JAR path is provided
if [ -z "$1" ]; then
  echo "Usage: $0 [--force-compile] <path-to-tongsuo-openjdk.jar>"
  echo ""
  echo "Options:"
  echo "  --force-compile, -f    Force recompilation even if .class file exists"
  echo ""
  echo "Examples:"
  echo "  $0 tongsuo-openjdk-1.1.0-uber.jar"
  echo "  $0 --force-compile tongsuo-openjdk-1.1.0-uber.jar"
  exit 1
fi

JAR_PATH="$1"

if [ ! -f "$JAR_PATH" ]; then
  echo "Error: JAR file not found: $JAR_PATH"
  exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Running TLS13Client"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "JAR: $JAR_PATH"
echo "Java version: $JAVA_VERSION"
echo ""

# Check if compilation is needed
NEED_COMPILE=0

if [ $FORCE_COMPILE -eq 1 ]; then
  echo "🔄 Force compilation requested"
  NEED_COMPILE=1
elif [ ! -f "TLS13Client.class" ]; then
  echo "⚠️  TLS13Client.class not found"
  NEED_COMPILE=1
elif [ "TLS13Client.java" -nt "TLS13Client.class" ]; then
  echo "⚠️  TLS13Client.java is newer than TLS13Client.class"
  NEED_COMPILE=1
fi

# Compile if needed
if [ $NEED_COMPILE -eq 1 ]; then
  echo "📦 Compiling TLS13Client.java..."
  javac -cp "$JAR_PATH" TLS13Client.java
  if [ $? -eq 0 ]; then
    echo "✅ Compilation successful"
  else
    echo "❌ Compilation failed"
    exit 1
  fi
  echo ""
else
  echo "✅ TLS13Client.class is up to date"
  echo ""
fi

# Run with appropriate parameters based on Java version
if [ "$JAVA_VERSION" -ge 9 ]; then
  echo "Using Java 9+ with --add-opens parameters"
  java --add-opens java.base/java.net=ALL-UNNAMED \
       --add-opens java.base/sun.security.x509=ALL-UNNAMED \
       -cp ".:$JAR_PATH" \
       TLS13Client
else
  echo "Using Java 8 (no --add-opens needed)"
  java -cp ".:$JAR_PATH" TLS13Client
fi
