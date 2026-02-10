#!/bin/bash
#
# Convenience script to run TLS13Server with proper JVM parameters
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

# Check if JAR paths are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 [--force-compile] <path-to-bcprov.jar> <path-to-tongsuo-openjdk.jar>"
  echo ""
  echo "Options:"
  echo "  --force-compile, -f    Force recompilation even if .class file exists"
  echo ""
  echo "Examples:"
  echo "  $0 bcprov-jdk15on-1.69.jar tongsuo-openjdk-1.1.0-uber.jar"
  echo "  $0 --force-compile bcprov-jdk15on-1.69.jar tongsuo-openjdk-1.1.0-uber.jar"
  echo ""
  echo "Note: You can download bcprov from:"
  echo "  https://repo1.maven.org/maven2/org/bouncycastle/bcprov-jdk15on/1.69/bcprov-jdk15on-1.69.jar"
  exit 1
fi

BCPROV_JAR="$1"
TONGSUO_JAR="$2"

if [ ! -f "$BCPROV_JAR" ]; then
  echo "Error: BouncyCastle JAR not found: $BCPROV_JAR"
  exit 1
fi

if [ ! -f "$TONGSUO_JAR" ]; then
  echo "Error: Tongsuo JAR not found: $TONGSUO_JAR"
  exit 1
fi

# Check required certificate files
if [ ! -f "sm2.crt" ] || [ ! -f "sm2.key" ] || [ ! -f "chain.crt" ]; then
  echo "Error: Required certificate files not found!"
  echo "  - sm2.crt"
  echo "  - sm2.key"
  echo "  - chain.crt"
  exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Running TLS13Server"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "BouncyCastle JAR: $BCPROV_JAR"
echo "Tongsuo JAR: $TONGSUO_JAR"
echo "Java version: $JAVA_VERSION"
echo ""

# Check if compilation is needed
NEED_COMPILE=0

if [ $FORCE_COMPILE -eq 1 ]; then
  echo "🔄 Force compilation requested"
  NEED_COMPILE=1
elif [ ! -f "TLS13Server.class" ]; then
  echo "⚠️  TLS13Server.class not found"
  NEED_COMPILE=1
elif [ "TLS13Server.java" -nt "TLS13Server.class" ]; then
  echo "⚠️  TLS13Server.java is newer than TLS13Server.class"
  NEED_COMPILE=1
fi

# Compile if needed
if [ $NEED_COMPILE -eq 1 ]; then
  echo "📦 Compiling TLS13Server.java..."
  javac -cp "$BCPROV_JAR:$TONGSUO_JAR" TLS13Server.java
  if [ $? -eq 0 ]; then
    echo "✅ Compilation successful"
  else
    echo "❌ Compilation failed"
    exit 1
  fi
  echo ""
else
  echo "✅ TLS13Server.class is up to date"
  echo ""
fi

# Run with appropriate parameters based on Java version
if [ "$JAVA_VERSION" -ge 9 ]; then
  echo "Using Java 9+ with --add-opens parameters"
  echo "Server will listen on port 8443..."
  echo ""
  java --add-opens java.base/java.net=ALL-UNNAMED \
       --add-opens java.base/sun.security.x509=ALL-UNNAMED \
       -cp ".:$BCPROV_JAR:$TONGSUO_JAR" \
       TLS13Server
else
  echo "Using Java 8 (no --add-opens needed)"
  echo "Server will listen on port 8443..."
  echo ""
  java -cp ".:$BCPROV_JAR:$TONGSUO_JAR" TLS13Server
fi
