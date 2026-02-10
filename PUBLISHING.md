# Publishing to Maven Central

This document explains how to publish Tongsuo Java SDK to Maven Central with custom organization settings.

## Default Configuration

By default, the project uses the following Maven coordinates:

- **Group ID**: `net.tongsuo`
- **Artifact ID**: `tongsuo-openjdk`
- **Organization**: Tongsuo Project

## Custom Publishing (For Forks)

If you've forked this project and want to publish under your own Maven group ID, you can customize the settings using Gradle properties.

### Option 1: Using gradle.properties (Recommended)

1. Copy the example configuration:
   ```bash
   cp gradle.properties.example gradle.properties
   ```

2. Edit `gradle.properties` to customize your settings:
   ```properties
   mavenGroupId=com.infinilabs
   mavenProjectUrl=https://github.com/infinilabs/tongsuo-java-sdk
   mavenScmUrl=https://github.com/infinilabs/tongsuo-java-sdk
   mavenDeveloperId=infinilabs
   mavenDeveloperName=INFINI Labs
   mavenDeveloperEmail=hello@infini.ltd
   mavenDeveloperUrl=https://www.infini.ltd/
   mavenOrganization=INFINI Labs
   mavenOrganizationUrl=https://github.com/infinilabs
   ```

3. Add sensitive credentials to `~/.gradle/gradle.properties` (not in the project):
   ```properties
   ossrhUsername=your-sonatype-username
   ossrhPassword=your-sonatype-password
   signing.keyId=your-8-char-key-id
   signing.password=your-key-password
   signing.secretKeyRingFile=/path/to/.gnupg/secring.gpg
   ```

### Option 2: Using Command Line Parameters

You can also override settings via command line:

```bash
./gradlew :tongsuo-openjdk:publish \
  -PmavenGroupId=com.infinilabs \
  -PmavenOrganization="INFINI Labs" \
  -PmavenProjectUrl=https://github.com/infinilabs/tongsuo-java-sdk
```

## Available Properties

| Property | Default | Description |
|----------|---------|-------------|
| `mavenGroupId` | `net.tongsuo` | Maven Group ID |
| `mavenProjectUrl` | `https://www.tongsuo.net/` | Project URL |
| `mavenScmUrl` | `https://github.com/Tongsuo-Project/tongsuo-java-sdk` | SCM URL |
| `mavenDeveloperId` | `tongsuo` | Developer ID |
| `mavenDeveloperName` | `Tongsuo Project Authors` | Developer Name |
| `mavenDeveloperEmail` | `tongsuo-dev@tongsuo.net` | Developer Email |
| `mavenDeveloperUrl` | `https://www.tongsuo.net/` | Developer URL |
| `mavenOrganization` | `Tongsuo Project` | Organization Name |
| `mavenOrganizationUrl` | `https://github.com/Tongsuo-Project` | Organization URL |

## Publishing Steps

### 1. Prerequisites

- Sonatype OSSRH account with your Group ID approved
- GPG key for signing artifacts
- Build environment for all target platforms

### 2. Build and Publish

Build and publish on each platform:

```bash
# Linux
./gradlew :tongsuo-openjdk:clean :tongsuo-openjdk:build :tongsuo-openjdk:publish

# macOS
./gradlew :tongsuo-openjdk:clean :tongsuo-openjdk:build :tongsuo-openjdk:publish

# Windows
gradlew.bat :tongsuo-openjdk:clean :tongsuo-openjdk:build :tongsuo-openjdk:publish
```

### 3. Release on Sonatype

1. Log in to https://s01.oss.sonatype.org/
2. Go to "Staging Repositories"
3. Find your repository (e.g., `com.infinilabs-XXXX`)
4. Click "Close" to trigger validation
5. After validation passes, click "Release"
6. Wait 2-4 hours for sync to Maven Central

## User Consumption

After publishing, users can consume your library:

### Maven (with auto-detection)

```xml
<build>
  <extensions>
    <extension>
      <groupId>kr.motd.maven</groupId>
      <artifactId>os-maven-plugin</artifactId>
      <version>1.7.1</version>
    </extension>
  </extensions>
</build>

<dependencies>
  <dependency>
    <groupId>com.infinilabs</groupId>
    <artifactId>tongsuo-openjdk</artifactId>
    <version>1.1.0</version>
    <classifier>${os.detected.classifier}</classifier>
  </dependency>
</dependencies>
```

### Gradle (with auto-detection)

```gradle
plugins {
    id 'com.google.osdetector' version '1.7.3'
}

dependencies {
    implementation "com.infinilabs:tongsuo-openjdk:1.1.0:${osdetector.classifier}"
}
```

### Manual Platform Specification

If you prefer not to use auto-detection:

```gradle
dependencies {
    implementation 'com.infinilabs:tongsuo-openjdk:1.1.0:linux-x86_64'
}
```

Available classifiers:
- `linux-x86_64`
- `linux-aarch64`
- `darwin64-x86_64` (macOS Intel)
- `darwin64-arm64` (macOS Apple Silicon)
- `VC-WIN64A` (Windows x64)

## Notes

- **Always use gradle.properties for project-specific settings**: This keeps your fork's settings separate from the original project
- **Never commit credentials**: Keep `ossrhUsername`, `ossrhPassword`, and GPG keys in `~/.gradle/gradle.properties`
- **Add gradle.properties to .gitignore**: Prevent accidentally committing your custom settings
