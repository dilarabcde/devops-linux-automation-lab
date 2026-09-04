# Day 5 — Final Linux & Networking Troubleshooting Lab

## Objective

The goal of this lab is to practice a structured troubleshooting workflow for a web service.

Instead of randomly trying commands, the system is checked layer by layer:

```text
Process
  ↓
Socket
  ↓
IP Address + Port
  ↓
Application Response
  ↓
External Network Access
```

---

## Scenario 1 — Application Process Is Not Running

### Problem

A Python HTTP server is expected to run on port `8080`, but the application is unreachable.

### Step 1 — Check the Process

```bash
ps aux
```

or:

```bash
pgrep -a python3
```

If no Python process exists, the application is not running.

### Step 2 — Check Listening Ports

```bash
ss -lnt
```

If there is no `8080` listener, this confirms that the service is not listening on the expected port.

### Step 3 — Start the Application

```bash
python3 -m http.server 8080 --bind 0.0.0.0 &
```

Explanation:

- `8080` is the application port.
- `--bind 0.0.0.0` makes the server listen on all IPv4 interfaces.
- `&` runs the process in the background.

### Step 4 — Verify the Listener

```bash
ss -lnt
```

Expected result:

```text
LISTEN ... 0.0.0.0:8080
```

### Step 5 — Verify the HTTP Response

```bash
curl http://127.0.0.1:8080
```

If HTML content is returned, the application is responding successfully inside the container.

---

## Scenario 2 — Application Is Running on the Wrong Port

### Expected State

The application should run on:

```text
8080
```

### Actual Process

```bash
pgrep -a python3
```

Example output:

```text
39 python3 -m http.server 9090 --bind 0.0.0.0
```

The process is running, but it is configured to use port `9090`.

### Verify the Listening Port

```bash
ss -lnt
```

Example output:

```text
LISTEN ... 0.0.0.0:9090
```

### Diagnosis

```text
Expected port: 8080
Actual port:   9090
```

The application is running, but on the wrong port.

### Fix

Stop the old process:

```bash
kill 39
```

Start the server on the correct port:

```bash
python3 -m http.server 8080 --bind 0.0.0.0 > /tmp/webserver.log 2>&1 &
```

### Verify the Fix

```bash
ss -lnt
```

Expected:

```text
LISTEN ... 0.0.0.0:8080
```

Then verify the application response:

```bash
curl http://127.0.0.1:8080
```

---

## Scenario 3 — Process Starts but Immediately Crashes

A service can appear to start but terminate immediately.

Example application:

```python
print("Application starting...")
raise RuntimeError("Database configuration missing")
```

Start it in the background and redirect output to a log file:

```bash
python3 /tmp/app.py > /tmp/app.log 2>&1 &
```

The shell reports:

```text
exit 1
```

### Meaning of Exit Code 1

A non-zero exit code usually means that the process terminated with an error.

In this case, instead of investigating networking first, the next step is to inspect the application logs.

### Read the Logs

```bash
cat /tmp/app.log
```

Example error:

```text
RuntimeError: Database configuration missing
```

### Diagnosis

The application failed during startup because required configuration was missing.

Possible real-world causes include:

- Missing environment variables
- Missing database connection string
- Missing secrets
- Invalid application configuration
- Missing dependency

### Key Lesson

If the application process is not alive, troubleshooting DNS, ports, or firewalls is usually premature.

First determine why the application failed.

---

## Scenario 4 — Application Works Inside the Container but Not from the Host

Inside the container:

```bash
curl http://127.0.0.1:8080
```

works successfully.

However, on the host machine:

```bash
curl http://localhost:8080
```

fails.

### Important Concept

The host and the container have different network namespaces.

```text
Container localhost → container itself

Host localhost → host machine itself
```

A service running inside a Docker container is not automatically exposed to the host.

### Docker Port Publishing

The container must be created with port publishing:

```bash
docker run -it -p 8080:8080 ubuntu bash
```

Meaning:

```text
Host port 8080
       ↓
Container port 8080
```

Then traffic can flow like this:

```text
Host localhost:8080
        ↓
Docker port mapping
        ↓
Container port 8080
        ↓
Application
```

---

## Bind Address

### Loopback Only

```text
127.0.0.1:8080
```

This means the application accepts connections only from its own local network namespace.

### All IPv4 Interfaces

```text
0.0.0.0:8080
```

This means the application listens on all available IPv4 interfaces.

Important:

`0.0.0.0` does not mean that the application is automatically reachable from everywhere.

Firewall rules, routing, Docker port publishing, or cloud security rules can still block access.

---

## Core Troubleshooting Workflow

When an application is unreachable:

### 1. Is the process running?

```bash
pgrep -a <process>
```

or:

```bash
ps aux
```

If the process is missing, investigate why it stopped.

---

### 2. Is the expected port listening?

```bash
ss -lnt
```

Check:

- Expected port
- Bind address
- LISTEN state

---

### 3. Is the application responding locally?

```bash
curl http://127.0.0.1:PORT
```

A listening port does not automatically prove that the application is healthy.

---

### 4. Does external access work?

If local access works but external access fails, investigate the network path.

Possible causes:

- Docker port publishing
- Firewall
- Routing
- NAT
- Cloud security groups
- Kubernetes Service or Ingress configuration

---

### 5. If the process crashes, inspect logs

```bash
cat /path/to/log
```

Logs often contain the actual root cause.

---

## Commands Used

### Process Inspection

```bash
ps aux
pgrep -a python3
pkill python3
kill <PID>
```

### Network Inspection

```bash
ss -lnt
```

### HTTP Testing

```bash
curl http://127.0.0.1:8080
curl http://localhost:8080
```

### Application Logs

```bash
cat /tmp/app.log
```

### Python HTTP Server

```bash
python3 -m http.server 8080 --bind 0.0.0.0 &
```

### Docker Port Publishing

```bash
docker run -it -p 8080:8080 ubuntu bash
```

---

## Mental Model

```text
Program
  ↓
Process
  ↓
Socket
  ↓
Bind Address + Port
  ↓
LISTEN
  ↓
Network Path
  ↓
Client Connection
  ↓
Application Response
```

A useful troubleshooting principle is:

```text
Do not guess the cause.

Verify each layer and eliminate possibilities one by one.
```

---

## Final Takeaways

After this lab, the following troubleshooting patterns should be clear:

- If the process does not exist, investigate the application and logs.
- If the process exists but the expected port is not listening, inspect configuration.
- If the wrong port is listening, correct the application port.
- If the wrong bind address is used, correct the interface binding.
- If the port is listening but the application does not respond, investigate the application layer.
- If the application works locally but not externally, investigate the network path.
- Exit codes and logs provide critical information when processes fail.
- A successful fix should always be verified after the change.
