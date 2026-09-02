## System Health Check Script

The `scripts/health-check.sh` script performs basic Linux system health checks.

It monitors:

- Disk usage
- Available memory
- Process availability

The script uses threshold-based checks and returns an exit code that can be used by automation and CI/CD systems.

### Exit Codes

- `0` - All health checks passed
- `1` - One or more health checks failed

### Run

```bash
./scripts/health-check.sh
```
