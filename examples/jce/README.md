# JCE Examples

Every example in this directory is a standalone example that demonstrates how to use the JCE API in Tongsuo OpenJDK.

## Quick Start (Recommended)

The easiest way to run examples is using the provided convenience scripts with the uber JAR:

```shell
cd examples/jce

# Download uber JAR (static version - no external dependencies)
wget https://github.com/Tongsuo-Project/tongsuo-java-sdk/releases/download/v1.1.0/tongsuo-openjdk-1.1.0-uber.jar

# Download BouncyCastle (for server only)
wget https://repo1.maven.org/maven2/org/bouncycastle/bcprov-jdk15on/1.69/bcprov-jdk15on-1.69.jar

# Run client
./run-client.sh tongsuo-openjdk-1.1.0-uber.jar

# Run server (in another terminal)
./run-server.sh bcprov-jdk15on-1.69.jar tongsuo-openjdk-1.1.0-uber.jar
```

The scripts will automatically:
- ✅ Detect your Java version
- ✅ Add required JVM parameters (Java 9+)
- ✅ Compile the code if needed
- ✅ Run the example

## Prerequisites

**Java 9+ Module System:** When using Java 9 or later, you need to add JVM parameters to allow Conscrypt to access internal Java APIs:

```shell
--add-opens java.base/java.net=ALL-UNNAMED
--add-opens java.base/sun.security.x509=ALL-UNNAMED
```

The convenience scripts (`run-client.sh` and `run-server.sh`) handle this automatically.

## TLS13Client

### Using Convenience Script (Recommended)

```shell
cd examples/jce

# Basic usage
./run-client.sh tongsuo-openjdk-1.1.0-uber.jar

# Force recompilation
./run-client.sh --force-compile tongsuo-openjdk-1.1.0-uber.jar
```

### Manual Usage

```shell
cd examples/jce

# Build
javac -cp tongsuo-openjdk-1.1.0-uber.jar TLS13Client.java

# Run (Java 9+)
java --add-opens java.base/java.net=ALL-UNNAMED \
     --add-opens java.base/sun.security.x509=ALL-UNNAMED \
     -cp .:tongsuo-openjdk-1.1.0-uber.jar \
     TLS13Client

# Run (Java 8)
java -cp .:tongsuo-openjdk-1.1.0-uber.jar TLS13Client
```

## TLS13Server

**Note:** The server requires:
- BouncyCastle JAR (`bcprov-jdk15on-1.69.jar`)
- Certificate files: `sm2.crt`, `sm2.key`, `chain.crt` (provided in this directory)

### Using Convenience Script (Recommended)

```shell
cd examples/jce

# Basic usage
./run-server.sh bcprov-jdk15on-1.69.jar tongsuo-openjdk-1.1.0-uber.jar

# Force recompilation
./run-server.sh --force-compile bcprov-jdk15on-1.69.jar tongsuo-openjdk-1.1.0-uber.jar
```

### Manual Usage

```shell
cd examples/jce

# Build
javac -cp bcprov-jdk15on-1.69.jar:tongsuo-openjdk-1.1.0-uber.jar TLS13Server.java

# Run (Java 9+)
java --add-opens java.base/java.net=ALL-UNNAMED \
     --add-opens java.base/sun.security.x509=ALL-UNNAMED \
     -cp .:bcprov-jdk15on-1.69.jar:tongsuo-openjdk-1.1.0-uber.jar \
     TLS13Server

# Run (Java 8)
java -cp .:bcprov-jdk15on-1.69.jar:tongsuo-openjdk-1.1.0-uber.jar TLS13Server
```

## Choosing the Right JAR

We provide two uber JARs:

### Static Uber JAR (Recommended) ⭐
- **Filename:** `tongsuo-openjdk-{version}-uber.jar`
- **Pros:** No external dependencies, works out of the box
- **Cons:** Larger file size (~15-20 MB)
- **Use when:** You want simplicity and don't mind the file size

### Dynamic Uber JAR (Advanced)
- **Filename:** `tongsuo-openjdk-{version}-dynamic-uber.jar`
- **Pros:** Smaller file size (~1-2 MB)
- **Cons:** Requires Tongsuo installed on your system
- **Use when:** You have Tongsuo installed and want smaller JARs

**For most users, the static uber JAR is recommended.**

## Troubleshooting

### InaccessibleObjectException (Java 9+)

**Error:**
```
java.lang.reflect.InaccessibleObjectException: Unable to make java.net.InetAddress$InetAddressHolder java.net.InetAddress.holder() accessible
```

**Solution:** Add the required JVM parameters:
```bash
java --add-opens java.base/java.net=ALL-UNNAMED \
     --add-opens java.base/sun.security.x509=ALL-UNNAMED \
     -cp .:tongsuo-openjdk-1.1.0-uber.jar \
     YourClass
```

Or use the convenience scripts which handle this automatically.

### UnsatisfiedLinkError (Dynamic Uber JAR only)

**Error:**
```
java.lang.UnsatisfiedLinkError: ... libssl.3.dylib ... no such file
```

**Solution:** Install Tongsuo on your system:
- **macOS:** `brew install tongsuo`
- **Linux:** Install to `/usr/local/lib` and run `sudo ldconfig`

Or switch to the static uber JAR which has no external dependencies.

### Compilation Errors

If you encounter compilation errors, try forcing recompilation:
```bash
./run-client.sh --force-compile tongsuo-openjdk-1.1.0-uber.jar
./run-server.sh --force-compile bcprov-jdk15on-1.69.jar tongsuo-openjdk-1.1.0-uber.jar
```

## Complete Example Session

```bash
cd examples/jce

# 1. Download dependencies
wget https://github.com/Tongsuo-Project/tongsuo-java-sdk/releases/download/v1.1.0/tongsuo-openjdk-1.1.0-uber.jar
wget https://repo1.maven.org/maven2/org/bouncycastle/bcprov-jdk15on/1.69/bcprov-jdk15on-1.69.jar

# 2. Start server in one terminal
./run-server.sh bcprov-jdk15on-1.69.jar tongsuo-openjdk-1.1.0-uber.jar

# 3. In another terminal, run client
./run-client.sh tongsuo-openjdk-1.1.0-uber.jar
```

That's it! The scripts handle everything else automatically. 🎉
