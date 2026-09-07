# Exercise 05 - Network Diagnosis

## Scenario 1: Port 8080 already in use

### Check port 8080

Command:

```bash
sudo ss -tulpn | grep :8080
