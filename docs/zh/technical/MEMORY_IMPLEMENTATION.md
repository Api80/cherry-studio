# Cherry Studio 记忆功能技术文档

> 面向 .NET 开发者的技术解析文档

## 目录

1. [概述](#概述)
2. [记忆功能实现原理](#记忆功能实现原理)
3. [向量数据库架构](#向量数据库架构)
4. [本地运行要求](#本地运行要求)
5. [权限和后台运行机制](#权限和后台运行机制)
6. [与.NET对比](#与net对比)

---

## 概述

Cherry Studio 是一个使用 **Electron + React + TypeScript** 构建的跨平台 AI 桌面应用。作为 .NET 开发者，你可以将其理解为类似于使用 WPF/Avalonia + C# 构建的桌面应用，但使用了 Web 技术栈。

**核心技术栈**:
- **前端**: React 19.2.0 (类似于 WPF 的 XAML 数据绑定)
- **后端**: Electron 主进程 (Node.js，类似于 .NET Core 后端服务)
- **数据持久化**: IndexedDB (浏览器端) + LibSQL (主进程端)
- **状态管理**: Redux Toolkit (类似于 MediatR + CQRS 模式)

---

## 记忆功能实现原理

### 1. 架构设计

Cherry Studio 的记忆功能采用了 **RAG (Retrieval-Augmented Generation)** 架构，类似于 .NET 中的向量搜索实现：

```
用户输入 → 向量化 (Embedding) → 向量搜索 → 召回相关记忆 → 注入到 AI 上下文
```

### 2. 核心组件

#### 2.1 MemoryService (主进程)

**文件位置**: `src/main/services/memory/MemoryService.ts`

这是记忆功能的核心服务，使用 **单例模式** (Singleton Pattern)：

```typescript
export class MemoryService {
  private static instance: MemoryService | null = null
  private db: Client | null = null  // LibSQL 数据库连接
  private embeddings: Embeddings | null = null  // Embedding 服务
  private config: MemoryConfig | null = null
  private static readonly UNIFIED_DIMENSION = 1536  // 向量维度
  private static readonly SIMILARITY_THRESHOLD = 0.85  // 相似度阈值

  public static getInstance(): MemoryService {
    if (!MemoryService.instance) {
      MemoryService.instance = new MemoryService()
    }
    return MemoryService.instance
  }
}
```

**对比 .NET**:
```csharp
// 类似于 .NET 中的单例服务
public class MemoryService 
{
    private static MemoryService _instance;
    private SqliteConnection _db;
    private IEmbeddingService _embeddings;
    
    public static MemoryService Instance => 
        _instance ??= new MemoryService();
}
```

#### 2.2 工作流程

1. **存储记忆** (`addMemory`)
   ```typescript
   // 1. 接收用户消息和AI回复
   // 2. 生成向量嵌入 (Embedding)
   const embedding = await this.embeddings.embedDocuments([content])
   
   // 3. 存储到向量数据库
   await this.db.execute({
     sql: `INSERT INTO memories (content, embedding, userId, agentId, ...) 
           VALUES (?, ?, ?, ?, ...)`,
     args: [content, JSON.stringify(embedding), userId, agentId, ...]
   })
   ```

2. **搜索记忆** (`searchMemories`)
   ```typescript
   // 1. 将查询文本向量化
   const queryEmbedding = await this.embeddings.embedQuery(query)
   
   // 2. 使用余弦相似度搜索
   // LibSQL 支持向量相似度计算
   const results = await this.vectorSearch(queryEmbedding, {
     limit: 10,
     threshold: 0.85,
     userId,
     agentId
   })
   ```

3. **注入上下文**
   - 搜索结果按相似度排序
   - Top-K 记忆注入到 AI 对话上下文
   - AI 基于历史记忆生成回复

---

## 向量数据库架构

### 1. 使用的数据库: LibSQL

**重要发现**: Cherry Studio **不需要单独安装向量数据库**！

项目使用的是 **LibSQL**，这是 SQLite 的一个 fork，支持向量操作：

```json
// package.json
{
  "dependencies": {
    "@libsql/client": "0.14.0",
    "@cherrystudio/embedjs-libsql": "0.1.31"
  }
}
```

### 2. LibSQL vs 传统向量数据库

| 特性 | LibSQL (Cherry Studio) | Milvus/Qdrant | .NET 类比 |
|-----|----------------------|---------------|----------|
| 安装 | **无需单独安装** | 需要独立服务 | SQLite vs SQL Server |
| 部署 | 嵌入式数据库文件 | 独立服务器 | LocalDB vs SQL Server |
| 存储位置 | 本地文件 `memories.db` | 独立数据库 | `.mdf` 文件 vs 数据库服务器 |
| 向量搜索 | 支持（内置） | 专业优化 | Entity Framework vs Dapper |

### 3. 数据存储位置

```typescript
// src/main/services/memory/MemoryService.ts
const memoryDbPath = path.join(DATA_PATH, 'Memory', 'memories.db')
```

**存储路径**:
- **Windows**: `%APPDATA%/CherryStudio/Data/Memory/memories.db`
- **macOS**: `~/Library/Application Support/CherryStudio/Data/Memory/memories.db`
- **Linux**: `~/.config/CherryStudio/Data/Memory/memories.db`

### 4. 数据库 Schema

```sql
-- memories 表结构
CREATE TABLE memories (
    id TEXT PRIMARY KEY,
    content TEXT NOT NULL,           -- 记忆内容
    embedding TEXT NOT NULL,         -- 向量嵌入 (JSON 格式)
    userId TEXT NOT NULL,            -- 用户ID
    agentId TEXT,                    -- 助手ID
    metadata TEXT,                   -- 元数据 (JSON)
    createdAt INTEGER NOT NULL,      -- 创建时间戳
    updatedAt INTEGER NOT NULL       -- 更新时间戳
);

-- 索引优化查询
CREATE INDEX idx_memories_userId ON memories(userId);
CREATE INDEX idx_memories_agentId ON memories(agentId);
```

### 5. Embedding (向量化) 提供商

Cherry Studio 支持多种 Embedding 模型：

```typescript
// src/main/knowledge/embedjs/embeddings/EmbeddingsFactory.ts
export class EmbeddingsFactory {
  static create(config: EmbeddingConfig): Embeddings {
    switch (config.provider) {
      case 'openai':
        return new OpenAIEmbeddings(config)
      case 'azure':
        return new AzureEmbeddings(config)
      case 'voyage':
        return new VoyageEmbeddings(config)
      case 'ollama':
        return new OllamaEmbeddings(config)
      // ... 更多提供商
    }
  }
}
```

**默认配置**:
- **模型**: `text-embedding-ada-002` (OpenAI)
- **维度**: 1536
- **相似度阈值**: 0.85

---

## 本地运行要求

### 1. 系统要求

```json
// package.json
{
  "engines": {
    "node": ">=22.0.0"
  },
  "packageManager": "pnpm@10.27.0"
}
```

**最小要求**:
- **Node.js**: 22.0.0 或更高版本
- **pnpm**: 10.27.0
- **操作系统**: Windows 10+, macOS 10.15+, Linux (主流发行版)

### 2. 是否需要单独安装向量数据库？

**答案: 不需要！** 🎉

Cherry Studio 使用 **嵌入式向量数据库 (LibSQL)**，类似于 .NET 中的 SQLite LocalDB：

```
.NET 类比:
- LibSQL ≈ SQLite / SQL Server LocalDB
- 嵌入式数据库，无需独立服务
- 数据存储在本地文件中
- 随应用启动而加载
```

### 3. 需要配置的内容

虽然不需要安装数据库，但需要配置 **Embedding API**：

**选项 1: 使用 OpenAI (推荐)**
```bash
# 在应用设置中配置
Provider: OpenAI
API Key: sk-xxx...
Model: text-embedding-ada-002
```

**选项 2: 使用本地 Ollama (离线方案)**
```bash
# 1. 安装 Ollama
curl https://ollama.ai/install.sh | sh

# 2. 下载 Embedding 模型
ollama pull nomic-embed-text

# 3. 在应用中配置
Provider: Ollama
Base URL: http://localhost:11434
Model: nomic-embed-text
```

**选项 3: 使用其他提供商**
- Azure OpenAI
- Google Vertex AI
- Cohere
- Voyage AI

### 4. 安装和运行步骤

```bash
# 1. 克隆仓库
git clone https://github.com/CherryHQ/cherry-studio.git
cd cherry-studio

# 2. 安装依赖
corepack enable
corepack prepare pnpm@10.27.0 --activate
pnpm install

# 3. 配置环境变量 (可选)
cp .env.example .env

# 4. 启动开发服务器
pnpm dev

# 5. 构建生产版本
pnpm build:win    # Windows
pnpm build:mac    # macOS
pnpm build:linux  # Linux
```

---

## 权限和后台运行机制

### 1. Electron 权限模型

Electron 应用由两个进程组成：

```
┌─────────────────────────────────────────┐
│         Electron 应用架构               │
├─────────────────────────────────────────┤
│  Main Process (主进程)                  │
│  - Node.js 运行时                       │
│  - 完整的系统权限                       │
│  - 文件系统访问                         │
│  - 网络访问                             │
│  - 数据库操作                           │
└─────────────────┬───────────────────────┘
                  │ IPC (进程间通信)
┌─────────────────┴───────────────────────┐
│  Renderer Process (渲染进程)            │
│  - Chromium 浏览器引擎                  │
│  - 沙盒化环境 (受限权限)               │
│  - React UI 界面                        │
│  - 通过 IPC 调用主进程                  │
└─────────────────────────────────────────┘
```

**与 .NET 对比**:
```
Electron Main Process    ≈  .NET Windows Service / WPF 主线程
Electron Renderer Process ≈  WPF UI 线程 / Blazor WebAssembly
IPC (进程间通信)          ≈  SignalR / gRPC / Named Pipes
```

### 2. 权限获取方式

#### 2.1 文件系统权限

```typescript
// src/main/services/FileStorage.ts
import fs from 'fs'
import path from 'path'

// 主进程拥有完整的文件系统访问权限
// 类似于 .NET 的 File.ReadAllText()
const content = fs.readFileSync(filePath, 'utf-8')
```

Electron 主进程默认拥有与 Node.js 相同的权限：
- **读写文件**: 完整的文件系统访问
- **网络请求**: 无限制的 HTTP/HTTPS 请求
- **系统调用**: 可以执行系统命令
- **数据库**: 可以访问本地数据库

#### 2.2 macOS 特殊权限

在 macOS 上，某些功能需要用户授权：

```typescript
// src/main/services/SelectionService.ts
// 监听全局文本选择需要辅助功能权限
import { systemPreferences } from 'electron'

const hasAccess = systemPreferences.isTrustedAccessibilityClient(true)
if (!hasAccess) {
  // 提示用户在系统偏好设置中授权
}
```

**需要的 macOS 权限**:
1. **辅助功能 (Accessibility)**: 用于全局文本选择
2. **屏幕录制**: 用于 OCR 功能
3. **文件和文件夹访问**: 访问用户文件

### 3. 后台运行机制

#### 3.1 系统托盘 (Tray)

Cherry Studio 使用系统托盘保持后台运行：

```typescript
// src/main/services/TrayService.ts
import { Tray, Menu } from 'electron'

class TrayService {
  private tray: Tray | null = null

  init() {
    this.tray = new Tray(iconPath)
    
    // 设置托盘菜单
    const contextMenu = Menu.buildFromTemplate([
      { label: '显示窗口', click: () => this.showWindow() },
      { label: '退出', click: () => app.quit() }
    ])
    
    this.tray.setContextMenu(contextMenu)
    
    // 防止窗口关闭时退出应用
    mainWindow.on('close', (event) => {
      if (!this.shouldQuit) {
        event.preventDefault()
        mainWindow.hide()  // 隐藏而不是关闭
      }
    })
  }
}
```

**与 .NET 对比**:
```csharp
// .NET WinForms / WPF 系统托盘
NotifyIcon trayIcon = new NotifyIcon();
trayIcon.Icon = new Icon("icon.ico");
trayIcon.Visible = true;

// 防止窗口关闭时退出
protected override void OnClosing(CancelEventArgs e) {
    e.Cancel = true;
    this.Hide();
}
```

#### 3.2 防止系统休眠

Cherry Studio 使用 **PowerMonitor** 监听系统事件：

```typescript
// src/main/services/PowerMonitorService.ts
import { powerMonitor } from 'electron'

class PowerMonitorService {
  init() {
    // 监听系统关机事件
    powerMonitor.on('shutdown', async () => {
      logger.info('系统即将关机，保存数据...')
      await this.saveAllData()
    })
    
    // 监听系统休眠
    powerMonitor.on('suspend', () => {
      logger.info('系统进入休眠')
    })
    
    // 监听系统唤醒
    powerMonitor.on('resume', () => {
      logger.info('系统唤醒，恢复连接')
    })
  }
}
```

**与 .NET 对比**:
```csharp
// .NET Windows Service
using Microsoft.Win32;

SystemEvents.PowerModeChanged += (sender, e) => {
    switch (e.Mode) {
        case PowerModes.Suspend:
            // 系统休眠
            break;
        case PowerModes.Resume:
            // 系统唤醒
            break;
    }
};
```

#### 3.3 自动启动

```typescript
// src/main/services/AppService.ts
import { app } from 'electron'

class AppService {
  setAutoLaunch(enable: boolean) {
    app.setLoginItemSettings({
      openAtLogin: enable,
      openAsHidden: true  // 启动时隐藏窗口
    })
  }
}
```

**实现机制**:
- **Windows**: 写入注册表 `HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run`
- **macOS**: 添加到 Login Items
- **Linux**: 创建 `.desktop` 文件到 `~/.config/autostart/`

### 4. 持续工作的关键点

Cherry Studio 如何在后台持续工作：

1. **不退出进程**: 关闭窗口时隐藏而不是退出
   ```typescript
   mainWindow.on('close', (event) => {
     event.preventDefault()
     mainWindow.hide()
   })
   ```

2. **系统托盘常驻**: 提供托盘图标和菜单

3. **监听系统事件**: 
   - 系统关机时保存数据
   - 系统休眠时暂停任务
   - 系统唤醒时恢复任务

4. **自动启动**: 系统启动时自动运行

5. **IPC 持久连接**: 主进程和渲染进程保持通信

---

## 与 .NET 对比

### 1. 技术栈映射

| 功能 | Cherry Studio (Electron) | .NET 等效方案 |
|-----|-------------------------|--------------|
| 桌面框架 | Electron | WPF / WinForms / Avalonia |
| UI 层 | React + TypeScript | XAML + C# / Blazor |
| 后台服务 | Node.js (主进程) | Windows Service / BackgroundService |
| 数据库 | LibSQL (嵌入式) | SQLite / LocalDB |
| 向量搜索 | LibSQL + embedjs | Milvus.Client / Pgvector |
| ORM | 原生 SQL | Entity Framework Core / Dapper |
| 状态管理 | Redux Toolkit | MediatR + CQRS |
| 依赖注入 | 单例模式 | Microsoft.Extensions.DependencyInjection |
| IPC 通信 | Electron IPC | Named Pipes / gRPC / SignalR |

### 2. 代码风格对比

#### 记忆存储

**Electron (TypeScript)**:
```typescript
class MemoryService {
  async addMemory(options: AddMemoryOptions): Promise<string> {
    const embedding = await this.embeddings.embedDocuments([content])
    
    await this.db.execute({
      sql: `INSERT INTO memories (content, embedding) VALUES (?, ?)`,
      args: [content, JSON.stringify(embedding)]
    })
    
    return id
  }
}
```

**.NET (C#)**:
```csharp
public class MemoryService 
{
    public async Task<string> AddMemoryAsync(AddMemoryOptions options)
    {
        var embedding = await _embeddingService.EmbedAsync(content);
        
        await _dbContext.Memories.AddAsync(new Memory 
        {
            Content = content,
            Embedding = JsonSerializer.Serialize(embedding)
        });
        
        await _dbContext.SaveChangesAsync();
        return id;
    }
}
```

#### IPC 通信

**Electron (TypeScript)**:
```typescript
// 主进程
ipcMain.handle('memory:add', async (event, options) => {
  return await memoryService.addMemory(options)
})

// 渲染进程
const result = await window.api.memory.add(options)
```

**.NET (C#)**:
```csharp
// gRPC 服务端
public override async Task<AddMemoryResponse> AddMemory(
    AddMemoryRequest request, ServerCallContext context)
{
    var id = await _memoryService.AddMemoryAsync(request);
    return new AddMemoryResponse { Id = id };
}

// 客户端
var response = await _client.AddMemoryAsync(request);
```

### 3. 性能对比

| 方面 | Electron | .NET |
|-----|----------|------|
| 启动速度 | 较慢 (Chromium 启动) | 快 |
| 内存占用 | 较高 (~150-300MB) | 较低 (~50-100MB) |
| CPU 使用 | 中等 | 低到中等 |
| 跨平台 | 优秀 (一次编写，到处运行) | 良好 (需要针对不同平台调整) |
| UI 开发速度 | 快 (Web 技术栈) | 中等 (XAML 学习曲线) |
| 生态系统 | npm (~2M+ 包) | NuGet (~300K+ 包) |

---

## 总结

### 关键点回答

**1. 记忆功能如何实现？**
- 使用 **RAG (检索增强生成)** 架构
- 对话内容 → 向量化 (Embedding) → 存储到向量数据库
- 查询时使用向量相似度搜索召回相关记忆
- 将记忆注入到 AI 上下文中生成回复

**2. 是否需要单独安装向量数据库？**
- **不需要！** 使用嵌入式数据库 **LibSQL**
- 类似于 .NET 中的 SQLite，无需独立服务
- 数据存储在本地文件 `memories.db` 中
- 但需要配置 **Embedding API** (OpenAI / Ollama 等)

**3. 如何获取电脑权限并持续工作？**
- **权限**: Electron 主进程默认拥有完整系统权限
- **特殊权限**: macOS 需要用户授权辅助功能
- **后台运行**: 
  - 系统托盘常驻
  - 关闭窗口时隐藏而不退出
  - 监听系统休眠/唤醒事件
  - 支持开机自动启动

### 快速开始

```bash
# 1. 安装依赖
pnpm install

# 2. 启动开发
pnpm dev

# 3. 配置 Embedding (在应用设置中)
Provider: OpenAI / Ollama
API Key: your-key
```

### 进一步学习

- **Electron 文档**: https://www.electronjs.org/docs
- **RAG 架构**: https://docs.llamaindex.ai/en/stable/
- **向量数据库**: https://github.com/tursodatabase/libsql
- **embedjs 库**: https://github.com/llm-tools/embedjs

---

**文档作者**: Cherry Studio 技术团队  
**最后更新**: 2026-01-31  
**适用版本**: v1.7.15+
