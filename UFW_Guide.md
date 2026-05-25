# UFW (Uncomplicated Firewall) How-To Guide

## Installation

### Debian/Ubuntu
```bash
sudo apt update
sudo apt install ufw
```

### Fedora/RHEL
```bash
sudo dnf install ufw
```

## Basic Commands

### Enable/Disable Firewall
```bash
sudo ufw enable      # Start firewall at boot
sudo ufw disable     # Stop firewall
sudo ufw status      # Check status
sudo ufw status verbose  # Detailed status
```

### Reset
```bash
sudo ufw reset       # Reset to defaults (removes all rules)
```

## Allow Rules

### Allow by Port
```bash
sudo ufw allow 22           # Allow port 22 (SSH)
sudo ufw allow 80           # Allow port 80 (HTTP)
sudo ufw allow 443          # Allow port 443 (HTTPS)
```

### Allow by Service Name
```bash
sudo ufw allow ssh          # Allow SSH service
sudo ufw allow http         # Allow HTTP
sudo ufw allow https        # Allow HTTPS
```

### Allow Specific Protocol
```bash
sudo ufw allow 53/udp       # Allow DNS (UDP)
sudo ufw allow 5353/tcp     # Allow specific TCP port
```

### Allow from Specific IP
```bash
sudo ufw allow from 192.168.1.100        # Allow all traffic from IP
sudo ufw allow from 192.168.1.100 to any port 22  # Allow SSH from specific IP
```

### Allow IP Range
```bash
sudo ufw allow from 192.168.1.0/24       # Allow entire subnet
```

## Deny Rules

### Deny Ports/Services
```bash
sudo ufw deny 23            # Deny Telnet
sudo ufw deny http          # Deny HTTP service
```

### Deny from IP
```bash
sudo ufw deny from 192.168.1.50          # Deny all traffic from IP
sudo ufw deny from 192.168.1.50 to any port 22  # Deny SSH from IP
```

## Delete Rules

### Remove by Rule Number
```bash
sudo ufw status numbered    # List rules with numbers
sudo ufw delete 3           # Delete rule #3
```

### Remove by Rule Description
```bash
sudo ufw delete allow 80
sudo ufw delete deny from 192.168.1.50
```

## Default Policies

```bash
sudo ufw default deny incoming      # Deny all incoming (recommended)
sudo ufw default allow outgoing     # Allow all outgoing
sudo ufw default deny outgoing      # Deny all outgoing (restrictive)
```

## Common Setup Example

```bash
# Secure default policy
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow essential services
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https

# Enable firewall
sudo ufw enable

# Verify
sudo ufw status
```

## View/Manage Rules

```bash
sudo ufw show added              # Show newly added rules
sudo ufw show raw                # Show raw iptables output
sudo ufw app list                # List available applications
sudo ufw app info OpenSSH        # Info about specific app
```

## Advanced Options

### Logging
```bash
sudo ufw logging on              # Enable logging
#sudo ufw logging off             # Disable logging
sudo ufw logging medium          # Set log level (low, medium, high)
tail -f /var/log/ufw.log         # View firewall logs
```

### more Logging
```bash
# View firewall logs in real-time
sudo tail -f /var/log/ufw.log

# Filter for BLOCK events only
sudo grep "UFW BLOCK" /var/log/ufw.log | tail -20

# See what's being blocked with more detail
sudo journalctl -u ufw -f

# Check which ports your apps are trying to use
sudo netstat -tulpn | grep LISTEN

# Or with ss (modern alternative)
sudo ss -tulpn | grep LISTEN
```



### Rate Limiting
```bash
sudo ufw limit 22/tcp            # Limit SSH connections (prevents brute force)
sudo ufw limit from 192.168.1.100 port 22
```

### Reload Rules
```bash
sudo ufw reload                  # Reload rules without dropping connections
```

## Tips

- Always allow SSH before enabling firewall (avoid lockout)
- Use `sudo ufw status verbose` to verify rules before enabling
- Default deny incoming, allow outgoing is safest approach
- Use service names when possible (more readable than ports)
- Check `/etc/ufw/applications.d/` for pre-configured app profiles

## File Locations

```
/etc/ufw/ufw.conf               # Main config
/etc/ufw/before.rules           # Rules applied before user rules
/etc/ufw/after.rules            # Rules applied after user rules
/etc/ufw/applications.d/        # Application profiles
/var/log/ufw.log                # Firewall log file
```
