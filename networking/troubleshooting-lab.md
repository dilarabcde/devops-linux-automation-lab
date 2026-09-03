# Linux Networking Troubleshooting Lab

## Objective

This lab focuses on understanding Linux networking fundamentals and troubleshooting connectivity problems systematically.

The lab covers:

- Network interfaces and IP addresses
- Loopback and localhost
- Routing and default gateways
- Connectivity testing with ping
- DNS resolution
- TCP ports and listening sockets
- Process, socket, and port relationships
- Bind addresses
- HTTP service testing with curl
- Systematic network troubleshooting

---

## 1. Network Interfaces and IP Addresses

Network interfaces and their IP addresses were inspected using:

```bash
ip addr
```

The lab container had an active `eth0` interface with an address similar to:

```text
172.17.0.2/16
```

`eth0` is the container's network interface used to communicate with the Docker network.

The system also has a loopback interface called `lo`.

The IPv4 loopback address is:

```text
127.0.0.1
```

`127.0.0.1` represents localhost.

An important distinction is that localhost is local to the current network environment. The Mac host and the Docker container therefore do not share the same localhost.

---

## 2. Routing and Default Gateway

The routing table was inspected with:

```bash
ip route
```

Example output:

```text
default via 172.17.0.1 dev eth0
172.17.0.0/16 dev eth0
```

The container address was:

```text
172.17.0.2
```

and the default gateway was:

```text
172.17.0.1
```

The default gateway is used when the system does not have a more specific route for a destination.

Simplified traffic flow:

```text
Container
172.17.0.2
    |
    v
Default Gateway
172.17.0.1
    |
    v
Docker / Host Networking
    |
    v
External Network
```

---

## 3. Connectivity Testing

Connectivity was tested in stages.

First, the default gateway:

```bash
ping -c 3 172.17.0.1
```

Then an external IP address:

```bash
ping -c 3 8.8.8.8
```

Finally, a domain name:

```bash
ping -c 3 google.com
```

These tests provide different information.

If the gateway cannot be reached, the problem may be related to the local network, interface, or routing configuration.

If the gateway works but an external IP cannot be reached, the problem may be related to external routing or connectivity.

If an external IP works but a domain name does not, DNS becomes a strong suspect.

A useful troubleshooting pattern is:

```text
Gateway fails
    |
    v
Investigate local networking / routing

Gateway works
External IP fails
    |
    v
Investigate external connectivity / routing

External IP works
Domain fails
    |
    v
Investigate DNS
```

---

## 4. DNS Resolution

DNS resolution was inspected using:

```bash
nslookup google.com
```

The result showed both the DNS server and the IP address returned for the domain.

DNS translates domain names into IP addresses and other DNS records.

Simplified flow:

```text
google.com
    |
    v
DNS Resolver
    |
    v
IP Address
```

DNS commonly uses port `53`.

A successful connection to an external IP does not prove that DNS is working. This is why IP connectivity and DNS resolution should be tested separately.

---

## 5. TCP Ports and Listening Sockets

Listening TCP sockets were inspected using:

```bash
ss -lnt
```

Options:

```text
-l = show listening sockets
-n = show numeric addresses and ports
-t = show TCP sockets
```

Initially there was no TCP service listening on port `8080`.

A listening port indicates that a server socket is waiting for incoming connections.

---

## 6. Process, Socket, and Port Relationship

A process is a running instance of a program.

Not every process uses the network.

For example:

```bash
sleep 300
```

creates a process but does not need to listen on a network port.

A network server typically follows this relationship:

```text
Application
    |
    v
Process
    |
    v
Socket
    |
    v
Bind Address + Port
    |
    v
LISTEN
    |
    v
Client Connection
```

A socket is an operating-system communication endpoint used by a process for network communication.

A port identifies a TCP or UDP endpoint on a host/network namespace.

Therefore:

```text
Process != Port
Process != IP
```

A running process does not automatically mean that the expected network port is listening.

---

## 7. Application Startup Failure

An HTTP server was initially started using:

```bash
python3 -m http.server 8080 &
```

but the command failed because Python was not installed:

```text
python3: command not found
```

The background command exited with:

```text
Exit 127
```

Exit code `127` commonly indicates that the shell could not find the requested command.

The failure chain was:

```text
python3 command requested
        |
        v
python3 not found
        |
        v
Application cannot start
        |
        v
Socket is not created
        |
        v
Port 8080 is not listening
```

This demonstrates an important troubleshooting principle:

If a port is not listening, first verify that the application expected to listen on that port is actually running.

A missing listening port does not automatically indicate a firewall or networking problem.

---

## 8. Starting the HTTP Server

Python was installed and verified:

```bash
apt update
apt install -y python3
python3 --version
```

The HTTP server was then started:

```bash
python3 -m http.server 8080 &
```

The `&` runs the process in the background.

After starting the server:

```bash
ss -lnt
```

showed:

```text
0.0.0.0:8080
```

in the `LISTEN` state.

This confirmed that:

```text
Python process is running
        |
        v
TCP socket exists
        |
        v
Port 8080 is bound
        |
        v
Socket is LISTENING
```

---

## 9. Bind Addresses

`0.0.0.0:8080` does not mean that the application's real IP address is `0.0.0.0`.

For a server socket, binding to:

```text
0.0.0.0
```

means that the service listens on the available IPv4 interfaces for that port.

In the lab this allowed access through addresses such as:

```text
127.0.0.1:8080
172.17.0.2:8080
```

By contrast:

```text
127.0.0.1
```

is the IPv4 loopback address.

A service bound only to:

```text
127.0.0.1:8080
```

accepts connections only through the loopback interface.

---

## 10. Testing HTTP with curl

`curl` was installed using:

```bash
apt install -y curl
```

The HTTP server was tested with:

```bash
curl http://127.0.0.1:8080
```

The server returned an HTML directory listing, confirming that the HTTP service was responding.

`ping` and `curl` test different things.

```text
ping
→ tests basic IP/ICMP reachability

curl
→ tests communication with an application/protocol such as HTTP
```

A host can respond to `ping` while its web application is unavailable.

Therefore successful ping results do not prove that an application is healthy.

---

## 11. Finding the Server Process

The Python server process was located using:

```bash
pgrep -a python3
```

Example:

```text
2995 python3 -m http.server 8080
```

The process was stopped using its PID:

```bash
kill 2995
```

When the server process stops, its listening socket is also removed.

This can be verified with:

```bash
pgrep -a python3
ss -lnt
```

---

## 12. Bind Address Troubleshooting Lab

The HTTP server was deliberately configured to listen only on localhost:

```bash
python3 -m http.server 8080 --bind 127.0.0.1 &
```

The listening socket was checked:

```bash
ss -lnt
```

The result showed:

```text
127.0.0.1:8080
```

The localhost request succeeded:

```bash
curl http://127.0.0.1:8080
```

However, accessing the same service through the container's `eth0` address failed:

```bash
curl http://172.17.0.2:8080
```

Example error:

```text
curl: (7) Failed to connect to 172.17.0.2 port 8080
```

At this point:

```text
Process running              -> YES
Port 8080 listening          -> YES
localhost:8080 reachable     -> YES
172.17.0.2:8080 reachable    -> NO
```

The problem was not that the application had stopped.

The application was listening only on:

```text
127.0.0.1:8080
```

and not on the container's `eth0` interface.

This demonstrates that asking only:

```text
"Is port 8080 open?"
```

is not enough.

A better troubleshooting question is:

```text
"Which address/interface is port 8080 bound to?"
```

---

## 13. Correcting the Bind Address

If the application needs to accept connections through the available IPv4 interfaces, it can be bound to:

```bash
python3 -m http.server 8080 --bind 0.0.0.0
```

The result can be verified with:

```bash
ss -lnt
```

Expected listening address:

```text
0.0.0.0:8080
```

The service can then be tested through both addresses:

```bash
curl http://127.0.0.1:8080
curl http://172.17.0.2:8080
```

---

## 14. Troubleshooting Workflow

When a network service is unreachable, troubleshoot systematically instead of immediately assuming that the firewall or network is broken.

A useful workflow is:

```text
Is the application process running?
        |
        v
Is the expected port listening?
        |
        v
Is it bound to the correct address/interface?
        |
        v
Is the local/default gateway reachable?
        |
        v
Is external IP connectivity working?
        |
        v
Is DNS resolution working?
        |
        v
Can the application respond to a real request?
```

Examples:

```text
Process not running
→ Investigate the application

Process running but expected port not listening
→ Investigate application configuration/startup

Port listening on wrong bind address
→ Investigate bind configuration

Correct address and port listening but unreachable
→ Investigate routing/firewall/network path

TCP connection succeeds but HTTP response is incorrect
→ Investigate application/HTTP layer
```

---

## Key Takeaways

- A process and a network port are not the same thing.
- Not every process uses the network.
- Server processes use sockets to communicate over the network.
- `ss -lnt` shows listening TCP sockets.
- A service can be running but still be unreachable.
- The bind address determines which local interfaces accept connections.
- `127.0.0.1` represents the local loopback interface.
- `0.0.0.0` can be used by a server to listen on available IPv4 interfaces.
- `ping` and `curl` test different layers of connectivity.
- Successful IP connectivity does not prove that DNS works.
- Successful ping does not prove that an application works.
- Troubleshooting should move systematically from the application/process toward sockets, addressing, routing, DNS, and application-level communication.
