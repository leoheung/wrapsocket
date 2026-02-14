# WarpSocket

A **production-grade, high-availability, auto-recovery, dual-end** WebSocket toolkit.

**Go Server + TypeScript Client** — Solving all WebSocket pain points in one package.

## Why WarpSocket?

Building reliable WebSocket applications is hard. You need to handle reconnections, heartbeats, message acknowledgments, and more. WarpSocket provides a complete solution with:

- **Go Server** — Robust, concurrent-safe WebSocket server with connection management
- **TypeScript Client** — Auto-reconnecting client with seamless recovery for browser & Node.js

## Core Features

| Feature                     | Description                                              |
| --------------------------- | -------------------------------------------------------- |
| 🔄 **Auto Reconnection**    | Exponential backoff strategy (1s → 2s → 4s → 8s...)      |
| 💓 **Heartbeat Keep-Alive** | Automatic ping/pong with connection health monitoring    |
| ✅ **Message ACK**          | Reliable message delivery with acknowledgment mechanism  |
| 💾 **Message Persistence**  | Optional message caching and queue for offline scenarios |
| 🔁 **Auto Retry**           | Automatic resend for unacknowledged messages             |
| 🔌 **Full-Duplex Protocol** | Unified message protocol for both ends                   |
| 🛡️ **Middleware System**    | Interceptors for logging, authentication, and more       |
| 📡 **Event-Driven**         | Clean event-based API for all connection states          |
| 🔒 **Type-Safe**            | Full TypeScript + Go type definitions                    |

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        WarpSocket                           │
├─────────────────────────┬───────────────────────────────────┤
│      Go Server          │         TypeScript Client         │
├─────────────────────────┼───────────────────────────────────┤
│ • Connection Manager    │ • Auto Reconnection               │
│ • Lifecycle Hooks       │ • Network Status Detection        │
│ • Heartbeat Detection   │ • Background/Foreground Recovery  │
│ • Concurrent-Safe Write │ • Message Queue & Retry           │
│ • Broadcast/Unicast     │ • State Management                │
│ • Room/Channel Support  │ • Event-Driven API                │
│ • Middleware System     │ • TypeScript Type Safety          │
└─────────────────────────┴───────────────────────────────────┘
```

## Unified Protocol

Both Go server and TypeScript client share the same message format:

```json
{
  "type": "event | ack | heartbeat",
  "id": "uuid",
  "data": {},
  "timestamp": 1700000000000
}
```

## Roadmap

### Phase 1: Core Foundation

**Go Server**

- [x] WebSocket connection manager
- [x] Connection lifecycle hooks (OnOpen/OnClose/OnError)
- [x] Automatic heartbeat (Ping/Pong)
- [x] Concurrent-safe write operations
- [x] Broadcast / Unicast / Group send
- [x] Automatic resource cleanup on disconnect

**TypeScript Client**

- [x] Exponential backoff auto-reconnection
- [x] Network status detection (`navigator.onLine`)
- [x] Background/foreground recovery
- [x] Manual/auto reconnection control
- [x] Automatic heartbeat maintenance
- [x] State machine: `connecting` → `open` → `disconnected` → `reconnecting`

### Phase 2: High Availability

**Go Server**

- [ ] Message ACK confirmation
- [ ] Unacknowledged message timeout handling
- [ ] Connection rate limiting
- [ ] Idle connection eviction
- [ ] Middleware system (logging, interceptors, auth)

**TypeScript Client**

- [ ] Message send queue (offline caching)
- [ ] Auto-send pending messages on reconnect
- [ ] Message deduplication (idempotency)
- [ ] Timeout retry mechanism
- [ ] Manual/auto ACK
- [ ] State restoration after reconnect

### Phase 3: Production-Ready

**Go Server**

- [ ] Distributed support (Redis pub/sub)
- [ ] Room/Channel system
- [ ] Connection metrics & monitoring
- [ ] Security validation (Origin check, Token auth)
- [ ] Graceful shutdown

**TypeScript Client**

- [ ] Max reconnection attempts
- [ ] Network change detection (WiFi/5G switch)
- [ ] Custom reconnection conditions
- [ ] Custom encoding/decoding (Protobuf support)
- [ ] Node.js + Browser dual environment

**Tooling**

- [ ] Unified error codes
- [ ] Debug mode
- [ ] Performance statistics
- [ ] Reconnection success rate metrics

### Phase 4: Advanced Features

- [ ] State sync after reconnection
- [ ] Message compression
- [ ] Binary message support
- [ ] Flow control
- [ ] Custom retry strategies
- [ ] Distributed message sync
- [ ] Connection state animations
- [ ] Isomorphic TS-Go protocol definitions

### Phase 5: Enterprise Features

**Security**

- [ ] TLS/SSL support (WSS)
- [ ] JWT token authentication & auto-refresh
- [ ] Message encryption (AES-256)
- [ ] Message signature verification
- [ ] IP whitelist/blacklist

**Performance**

- [ ] Backpressure control
- [ ] Message batching
- [ ] Connection pooling
- [ ] Zero-copy optimization

**Developer Experience**

- [ ] Browser DevTools extension
- [ ] CLI testing tool
- [ ] Mock server for frontend development
- [ ] React/Vue hooks

**Observability**

- [ ] Prometheus metrics export
- [ ] OpenTelemetry integration
- [ ] Health check HTTP endpoint
- [ ] Slow message alerts

**Protocol**

- [ ] Message priority queue
- [ ] Large file transfer (chunked)
- [ ] Message TTL expiration
- [ ] Request-Response (RPC) pattern

**Cluster**

- [ ] Session persistence (Redis)
- [ ] Service discovery (Consul/etcd)
- [ ] Load balancer awareness

## Installation

### Go Server

```bash
go get github.com/leoheung/wrapsocket/go-patterns
```

### TypeScript Client

```bash
npm install wrapsocket-ts
# or
yarn add wrapsocket-ts
# or
pnpm add wrapsocket-ts
```

## Project Structure

```
wrapsocket/
├── go-patterns/          # Go server implementation
│   ├── net/              # Network utilities
│   ├── parallel/         # Concurrency patterns
│   ├── container/        # Data structures
│   └── utils/            # Helper functions
├── wrapsocket-ts/        # TypeScript client implementation
└── README.md
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/leoheung">leoheung</a>
</p>
