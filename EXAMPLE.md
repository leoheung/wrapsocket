# WrapSocket Example Usage

WrapSocket 是一個生產級別的 WebSocket 解決方案，提供自動重連、心跳檢測和狀態管理功能。本文檔展示如何使用 Go (Chi Framework) 後端和 TypeScript 前端進行整合。

## 目錄

- [後端 (Go + Chi)](#後端-go--chi)
- [前端 (TypeScript)](#前端-typescript)
- [運行示例](#運行示例)

---

## 後端 (Go + Chi)

### 安裝依賴

```bash
go get github.com/go-chi/chi/v5
go get github.com/coder/websocket
go get github.com/leoheung/go-patterns/net/wrapsocket
```

### 完整示例代碼

```go
package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/coder/websocket"
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	wrapsocket "github.com/leoheung/go-patterns/net/wrapsocket"
)

func main() {
	r := chi.NewRouter()
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)
	r.Use(corsMiddleware)

	handler := wrapsocket.NewDefaultHandler(nil)

	handler.SetHeartbeatConfig(&wrapsocket.HeartbeatConfig{
		Interval:  15 * time.Second,
		Timeout:   5 * time.Second,
		MaxMissed: 3,
	})

	handler.SetOnConnect(func(conn *wrapsocket.Conn) {
		log.Printf("[Server] Client connected: %s", conn.ID)
		conn.SetMetadata("joinedAt", time.Now())
	})

	handler.SetOnDisconnect(func(conn *wrapsocket.Conn) {
		log.Printf("[Server] Client disconnected: %s", conn.ID)
	})

	handler.SetOnMessage(func(conn *wrapsocket.Conn, msg *wrapsocket.Message) {
		log.Printf("[Server] Message from %s: %s", conn.ID, string(msg.Data))
	})

	handler.SetOnError(func(conn *wrapsocket.Conn, err error) {
		log.Printf("[Server] Error from %s: %v", conn.ID, err)
	})

	r.Get("/ws", handler.ServeHTTP)

	r.Get("/broadcast", func(w http.ResponseWriter, r *http.Request) {
		msg := r.URL.Query().Get("msg")
		if msg == "" {
			http.Error(w, "msg parameter required", http.StatusBadRequest)
			return
		}
		err := handler.Manager().Broadcast(r.Context(), websocket.MessageText, []byte(msg))
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		fmt.Fprintf(w, "Broadcast to %d connections\n", handler.Manager().Count())
	})

	r.Get("/stats", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Active connections: %d\n", handler.Manager().Count())
	})

	r.Get("/send/{connID}", func(w http.ResponseWriter, r *http.Request) {
		connID := chi.URLParam(r, "connID")
		msg := r.URL.Query().Get("msg")
		if msg == "" {
			http.Error(w, "msg parameter required", http.StatusBadRequest)
			return
		}
		err := handler.Manager().SendTo(r.Context(), connID, websocket.MessageText, []byte(msg))
		if err != nil {
			http.Error(w, err.Error(), http.StatusNotFound)
			return
		}
		fmt.Fprintf(w, "Message sent to %s\n", connID)
	})

	log.Printf("[Server] Starting on :3001")
	log.Fatal(http.ListenAndServe(":3001", r))
}

func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}
		next.ServeHTTP(w, r)
	})
}
```

---

### API 文檔

#### 1. WebSocket 連接端點

| 屬性      | 值                                    |
| --------- | ------------------------------------- |
| **Route** | `GET /ws`                             |
| **語義**  | 建立 WebSocket 連接，用於實時雙向通信 |

**連接參數**

無需額外參數，使用標準 WebSocket 握手協議。

**連接成功後行為**

- 服務器自動分配唯一連接 ID
- 啟用心跳檢測（可配置）
- 連接加入管理器進行統一管理

**消息格式**

```json
{
  "type": "event|ack|heartbeat|pong",
  "id": "uuid-string",
  "data": "any data",
  "timestamp": 1700000000000
}
```

**心跳消息**

客戶端發送：

```json
{
  "type": "heartbeat",
  "id": "uuid",
  "data": "ping",
  "timestamp": 1700000000000
}
```

服務器響應：

```json
{
  "type": "pong",
  "id": "uuid",
  "data": "pong",
  "timestamp": 1700000000000
}
```

---

#### 2. 廣播消息

| 屬性      | 值                           |
| --------- | ---------------------------- |
| **Route** | `GET /broadcast`             |
| **語義**  | 向所有已連接的客戶端廣播消息 |

**Query Parameters**

| 參數  | 類型   | 必填 | 說明             |
| ----- | ------ | ---- | ---------------- |
| `msg` | string | 是   | 要廣播的消息內容 |

**Response**

成功響應 (200):

```
Broadcast to 5 connections
```

錯誤響應 (400):

```
msg parameter required
```

**cURL 示例**

```bash
curl "http://localhost:3001/broadcast?msg=Hello%20Everyone"
```

**TypeScript 調用示例**

```typescript
async function broadcastMessage(message: string): Promise<void> {
  const response = await fetch(
    `http://localhost:3001/broadcast?msg=${encodeURIComponent(message)}`,
  );
  const text = await response.text();
  console.log(text);
}

broadcastMessage("Hello Everyone");
```

**Go 調用示例**

```go
package main

import (
	"fmt"
	"io"
	"net/http"
	"net/url"
)

func broadcastMessage(message string) error {
	baseURL := "http://localhost:3001/broadcast"
	params := url.Values{}
	params.Add("msg", message)
	fullURL := fmt.Sprintf("%s?%s", baseURL, params.Encode())

	resp, err := http.Get(fullURL)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)
	fmt.Println(string(body))
	return nil
}
```

---

#### 3. 獲取連接統計

| 屬性      | 值                                |
| --------- | --------------------------------- |
| **Route** | `GET /stats`                      |
| **語義**  | 獲取當前活躍的 WebSocket 連接數量 |

**Query Parameters**

無

**Response**

成功響應 (200):

```
Active connections: 5
```

**cURL 示例**

```bash
curl "http://localhost:3001/stats"
```

**TypeScript 調用示例**

```typescript
async function getStats(): Promise<string> {
  const response = await fetch("http://localhost:3001/stats");
  return await response.text();
}

getStats().then(console.log);
```

**Go 調用示例**

```go
func getStats() (string, error) {
	resp, err := http.Get("http://localhost:3001/stats")
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)
	return string(body), nil
}
```

---

#### 4. 發送消息到指定連接

| 屬性      | 值                         |
| --------- | -------------------------- |
| **Route** | `GET /send/{connID}`       |
| **語義**  | 向指定的客戶端連接發送消息 |

**URL Parameters**

| 參數     | 類型   | 必填 | 說明              |
| -------- | ------ | ---- | ----------------- |
| `connID` | string | 是   | 目標連接的唯一 ID |

**Query Parameters**

| 參數  | 類型   | 必填 | 說明             |
| ----- | ------ | ---- | ---------------- |
| `msg` | string | 是   | 要發送的消息內容 |

**Response**

成功響應 (200):

```
Message sent to abc123-uuid
```

錯誤響應 (400):

```
msg parameter required
```

錯誤響應 (404):

```
connection not found: abc123-uuid
```

**cURL 示例**

```bash
curl "http://localhost:3001/send/abc123-uuid?msg=Hello"
```

**TypeScript 調用示例**

```typescript
async function sendToConnection(
  connId: string,
  message: string,
): Promise<void> {
  const response = await fetch(
    `http://localhost:3001/send/${connId}?msg=${encodeURIComponent(message)}`,
  );
  const text = await response.text();
  console.log(text);
}

sendToConnection("abc123-uuid", "Hello");
```

**Go 調用示例**

```go
func sendToConnection(connID, message string) error {
	baseURL := fmt.Sprintf("http://localhost:3001/send/%s", connID)
	params := url.Values{}
	params.Add("msg", message)
	fullURL := fmt.Sprintf("%s?%s", baseURL, params.Encode())

	resp, err := http.Get(fullURL)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)
	fmt.Println(string(body))
	return nil
}
```

---

## 前端 (TypeScript)

### 安裝

```bash
npm install wrapsocket-ts
```

或直接使用打包文件：

```html
<script type="module">
  import { WrapSocket } from "./path/to/wrapsocket.js";
</script>
```

### 完整示例代碼

```typescript
import { WrapSocket, type ConnectionState } from "wrapsocket-ts";

const ws = new WrapSocket({
  url: "ws://localhost:3001/ws",
  debug: true,
  reconnect: {
    enabled: true,
    maxAttempts: 10,
    initialDelay: 1000,
    maxDelay: 30000,
    backoffFactor: 2,
  },
  heartbeat: {
    enabled: true,
    interval: 15000,
    timeout: 5000,
  },
});

ws.on("stateChange", (state: ConnectionState, previous: ConnectionState) => {
  console.log(`State changed: ${previous} -> ${state}`);
});

ws.on("open", () => {
  console.log("Connected to server");
});

ws.on("close", (event: CloseEvent) => {
  console.log(`Connection closed: code=${event.code}, reason=${event.reason}`);
});

ws.on("error", (event: Event) => {
  console.error("WebSocket error:", event);
});

ws.on("message", (event: MessageEvent) => {
  console.log("Received:", event.data);
});

ws.on("reconnecting", (attempt: number, delay: number) => {
  console.log(`Reconnecting in ${delay}ms (attempt ${attempt})`);
});

ws.on("reconnectFailed", (attempt: number) => {
  console.error(`Reconnect failed after ${attempt} attempts`);
});

ws.on("online", () => {
  console.log("Network online");
});

ws.on("offline", () => {
  console.log("Network offline");
});

ws.on("visibilityChange", (visible: boolean) => {
  console.log(`Visibility: ${visible ? "visible" : "hidden"}`);
});

ws.connect();

function sendMessage(data: string | object) {
  if (ws.isConnected) {
    ws.send(data);
  }
}

function disconnect() {
  ws.disconnect();
}

function reconnect() {
  ws.reconnect();
}

function destroy() {
  ws.destroy();
}
```

### 配置選項

#### WrapSocketOptions

| 屬性        | 類型               | 必填 | 默認值  | 說明                 |
| ----------- | ------------------ | ---- | ------- | -------------------- |
| `url`       | string             | 是   | -       | WebSocket 服務器 URL |
| `protocols` | string \| string[] | 否   | -       | WebSocket 子協議     |
| `debug`     | boolean            | 否   | `false` | 是否啟用調試日誌     |
| `reconnect` | ReconnectOptions   | 否   | 見下表  | 重連配置             |
| `heartbeat` | HeartbeatOptions   | 否   | 見下表  | 心跳配置             |

#### ReconnectOptions

| 屬性            | 類型    | 默認值     | 說明              |
| --------------- | ------- | ---------- | ----------------- |
| `enabled`       | boolean | `true`     | 是否啟用自動重連  |
| `maxAttempts`   | number  | `Infinity` | 最大重連次數      |
| `initialDelay`  | number  | `1000`     | 初始重連延遲 (ms) |
| `maxDelay`      | number  | `30000`    | 最大重連延遲 (ms) |
| `backoffFactor` | number  | `2`        | 指數退避因子      |

#### HeartbeatOptions

| 屬性       | 類型    | 默認值  | 說明          |
| ---------- | ------- | ------- | ------------- |
| `enabled`  | boolean | `true`  | 是否啟用心跳  |
| `interval` | number  | `30000` | 心跳間隔 (ms) |
| `timeout`  | number  | `10000` | 心跳超時 (ms) |

### 事件列表

| 事件               | 參數                     | 說明           |
| ------------------ | ------------------------ | -------------- |
| `open`             | `(event: Event)`         | 連接成功       |
| `close`            | `(event: CloseEvent)`    | 連接關閉       |
| `error`            | `(event: Event)`         | 連接錯誤       |
| `message`          | `(event: MessageEvent)`  | 收到消息       |
| `stateChange`      | `(state, previousState)` | 狀態變化       |
| `reconnecting`     | `(attempt, delay)`       | 正在重連       |
| `reconnectFailed`  | `(attempt)`              | 重連失敗       |
| `online`           | -                        | 網絡恢復       |
| `offline`          | -                        | 網絡斷開       |
| `visibilityChange` | `(visible)`              | 頁面可見性變化 |

### 連接狀態

```typescript
type ConnectionState =
  | "connecting" // 正在連接
  | "open" // 已連接
  | "disconnected" // 已斷開
  | "reconnecting"; // 正在重連
```

---

## 運行示例

### 1. 啟動後端服務器

```bash
cd example
go mod tidy
go run main.go
```

服務器將在 `http://localhost:3001` 啟動。

### 2. 訪問前端頁面

在瀏覽器中打開 `http://localhost:3001`，即可看到測試頁面。

### 3. 測試功能

- 點擊 **Connect** 按鈕建立連接
- 在輸入框輸入消息並點擊 **Send** 發送
- 點擊 **Disconnect** 斷開連接
- 點擊 **Reconnect** 重新連接

### 4. 測試廣播功能

```bash
# 向所有連接廣播消息
curl "http://localhost:3001/broadcast?msg=Hello%20World"

# 查看連接統計
curl "http://localhost:3001/stats"
```
