# Secure-Firewall-Configuration-for-Server-Protection

The project aims to implement a robust iptables firewall configuration to enhance server security by regulating incoming and outgoing network traffic. The firewall will be configured with a deny-by-default policy, allowing only essential services while blocking unauthorized access attempts. Key features include the allowance of HTTP versions 1.1, 2, and 3, secure SSH access with fail2ban protection, utilization of sshttp for SSH/HTTP(S) multiplexing on port 443, and proper logging of internet-facing traffic. Additionally, flood protection mechanisms will be implemented to mitigate potential denial-of-service (DoS) attacks, ensuring the stability and reliability of the server under high traffic conditions.

## 1. Policy: Deny by Default
- Configure iptables firewall to deny all incoming and outgoing traffic by default.

## 2. Services Allowed as a Server (IN):
- Allow HTTP versions 1.1, 2, and 3.
- Allow SSH with fail2ban protection and asymmetric key login.
- Configure sshttp for SSH/HTTP(S) multiplexing on port 443.
- Allow ICMP ping.

## 3. Services Allowed as a Client (OUT):
- Allow DNS and DNS over TLS.
- Allow ICMP ping.
- Allow SSH, git, docker, whois, HTTP, and HTTPS.

## 4. Additional Requirements:
- **Logging:**
  - Log all traffic related to services exposed to the Internet (IN).
  - Log and reject all invalid packets (IN and OUT).
- **Flood Protection:**
  - Implement flood protection for incoming connections (IN).
  - Prevent ICMP packet flood exceeding 5 per second.
  - Prevent UDP packet flood exceeding 10 per second, with a tolerance of 50.
  - Prevent TCP packet flood exceeding 50 per second, with a tolerance of 100.
  - Make an exception for SSH service to TCP flood protection.

