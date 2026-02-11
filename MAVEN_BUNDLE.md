# Maven Central Bundle 准备指南

本文档说明如何为 `com.infinilabs` groupId 准备 Maven Central 发布包。

## 概述

该 workflow 会：
1. 为所有支持的平台构建 JAR（linux-x86_64, linux-aarch_64, osx-x86_64, osx-aarch_64, windows-x86_64）
2. 构建两个 uber JAR（静态和动态版本）
3. 生成 POM 文件
4. 对所有文件进行 GPG 签名
5. 生成 MD5 和 SHA1 校验和
6. 打包成 Maven Central 格式的 ZIP bundle
7. 创建 GitHub Release

## 前提条件

### 1. 配置 GPG 密钥

在 GitHub 仓库的 Settings → Secrets and variables → Actions 中添加：

- `GPG_PRIVATE_KEY`: GPG 私钥（ASCII armored 格式）
- `GPG_PASSPHRASE`: GPG 密钥密码

#### 生成 GPG 密钥

```bash
# 生成新密钥
gpg --full-generate-key
# 选择: RSA and RSA, 4096 bits, 0 = key does not expire

# 列出密钥
gpg --list-secret-keys --keyid-format=long

# 导出私钥（替换 YOUR_KEY_ID）
gpg --armor --export-secret-keys YOUR_KEY_ID
```

将导出的私钥（包括 `-----BEGIN PGP PRIVATE KEY BLOCK-----` 和 `-----END PGP PRIVATE KEY BLOCK-----`）复制到 `GPG_PRIVATE_KEY` secret 中。

### 2. 配置 Maven Central 凭证

在 infinilabs/ci 仓库中应该已经配置了：

- `OSSRH_USERNAME`: Sonatype OSSRH 用户名
- `OSSRH_PASSWORD`: Sonatype OSSRH 密码

## 使用方法

### 步骤 1: 触发 Bundle 构建

1. 进入 GitHub Actions 页面
2. 选择 "Prepare Maven Central Bundle" workflow
3. 点击 "Run workflow"
4. 填写参数：
   - **version**: 要发布的版本号（如 `1.1.0`）
   - **group_id**: Maven Group ID（默认 `com.infinilabs`）

### 步骤 2: 等待构建完成

Workflow 会：
- 为每个平台构建 JAR（~10-15 分钟/平台）
- 构建 uber JAR（~5 分钟）
- 创建签名的 bundle（~2 分钟）
- 创建 GitHub Release

### 步骤 3: 下载 Bundle

构建完成后，可以从两个地方获取 bundle：

1. **GitHub Release**:
   - 标签名: `v{version}-maven`
   - 附件: `tongsuo-openjdk-{version}-maven-bundle.zip`

2. **Workflow Artifacts**:
   - 名称: `maven-bundle`
   - 保留 30 天

### 步骤 4: 在 infinilabs/ci 中发布

```bash
# 1. Clone ci 仓库
git clone https://github.com/infinilabs/ci.git
cd ci

# 2. 下载 bundle ZIP 到合适位置
# 例如: products/tongsuo/bundle/

# 3. 触发发布 workflow
# 在 GitHub Actions UI 中手动触发 publish-maven-central.yml
# 参数:
#   - JDK_VERSION: 11
#   - BUILD_TOOL: gradle
#   - PUBLISH_COMPONENT: tongsuo-openjdk
#   - PUBLISH_VERSION: 1.1.0
```

或者修改 infinilabs/ci 的 workflow 来直接下载这个仓库的 release。

## Bundle 内容结构

```
maven-bundle/
  com/
    infinilabs/
      tongsuo-openjdk/
        1.1.0/
          ├── tongsuo-openjdk-1.1.0.pom
          ├── tongsuo-openjdk-1.1.0.pom.asc
          ├── tongsuo-openjdk-1.1.0.pom.md5
          ├── tongsuo-openjdk-1.1.0.pom.sha1
          │
          ├── tongsuo-openjdk-1.1.0-linux-x86_64.jar
          ├── tongsuo-openjdk-1.1.0-linux-x86_64.jar.asc
          ├── tongsuo-openjdk-1.1.0-linux-x86_64.jar.md5
          ├── tongsuo-openjdk-1.1.0-linux-x86_64.jar.sha1
          ├── tongsuo-openjdk-1.1.0-linux-x86_64-sources.jar
          ├── tongsuo-openjdk-1.1.0-linux-x86_64-sources.jar.asc
          ├── tongsuo-openjdk-1.1.0-linux-x86_64-javadoc.jar
          ├── tongsuo-openjdk-1.1.0-linux-x86_64-javadoc.jar.asc
          │
          ├── ... (其他平台类似)
          │
          ├── tongsuo-openjdk-1.1.0-static-uber.jar
          ├── tongsuo-openjdk-1.1.0-static-uber.jar.asc
          ├── tongsuo-openjdk-1.1.0-dynamic-uber.jar
          └── tongsuo-openjdk-1.1.0-dynamic-uber.jar.asc
```

## Maven 使用方式

### 平台特定 JAR

```xml
<dependency>
  <groupId>com.infinilabs</groupId>
  <artifactId>tongsuo-openjdk</artifactId>
  <version>1.1.0</version>
  <classifier>linux-x86_64</classifier>
</dependency>
```

### Static Uber JAR（推荐）

```xml
<dependency>
  <groupId>com.infinilabs</groupId>
  <artifactId>tongsuo-openjdk</artifactId>
  <version>1.1.0</version>
  <classifier>static-uber</classifier>
</dependency>
```

### Dynamic Uber JAR（需要系统安装 Tongsuo）

```xml
<dependency>
  <groupId>com.infinilabs</groupId>
  <artifactId>tongsuo-openjdk</artifactId>
  <version>1.1.0</version>
  <classifier>dynamic-uber</classifier>
</dependency>
```

## 故障排除

### GPG 签名失败

确保：
1. `GPG_PRIVATE_KEY` secret 包含完整的私钥（包括头尾）
2. `GPG_PASSPHRASE` 正确
3. 密钥没有过期

### 平台构建失败

某些平台可能需要特殊配置：
- **Linux ARM64**: 使用 QEMU 交叉编译
- **macOS**: 需要 Xcode 命令行工具
- **Windows**: 需要 Visual Studio Build Tools

### Bundle 结构错误

检查：
1. 所有平台的 artifacts 是否成功上传
2. POM 文件中的 groupId 和 version 是否正确
3. 签名文件（.asc）是否存在

## 与官方发布的区别

| 项目 | 官方 (net.tongsuo) | infinilabs (com.infinilabs) |
|------|-------------------|----------------------------|
| Group ID | `net.tongsuo` | `com.infinilabs` |
| 发布位置 | Sonatype OSSRH | Maven Central Portal |
| 发布流程 | 官方 CI/CD | 此 workflow + infinilabs/ci |
| 代码来源 | Tongsuo-Project/tongsuo-java-sdk | infinilabs/tongsuo-java-sdk (fork) |

**注意**: 两个版本的代码功能完全相同，只是 Maven 坐标不同。

## 参考资料

- [Maven Central Publishing Guide](https://central.sonatype.org/publish/publish-guide/)
- [GPG Signing](https://central.sonatype.org/publish/requirements/gpg/)
- [infinilabs/ci workflow](https://github.com/infinilabs/ci/blob/main/.github/workflows/publish-maven-central.yml)
