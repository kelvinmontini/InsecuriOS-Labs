<div align="center">

<img src="assets/banner_light.png#gh-dark-mode-only" width="600" height="220" alt="InsecuriOS Labs">
<img src="assets/banner_dark.png#gh-light-mode-only" width="600" height="220" alt="InsecuriOS Labs">

</div>

InsecuriOS Labs is an educational iOS application designed to demonstrate and practice hacking and pentesting techniques on iOS devices. The application implements various common protections found in commercial iOS apps, allowing students, security researchers, and developers to learn how these protections work and how they can be bypassed using tools such as LLDB, Frida, Reverse Engineering, Patching, and more.

## Table of Contents

- [Implemented Protections](#implemented-protections)
  - [Biometrics (Touch ID / Face ID)](#biometrics-touch-id--face-id)
  - [Jailbreak Detection](#jailbreak-detection)
  - [Frida Detection](#frida-detection)
  - [SSL Pinning](#ssl-pinning)
  - [Data Storage](#data-storage)
  - [Application Patching](#application-patching)

### Jailbreak Detection

**Objective:**
Practice techniques to bypass multiple jailbreak detection implementations, from simple checks to commercial libraries and low-level implementations.

**Description:**
This module presents four different variations of jailbreak detection:
- Swift Implementation: Checks URL schemes, suspicious files, writable directories, symbolic links, and tweak libraries
- Objective-C Implementation: Checks URL schemes, suspicious files, writable directories, symbolic links, and tweak libraries
- External Library: Uses external security tools
- Dynamic Library (dylib): Low-level implementation loaded dynamically

Each implementation demonstrates different detection techniques, providing a complete environment to learn and test bypass methods.

---

### Frida Detection

**Objective:**
Understand how applications detect dynamic instrumentation tools and learn techniques to avoid these detections during security testing.

**Description:**
This module implements two common Frida detection techniques:
- Server detection
- FridaGadget detection

Learning to bypass these detections is essential for performing dynamic security testing on protected iOS applications.

---

### SSL Pinning

**Objective:**
Explore different SSL Certificate Pinning implementations and techniques to bypass them, enabling analysis of intercepted HTTPS traffic.

**Description:**
SSL Pinning is a security technique that ensures only specific certificates are accepted during HTTPS communications. This module presents three different implementations:
- URLSession
- Alamofire
- TrustKit

Each implementation demonstrates different approaches to certificate pinning, offering varied opportunities to learn bypass techniques.

---

### Data Storage

**Objective:**
Practice intercepting sensitive data stored in Keychain and NSUserDefaults, including data that is saved and immediately deleted.

**Description:**
This module presents challenges for intercepting data stored in native iOS mechanisms:
- Keychain: Intercept data before immediate deletion
- NSUserDefaults: Capture temporary data stored in UserDefaults
- Keychain Dump: Find hidden persistent keys

Data is saved and deleted quickly, requiring dynamic interception techniques to capture it before it's removed.

---

### Application Patching

**Objective:**
Learn to bypass anti-debugging protections and practice method patching techniques to modify application behavior at runtime.

**Description:**
This module presents challenges related to protections against debugging and application modification:
- Anti-Debugging: Protections that detect and prevent debugger attachment
- Method Patching: Challenges to modify method behavior at runtime

These techniques are fundamental to understanding how protected applications detect dynamic analysis and how these protections can be bypassed.

---


## Requirements

- **iOS**: 13.0+
- **Device**: iPhone/iPad (Requires physical device with Jailbreak)

---

## Installation

1. Clone the repository:
```bash
git clone https://github.com/kelvinmontini/InsecuriOS-Labs.git
cd InsecuriOS-Labs
```

2. Open the project in Xcode:
```bash
open "InsecuriOS Labs.xcodeproj"
```

3. Configure your Team ID and Bundle Identifier

4. Build in Release and install on the device.

---


## References

### Similar Projects
- [DVIA-v2](https://github.com/prateek147/DVIA-v2): Damn Vulnerable iOS App
- [iGoat-Swift](https://github.com/OWASP/igoat-swift): Vulnerable iOS app

---

## Disclaimer

This project is for educational purposes only. The use of hacking techniques on applications without authorization is illegal. Use responsibly and only in controlled environments or with explicit permission.
