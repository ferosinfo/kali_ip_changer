# kali_ip_changer

A lightweight, automated Tor IP rotation tool built exclusively for **Kali Linux**. It uses Tor's `ControlPort` (`SIGNAL NEWNYM`) to rotate exit nodes quickly without restarting the Tor service or dropping active circuits.

---

## ⚠️ Disclaimer & Authorized Use Only

> **FOR EDUCATIONAL & AUTHORIZED LAB USE ONLY:** This tool is created strictly for cybersecurity learning, network privacy testing, and authorized lab environments. **Do NOT use this tool for any illegal, malicious, or unauthorized activities.** The author and contributors assume no responsibility or liability for misuse of this software.

---

## ✨ Features

* **Kali Linux Exclusive:** Validates `/etc/os-release` to ensure the script runs strictly on Kali Linux.
* **Fast `NEWNYM` Circuit Rotation:** Connects to Tor's ControlPort (`127.0.0.1:9051`) using cookie authentication to switch exit nodes smoothly without service reload lag.
* **Automated Dependency Setup:** Automatically checks, installs, and configures `curl`, `tor`, `netcat-openbsd`, and `/etc/tor/torrc` ControlPort settings.
* **Flexible Rotation Modes:** Supports fixed-count IP rotation cycles or continuous randomized intervals (`10–20s`).

---

## 📋 Prerequisites

* **OS:** Kali Linux
* **Privileges:** Root (`sudo`) access required to manage the Tor service and read the Tor control authentication cookie.

---

## 🚀 Installation & Usage

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ferosinfo/kali_ip_changer.git
   cd kali_ip_changer
   ```

2. **Make the script executable:**
   ```bash
   chmod +x kali_ip_changer.sh
   ```

3. **Run the script:**
   ```bash
   sudo ./kali_ip_changer.sh
   ```

4. **Configure rotation prompts:**
   * **Time interval (seconds):** Enter `10` or higher (Tor enforces a minimum 10-second cooldown between `NEWNYM` signals), or `0` for random `10–20s` intervals.
   * **Number of cycles:** Enter the exact number of rotations, or `0` for infinite rotation until stopped with `Ctrl + C`.

---

## 🌐 Browser Proxy Setup & IP Verification

`kali_ip_changer` exposes a local Tor SOCKS5 proxy at **`127.0.0.1:9050`**. To route browser traffic through the rotating IP:

1. Open **Firefox** → **Settings** → **Network Settings** → **Settings...**
2. Select **Manual proxy configuration**:
   * **SOCKS Host:** `127.0.0.1`
   * **Port:** `9050`
   * **SOCKS Version:** `SOCKS v5`
   * Enable **Proxy DNS when using SOCKS v5** (prevents DNS leaks)
3. Click **OK**.

> **Important Note on Browser IP Verification:**  
> To verify your updated Tor exit IP in a web browser, **clear your browser cache and restart the browser** (or open a fresh Private Window and hard-refresh with `Ctrl + Shift + R`) before visiting an IP checker such as `https://check.torproject.org` or `https://api.ipify.org`. Web browsers reuse cached pages and HTTP Keep-Alive connections, which can continue displaying an older exit IP until the cache is cleared and the browser is restarted.

*(Remember to switch Firefox Network Settings back to **Use system proxy settings** after stopping `kali_ip_changer`.)*

---

## 🛠️ CLI Usage with ProxyChains

To route terminal commands through the Tor SOCKS5 proxy, ensure `/etc/proxychains4.conf` has `proxy_dns` enabled and `socks5 127.0.0.1 9050` set at the bottom of the file:

```bash
proxychains4 curl -s [https://api.ipify.org](https://api.ipify.org)
```

---

## 🙏 Acknowledgements & Credits

Special thanks to the original repository developer (**[GR33N37](https://github.com/GR33N37)**) for the foundational Tor IP rotation concept and shell script logic that inspired this Kali Linux tool.
