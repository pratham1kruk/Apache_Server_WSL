# 🚀 Apache + DNS + Server Binding Automation (WSL Based)

![Project Status](https://img.shields.io/badge/status-production-green)
![WSL](https://img.shields.io/badge/WSL-2-blue)
![Apache](https://img.shields.io/badge/Apache-2.4-red)
![BIND9](https://img.shields.io/badge/BIND9-DNS-orange)

## 📌 Project Overview

A complete infrastructure automation project that simulates a real-world production environment with:

- 🌐 **Apache Web Server** - Full HTTP/HTTPS server setup
- 🧭 **BIND9 DNS Server** - Custom DNS hosting and zone management
- 🔥 **Firewall Automation** - UFW rule management for all services
- 🔁 **DNS Resolver Control** - WSL resolver configuration and management
- 🗂 **Automatic Backups** - Safe configuration with rollback capability
- 🌍 **Local DNS Mapping** - Custom domain resolution (mywebapp.com → 172.16.0.10)

This project demonstrates enterprise-level infrastructure practices including service binding, DNS management, firewall automation, and network configuration in a WSL2 environment.

---

## 🎯 Key Features

✅ **Automated Installation & Configuration**
- Zero-touch Apache and BIND9 setup
- Automatic dependency resolution
- Service validation and health checks

✅ **DNS Management**
- Custom zone file creation
- Forward DNS resolution
- A record mapping
- Configuration validation

✅ **Security & Firewall**
- UFW integration for Apache (ports 80, 443)
- DNS firewall rules (port 53 TCP/UDP)
- Easy enable/disable scripts

✅ **Resolver Control**
- WSL auto-resolver override
- Custom nameserver configuration
- Resolv.conf management

✅ **Backup & Recovery**
- Pre-execution backups of all configs
- Safe rollback capability
- No data loss on changes

---

## 📁 Project Structure

```
Apache_Server/
│
├── apache_server/
│   ├── setup_apache.sh          # Apache installation & configuration
│   ├── firewall_enable.sh       # Enable Apache firewall rules
│   └── firewall_disable.sh      # Disable Apache firewall rules
│
├── dns_server/
│   ├── dns_setup.sh             # BIND9 installation & zone setup
│   ├── dns_firewall_enable.sh   # Enable DNS firewall rules
│   └── dns_firewall_disable.sh  # Disable DNS firewall rules
│
├── Server_Binding/
│   └── binding_setup.sh         # Complete DNS binding & resolver setup
│
└── README.md                     # This file
```

---

## 🔧 Installation & Usage

### Prerequisites

- WSL2 (Ubuntu 20.04+ recommended)
- Windows 10/11 with administrative access
- Basic understanding of DNS and networking

### Quick Start

```bash
# 1. Clone or download the project
cd Apache_Server/

# 2. Set up Apache Server
cd apache_server/
sudo bash setup_apache.sh
sudo bash firewall_enable.sh

# 3. Set up DNS Server
cd ../dns_server/
sudo bash dns_setup.sh
sudo bash dns_firewall_enable.sh

# 4. Configure Server Binding & Resolver
cd ../Server_Binding/
sudo bash binding_setup.sh

# 5. Configure Windows Network Adapter (see below)
```

---

## 🧱 Component Details

### 1️⃣ Apache Server Setup

**Directory:** `apache_server/`

#### 📄 `setup_apache.sh`
- Installs Apache2 with all dependencies
- Enables and starts Apache service
- Configures default virtual host
- Creates test index.html page
- Verifies service status and port binding
- Provides service URLs and next steps

**Features:**
```bash
✓ Package installation with update
✓ Service enablement
✓ Default site configuration
✓ Health check validation
✓ Colored output with status indicators
```

#### 📄 `firewall_enable.sh`
- Enables UFW (Uncomplicated Firewall)
- Opens port 80 (HTTP)
- Opens port 443 (HTTPS)
- Displays active firewall rules

#### 📄 `firewall_disable.sh`
- Removes Apache firewall rules
- Option to fully disable UFW
- Clean rule removal

---

### 2️⃣ DNS Server Setup (BIND9)

**Directory:** `dns_server/`

#### 📄 `dns_setup.sh`

Complete BIND9 DNS server setup with:

**Installation Phase:**
- BIND9 package installation
- DNS utilities (bind9utils, bind9-doc, dnsutils)

**Configuration Phase:**
- Creates zone directory: `/var/named/`
- Configures `/etc/bind/named.conf.local`
- Configures `/etc/bind/named.conf.options`
- Sets up forwarders (Google DNS: 8.8.8.8, 8.8.4.4)

**Zone Configuration:**
```conf
zone "mywebapp.com" IN {
    type master;
    file "/var/named/mywebapp.com.fzone";
    allow-query { any; };
};
```

**Forward Zone File:** `/var/named/mywebapp.com.fzone`
```dns
$TTL 86400
@   IN  SOA     ns1.mywebapp.com. admin.mywebapp.com. (
            2024020801  ; Serial
            3600        ; Refresh
            1800        ; Retry
            604800      ; Expire
            86400 )     ; Minimum TTL

@           IN  NS      ns1.mywebapp.com.
ns1         IN  A       172.16.0.10
@           IN  A       172.16.0.10
www         IN  A       172.16.0.10
```

**Validation:**
- Configuration syntax check: `named-checkconf`
- Zone file validation: `named-checkzone`
- Service restart and status verification

#### 📄 `dns_firewall_enable.sh`
- Opens port 53 TCP (DNS queries)
- Opens port 53 UDP (DNS queries)
- Enables external DNS resolution

#### 📄 `dns_firewall_disable.sh`
- Removes DNS firewall rules
- Closes port 53

---

### 3️⃣ Server Binding & Resolver Automation

**Directory:** `Server_Binding/`

#### 📄 `binding_setup.sh`

**The core integration script** that ties everything together:

**Phase 1: Automatic Backups**
Creates timestamped backups of:
- `/etc/bind/named.conf.local` → `/root/backups/`
- `/etc/bind/named.conf.options` → `/root/backups/`
- `/etc/resolv.conf` → `/etc/resolv.conf.backup`
- `/etc/wsl.conf` → `/etc/wsl.conf.backup`

**Phase 2: BIND Configuration Update**

Updates `named.conf.local` with:
```conf
zone "mywebapp.com" {
    type master;
    file "/var/named/mywebapp.com.fzone";
    allow-query { any; };
};
```

Updates `named.conf.options` with:
```conf
options {
    directory "/var/cache/bind";
    forwarders {
        8.8.8.8;
        8.8.4.4;
    };
    dnssec-validation auto;
    listen-on { any; };
    listen-on-v6 { any; };
    allow-query { any; };
};
```

**Phase 3: WSL Resolver Override**

Disables WSL auto-resolver in `/etc/wsl.conf`:
```ini
[boot]
systemd=true

[network]
generateResolvConf=false
```

**Phase 4: Custom Nameserver Configuration**

Creates static `/etc/resolv.conf`:
```conf
# Custom DNS configuration - managed by binding_setup.sh
# WSL auto-generation disabled
nameserver 127.0.0.1
nameserver 8.8.8.8
```

Makes it immutable:
```bash
sudo chattr +i /etc/resolv.conf
```

**Phase 5: Service Restart & Validation**
- Restarts BIND9 service
- Verifies service status
- Tests DNS resolution with `dig`

**Phase 6: Verification Testing**

Tests multiple resolution methods:
```bash
dig @127.0.0.1 mywebapp.com
nslookup mywebapp.com 127.0.0.1
host mywebapp.com 127.0.0.1
```

**Output Includes:**
- ✅ Backup confirmation
- ✅ Configuration updates
- ✅ Service status
- ✅ DNS resolution results
- ✅ Next steps guide

---

## 🌍 DNS Mapping Implementation

### WSL Side (Linux)

After running all setup scripts:

1. **DNS Server Running**
   ```bash
   sudo systemctl status bind9
   ```

2. **Zone File Active**
   ```
   mywebapp.com → 172.16.0.10
   ```

3. **Local Resolution Working**
   ```bash
   dig @127.0.0.1 mywebapp.com
   # Returns: 172.16.0.10
   ```

### Windows Side (Network Adapter)

To enable browser access:

#### Steps:

1. Open **Control Panel**
   ```
   Control Panel → Network and Internet → Network Connections
   ```

2. Right-click your **active adapter** (e.g., Wi-Fi 2, Ethernet)

3. Select **Properties**

4. Select **Internet Protocol Version 4 (TCP/IPv4)**

5. Click **Properties**

6. Select **Use the following DNS server addresses:**
   ```
   Preferred DNS server: 172.16.0.10
   Alternate DNS server: 8.8.8.8
   ```

7. Click **OK** and **Close**

8. **Flush DNS cache** (PowerShell/CMD as Admin):
   ```cmd
   ipconfig /flushdns
   ```

#### Browser Test

Open browser and navigate to:
```
http://mywebapp.com
```

You should see the Apache default page or your custom index.html!

---

## 🔥 Firewall Configuration Summary

| Service        | Port     | Protocol | Rule Type |
|----------------|----------|----------|-----------|
| Apache HTTP    | 80       | TCP      | Allow     |
| Apache HTTPS   | 443      | TCP      | Allow     |
| DNS Queries    | 53       | TCP      | Allow     |
| DNS Queries    | 53       | UDP      | Allow     |

**Firewall Management:**
```bash
# View active rules
sudo ufw status verbose

# Enable all services
cd apache_server/ && sudo bash firewall_enable.sh
cd ../dns_server/ && sudo bash dns_firewall_enable.sh

# Disable all services
cd apache_server/ && sudo bash firewall_disable.sh
cd ../dns_server/ && sudo bash dns_firewall_disable.sh
```

---

## 🛠 Services & Technologies Used

| Technology | Purpose | Version |
|------------|---------|---------|
| **Apache2** | Web Server | 2.4.x |
| **BIND9** | DNS Server | 9.x |
| **UFW** | Firewall | Latest |
| **WSL2** | Linux Environment | Ubuntu 20.04+ |
| **systemd** | Service Management | Latest |
| **dig** | DNS Testing | Latest |
| **Bash** | Scripting | 4.x+ |

---

## 🧪 Testing & Verification

### Apache Server Test

```bash
# Check service status
sudo systemctl status apache2

# Test HTTP response
curl http://localhost
curl http://172.16.0.10

# Check port binding
sudo netstat -tlnp | grep :80
```

### DNS Server Test

```bash
# Check BIND9 status
sudo systemctl status bind9

# Verify configuration
sudo named-checkconf
sudo named-checkzone mywebapp.com /var/named/mywebapp.com.fzone

# Test DNS resolution
dig @127.0.0.1 mywebapp.com
nslookup mywebapp.com 127.0.0.1
host mywebapp.com 127.0.0.1

# Check DNS port
sudo netstat -ulnp | grep :53
```

### Integration Test

```bash
# From WSL
curl http://mywebapp.com

# From Windows Browser
http://mywebapp.com
```

---

## 🔄 Backup & Restore Strategy

### Automatic Backups

All scripts create backups before making changes:

**Backup Locations:**
- `/root/backups/` - Primary backup directory
- `/etc/*.backup` - In-place backups
- `/var/backups/` - System backup directory

**Backup Naming:**
```
original_filename.backup
original_filename.backup.YYYYMMDD_HHMMSS
```

### Manual Backup

```bash
# Create manual backup before changes
sudo cp /etc/resolv.conf /etc/resolv.conf.manual.backup
sudo cp /etc/wsl.conf /etc/wsl.conf.manual.backup
```

### Complete System Restore

```bash
# Manually restore from backups
sudo cp /root/backups/resolv.conf.backup /etc/resolv.conf
sudo cp /root/backups/wsl.conf.backup /etc/wsl.conf
sudo cp /root/backups/named.conf.local.backup /etc/bind/named.conf.local
sudo cp /root/backups/named.conf.options.backup /etc/bind/named.conf.options

# Restart services
sudo systemctl restart bind9

# Restart WSL (from Windows)
wsl --shutdown

# Verify restoration
cat /etc/resolv.conf
cat /etc/wsl.conf
```

### Restore Notes

Important considerations when restoring:
- All backups are preserved in `/root/backups/`
- Manual restoration gives you full control
- Remember to restart services after restoration
- WSL restart may be needed for resolver changes
```

---

## 📊 Project Workflow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Project Execution Flow                    │
└─────────────────────────────────────────────────────────────┘

    [1] Apache Setup
         │
         ├─> Install Apache2
         ├─> Configure Virtual Host
         ├─> Enable Service
         └─> Enable Firewall (80, 443)
         
    [2] DNS Server Setup
         │
         ├─> Install BIND9
         ├─> Create Zone File
         ├─> Configure named.conf
         ├─> Validate Configuration
         ├─> Enable Firewall (53)
         └─> Start BIND9 Service
         
    [3] Server Binding
         │
         ├─> Backup All Configs
         ├─> Update BIND Config
         ├─> Disable WSL Auto-resolver
         ├─> Set Custom Nameserver (127.0.0.1)
         ├─> Make resolv.conf Immutable
         ├─> Restart Services
         └─> Verify DNS Resolution
         
    [4] Windows Configuration
         │
         ├─> Set Network Adapter DNS
         ├─> Point to WSL IP (192.168.149.140)
         └─> Flush DNS Cache
         
    [5] Testing
         │
         ├─> Test: curl http://mywebapp.com (WSL)
         ├─> Test: Browser http://mywebapp.com (Windows)
         └─> Verify DNS: dig @127.0.0.1 mywebapp.com
```

---

## 🎯 Learning Outcomes

This project demonstrates:

### Infrastructure Skills
✅ **DNS Management**
- Zone file creation and management
- Forward DNS configuration
- A record mapping
- DNS validation and testing

✅ **Web Server Administration**
- Apache installation and configuration
- Virtual host setup
- Service management
- Port binding verification

✅ **Network Configuration**
- WSL networking
- Resolver behavior and override
- Network adapter DNS configuration
- Cross-platform networking (WSL ↔ Windows)

✅ **Security & Firewall**
- UFW rule management
- Port-based access control
- Service-specific firewall rules

✅ **Automation & Scripting**
- Bash scripting best practices
- Error handling
- Backup automation
- Service validation
- Colored output and user feedback

✅ **System Administration**
- systemd service management
- Configuration file management
- Backup and restore strategies
- Immutable file handling

---

## 🚀 Future Enhancements

### Phase 2 (Intermediate)
- [ ] Reverse DNS zone configuration
- [ ] Subdomain support (www, api, admin)
- [ ] SSL/TLS with Let's Encrypt
- [ ] Multiple virtual hosts
- [ ] DNS caching optimization
- [ ] Advanced firewall rules

### Phase 3 (Advanced)
- [ ] Docker containerization
- [ ] Docker Compose orchestration
- [ ] Automated testing suite
- [ ] CI/CD pipeline integration
- [ ] Monitoring with Prometheus/Grafana
- [ ] Logging with ELK stack
- [ ] High availability setup
- [ ] Load balancer integration

### Phase 4 (Enterprise)
- [ ] Multi-zone DNS support
- [ ] DNSSEC implementation
- [ ] GeoDNS configuration
- [ ] Anycast DNS
- [ ] Auto-scaling
- [ ] Disaster recovery automation
- [ ] Infrastructure as Code (Terraform)
- [ ] Kubernetes deployment

---

## 🐛 Troubleshooting

### Apache Issues

**Problem:** Apache fails to start
```bash
# Check error logs
sudo tail -f /var/log/apache2/error.log

# Check port conflicts
sudo netstat -tlnp | grep :80

# Verify configuration
sudo apache2ctl configtest
```

**Problem:** Cannot access via browser
```bash
# Verify Apache is running
sudo systemctl status apache2

# Check firewall
sudo ufw status

# Verify IP address
ip addr show eth0
```

### DNS Issues

**Problem:** DNS resolution fails
```bash
# Check BIND9 status
sudo systemctl status bind9

# Verify zone file
sudo named-checkzone mywebapp.com /var/named/mywebapp.com.fzone

# Check named logs
sudo tail -f /var/log/syslog | grep named

# Test direct query
dig @127.0.0.1 mywebapp.com
```

**Problem:** resolv.conf keeps resetting
```bash
# Check if immutable flag is set
lsattr /etc/resolv.conf

# Set immutable
sudo chattr +i /etc/resolv.conf

# Verify WSL config
cat /etc/wsl.conf
# Should show: generateResolvConf=false
```

### WSL Issues

**Problem:** DNS not working after WSL restart
```bash
# Verify resolv.conf
cat /etc/resolv.conf

# Restore from backup if needed
sudo cp /root/backups/resolv.conf.backup /etc/resolv.conf
sudo chattr +i /etc/resolv.conf

# Restart BIND9
sudo systemctl restart bind9
```

**Problem:** Cannot access from Windows browser
```bash
# Verify Windows DNS settings
ipconfig /all

# Flush Windows DNS cache
ipconfig /flushdns

# Verify WSL IP hasn't changed
ip addr show eth0
```

---

## 📝 Important Notes

### WSL Resolver Behavior
- WSL2 automatically generates `/etc/resolv.conf` on boot
- Our scripts disable this with `generateResolvConf=false`
- The immutable flag prevents accidental overwrites
- Revert script properly handles cleanup

### IP Address Stability
- WSL2 IP can change after restart
- For production, consider:
  - Static IP configuration
  - DNS update scripts
  - Windows hosts file update automation

### Security Considerations
- This is a **development/learning environment**
- For production:
  - Use proper SSL certificates
  - Implement access controls
  - Add rate limiting
  - Enable DNSSEC
  - Regular security updates

---

## 📚 References & Documentation

- [Apache Official Documentation](https://httpd.apache.org/docs/)
- [BIND9 Administrator Reference Manual](https://bind9.readthedocs.io/)
- [Ubuntu UFW Guide](https://help.ubuntu.com/community/UFW)
- [WSL Documentation](https://docs.microsoft.com/en-us/windows/wsl/)
- [DNS RFC 1035](https://www.ietf.org/rfc/rfc1035.txt)

---

## 👨‍💻 Author

**Pratham Kumar Uikey**

Infrastructure & DevOps Practice Project  
WSL + Windows Hybrid Networking Lab

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file in the root directory for details.

```
Copyright 2024 Pratham Kumar Uikey

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

---

## 🙏 Acknowledgments

This project was built as a comprehensive infrastructure practice exercise, demonstrating:
- Real-world service deployment
- Network configuration management
- DNS infrastructure
- Automation best practices
- Backup and recovery strategies

---

## 🔖 Version History

- **v1.0.0** (Current)
  - Complete Apache + DNS setup
  - Server binding automation
  - Automatic backup system
  - Comprehensive documentation

---
