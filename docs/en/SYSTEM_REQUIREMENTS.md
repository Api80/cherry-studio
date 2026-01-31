# Cherry Studio System Requirements

> Complete system requirements and hardware configuration guide

## Quick Reference

### Windows

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **OS** | Windows 10 (1809+) 64-bit | Windows 10 21H2+ / Windows 11 |
| **CPU** | Dual-core 2.0 GHz | Quad-core 2.5 GHz+ |
| **RAM** | 4 GB | 8 GB |
| **Storage** | 500 MB | 2 GB (SSD) |
| **Graphics** | DirectX 11 | Dedicated GPU |
| **Display** | 1280 x 720 | 1920 x 1080 |
| **Network** | Internet connection | Broadband |

### macOS

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **OS** | macOS 11 Big Sur | macOS 12 Monterey+ |
| **CPU** | Intel i3 / Apple M1 | Intel i5 / Apple M1/M2 |
| **RAM** | 4 GB | 8 GB |
| **Storage** | 500 MB | 2 GB |
| **Display** | 1280 x 800 | 2560 x 1600 (Retina) |

### Linux

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **Distro** | Ubuntu 20.04, Debian 10, Fedora 33+ | Ubuntu 22.04 LTS+ |
| **CPU** | Dual-core 2.0 GHz | Quad-core 2.5 GHz+ |
| **RAM** | 4 GB | 8 GB |
| **Storage** | 500 MB | 2 GB |
| **Display** | 1280 x 720 | 1920 x 1080 |

---

## Detailed Requirements

### Windows System Requirements

#### Supported Versions

✅ **Fully Supported**:
- Windows 11 (all editions)
- Windows 10 21H2 and higher
- Windows 10 2004 (20H1) and higher

⚠️ **Basic Support**:
- Windows 10 1809 - 1903

❌ **Not Supported**:
- Windows 8.1 and earlier
- Windows 10 LTSC 2015 (version 1507)
- Windows 10 1507-1803

#### Architecture Support

| Architecture | Status | Notes |
|-------------|--------|-------|
| **x64 (64-bit)** | ✅ Fully supported | Intel/AMD 64-bit processors |
| **ARM64** | ✅ Fully supported | ARM64 Windows devices (e.g., Surface Pro X) |
| **x86 (32-bit)** | ❌ Not supported | 64-bit only |

#### Feature Requirements

| Feature | Windows Requirement | Notes |
|---------|-------------------|-------|
| Basic Chat | Windows 10 1809+ | All editions |
| System Tray | Windows 10+ | Notification area |
| Global Hotkeys | Windows 10+ | System-wide shortcuts |
| Auto Update | Windows 10+ | App updates |
| OCR | Windows 10 1903+ | Image text recognition |
| Voice | Windows 10 2004+ | Voice input/output |
| GPU Acceleration | DirectX 11/12 | Hardware rendering |

### macOS System Requirements

#### Supported Versions

✅ **Fully Supported**:
- macOS 15 Sequoia
- macOS 14 Sonoma
- macOS 13 Ventura
- macOS 12 Monterey

⚠️ **Basic Support**:
- macOS 11 Big Sur

❌ **Not Supported**:
- macOS 10.15 Catalina and earlier

#### Architecture Support

| Architecture | Status | Notes |
|-------------|--------|-------|
| **Apple Silicon (M1/M2/M3)** | ✅ Native support | ARM64 native app |
| **Intel (x64)** | ✅ Fully supported | x64 native app |

### Linux System Requirements

#### Tested Distributions

✅ **Tested and Verified**:
- Ubuntu 20.04 LTS, 22.04 LTS, 24.04 LTS
- Debian 10, 11, 12
- Fedora 35+
- openSUSE Leap 15.3+
- Arch Linux (latest)
- Manjaro (latest)

⚠️ **May Work** (not fully tested):
- CentOS 8+
- RHEL 8+
- Linux Mint 20+
- Pop!_OS 20.04+

#### Architecture Support

| Architecture | Status | Package Formats |
|-------------|--------|----------------|
| **x64 (64-bit)** | ✅ Fully supported | .deb, .rpm, .AppImage |
| **ARM64** | ✅ Fully supported | .deb, .rpm, .AppImage |
| **x86 (32-bit)** | ❌ Not supported | 64-bit only |

#### Required Dependencies

```bash
# Ubuntu/Debian
sudo apt-get install libgtk-3-0 libnotify4 libnss3 libxtst6 \
  libatspi2.0-0 libsecret-1-0 libgbm1

# Fedora/RHEL
sudo dnf install gtk3 libnotify nss libXtst at-spi2-core libsecret mesa-libgbm

# Arch/Manjaro
sudo pacman -S gtk3 libnotify nss libxtst at-spi2-core libsecret
```

---

## Hardware Requirements

### CPU (Processor)

#### Minimum ⚠️
- **Architecture**: x64 (64-bit) or ARM64
- **Cores**: Dual-core
- **Frequency**: 2.0 GHz or higher
- **Generation**:
  - Intel: 4th Gen (Haswell, 2013) or newer
  - AMD: Ryzen 1000 series (2017) or newer
  - ARM: Apple M1 or newer

#### Recommended ⭐
- **Architecture**: x64 or ARM64
- **Cores**: Quad-core or more
- **Frequency**: 2.5 GHz or higher
- **Generation**:
  - Intel: 8th Gen (Coffee Lake, 2017) or newer
  - AMD: Ryzen 3000 series (2019) or newer
  - ARM: Apple M1/M2/M3

### Memory (RAM)

| Use Case | Minimum | Recommended | Optimal |
|----------|---------|-------------|---------|
| **Basic Chat** | 4 GB | 8 GB | 16 GB |
| **Multiple Chats** | 6 GB | 12 GB | 16 GB |
| **Large Knowledge Base** | 8 GB | 16 GB | 32 GB |
| **Development** | 8 GB | 16 GB | 32 GB |

### Storage

| Purpose | Minimum | Recommended | Notes |
|---------|---------|-------------|-------|
| **Application** | 200 MB | 500 MB | Cherry Studio installer |
| **User Data** | 100 MB | 500 MB | Chat history, settings |
| **Cache** | 100 MB | 500 MB | Temp files, model cache |
| **Knowledge Base** | 100 MB | 1 GB | Documents, vector DB |
| **Total** | 500 MB | 2-5 GB | SSD recommended |

**Storage Type**:
- ✅ **SSD (Solid State Drive)**: Highly recommended, improves speed
- ⚠️ **HDD (Hard Disk Drive)**: Works, but slower

### Graphics (GPU)

| Scenario | Requirement | Notes |
|----------|-------------|-------|
| **Basic Use** | Integrated GPU | Intel HD Graphics 4000+ / AMD Radeon |
| **Recommended** | Dedicated GPU | DirectX 11/12 or OpenGL 3.3+ |
| **Best Experience** | Modern GPU | NVIDIA GeForce / AMD Radeon 2GB+ VRAM |

**GPU Acceleration**:
- ✅ Windows: DirectX 11/12
- ✅ macOS: Metal
- ✅ Linux: OpenGL 3.3+ / Vulkan

### Display

| Configuration | Resolution | Notes |
|---------------|-----------|-------|
| **Minimum** | 1280 x 720 (HD) | Usable but cramped |
| **Recommended** | 1920 x 1080 (Full HD) | Best display |
| **Optimal** | 2560 x 1440 (2K) or 3840 x 2160 (4K) | High-res experience |

**Multi-monitor**: ✅ Fully supported

---

## Network Requirements

### Internet Connection

| Feature | Network Required | Notes |
|---------|-----------------|-------|
| **Basic Chat** | Required | Access AI cloud services |
| **Knowledge Base** | Optional | Local KB works offline |
| **Auto Update** | Optional | Manual update available |
| **Cloud Backup** | Optional | WebDAV sync |

### Network Speed

| Use Case | Minimum Speed | Recommended Speed |
|----------|--------------|------------------|
| **Text Chat** | 512 Kbps | 5 Mbps |
| **Image Processing** | 2 Mbps | 10 Mbps |
| **Video Analysis** | 5 Mbps | 25 Mbps |
| **Large File Upload** | 2 Mbps | 50 Mbps |

### Proxy Support

✅ Cherry Studio supports:
- HTTP/HTTPS proxy
- SOCKS5 proxy
- System proxy settings

---

## Special Feature Requirements

### Local Models (Ollama)

If using Ollama for local models:

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **RAM** | 8 GB | 16 GB+ |
| **Storage** | 10 GB+ | 50 GB+ (SSD) |
| **GPU** | Optional | NVIDIA GPU (6GB+ VRAM) |

**Supported GPUs**:
- NVIDIA GPU (CUDA support)
- AMD GPU (ROCm support, Linux)
- Apple Silicon GPU (Metal, macOS)

### Knowledge Base & Vector DB

Large-scale knowledge base recommendations:

| KB Size | RAM Required | Storage Required |
|---------|-------------|-----------------|
| **Small** (< 1000 docs) | 4 GB | 500 MB |
| **Medium** (1000-10000) | 8 GB | 2 GB |
| **Large** (> 10000) | 16 GB+ | 5 GB+ |

---

## FAQ

### Q1: Can my computer run Cherry Studio?

**A**: Check these conditions:

✅ **Yes** (all of these):
- Windows 10 1809+ / macOS 11+ / Linux (64-bit)
- 4GB RAM
- 500MB free space
- Internet connection

❌ **No** (any of these):
- 32-bit OS
- Windows 8.1 or earlier
- macOS 10.15 or earlier
- Less than 4GB RAM

### Q2: Does Cherry Studio support 32-bit systems?

**A**: ❌ **No**

Cherry Studio is based on Electron 38, 64-bit only:
- x64 (64-bit Intel/AMD)
- ARM64 (64-bit ARM)

### Q3: Can I run it on Windows 7?

**A**: ❌ **No**

Minimum requirement is Windows 10 1809. Windows 7 is no longer supported.

### Q4: Do I need a GPU?

**A**: ⚠️ **Not required, but recommended**

| Scenario | GPU Need |
|----------|----------|
| Basic chat | ❌ Not needed - integrated GPU OK |
| Smooth UI | ✅ Recommended - dedicated GPU better |
| Local models (Ollama) | ✅✅ Highly recommended - NVIDIA GPU speeds up significantly |

### Q5: How much storage does it use?

**A**: 

```
Installer: 150-200 MB (Windows), 200-300 MB (macOS)
Installed: 300-500 MB
+ User data: 100-500 MB
+ Cache: 100-500 MB
+ Knowledge base: Depends on usage
─────────────────────────
Total: ~500 MB - 5 GB
```

### Q6: Can I run it in a virtual machine?

**A**: ✅ **Yes**, but performance will be reduced

**Recommended VM config**:
- Allocate 4 CPU cores
- Allocate 8GB RAM
- Enable 3D acceleration
- Use bridged network

**Performance comparison**:
- Physical machine: 100% performance
- Virtual machine: 60-80% performance

### Q7: ARM Windows support?

**A**: ✅ **Fully supported**

Cherry Studio provides ARM64 version for:
- Surface Pro X
- Other ARM Windows devices

Performance comparable to x64 version.

### Q8: Which version should I download?

**A**: 

| System | Recommended Version |
|--------|-------------------|
| **Windows x64** | cherry-studio-setup.exe |
| **Windows ARM64** | cherry-studio-arm64-setup.exe |
| **macOS Intel** | cherry-studio-x64.dmg |
| **macOS Apple Silicon** | cherry-studio-arm64.dmg |
| **Linux x64** | .deb / .rpm / .AppImage |

---

## Related Resources

- [Official Website](https://cherry-ai.com)
- [Download Page](https://github.com/CherryHQ/cherry-studio/releases)
- [Documentation](https://docs.cherry-ai.com)
- [Issue Tracker](https://github.com/CherryHQ/cherry-studio/issues)

---

**Document Version**: v1.0  
**Created**: 2026-01-31  
**Applies to**: Cherry Studio 1.7.15+

For detailed Chinese documentation, see [中文版本](../zh/SYSTEM_REQUIREMENTS.md).
