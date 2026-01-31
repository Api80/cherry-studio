# Cherry Studio 技术文档索引

本目录包含 Cherry Studio 的深度技术文档，面向开发者和高级用户。

## 📚 文档导航

### 1. 记忆功能实现原理

**文件**: [MEMORY_IMPLEMENTATION.md](./MEMORY_IMPLEMENTATION.md)  
**适合**: .NET 开发者、想了解 RAG 架构的开发者

**内容概要**:
- ✅ 记忆功能的 RAG 架构设计
- ✅ LibSQL 嵌入式向量数据库
- ✅ 本地运行要求和配置
- ✅ 权限和后台运行机制
- ✅ 与 .NET 技术栈的详细对比

**关键问题回答**:
1. 记忆功能如何实现？
2. 是否需要单独安装向量数据库？
3. 如何获取电脑权限并持续工作？

---

### 2. Embedding 算法与 .NET 实现

**文件**: [EMBEDDING_ALGORITHMS_AND_DOTNET.md](./EMBEDDING_ALGORITHMS_AND_DOTNET.md)  
**适合**: 想了解本地 Embedding 方案的开发者

**内容概要**:
- ✅ 本地 Embedding 算法详解
- ✅ Ollama 本地 Embedding 使用指南
- ✅ ONNX Runtime 完全离线方案
- ✅ .NET 重构完整实现方案
- ✅ Electron vs .NET 优缺点对比
- ✅ 70+ 种 Embedding 模型介绍

**关键问题回答**:
1. 向量化是否只能通过 OpenAI API？
2. 有什么算法可以直接计算向量？
3. 如何用 .NET 实现 Cherry Studio？

---

### 3. Ollama vs ONNX Runtime 对比

**文件**: [OLLAMA_VS_ONNX.md](./OLLAMA_VS_ONNX.md)  
**适合**: 想选择本地 Embedding 方案的用户

**内容概要**:
- ✅ Ollama 和 ONNX Runtime 的定义
- ✅ 详细的特性对比表格
- ✅ 安装配置难度对比
- ✅ 性能和资源占用分析
- ✅ 适用场景指南
- ✅ 代码量对比（0 行 vs 200+ 行）
- ✅ 开发和维护成本分析

**快速结论**:
- ✅ 推荐使用 **Ollama**（适合 90% 场景）
- ⚠️ 仅在特殊情况使用 ONNX Runtime

---

## 🎯 快速查找

### 我想了解...

#### "记忆功能是怎么工作的？"
→ 查看 [MEMORY_IMPLEMENTATION.md](./MEMORY_IMPLEMENTATION.md)

#### "如何使用本地 Embedding，不想用 OpenAI？"
→ 查看 [EMBEDDING_ALGORITHMS_AND_DOTNET.md](./EMBEDDING_ALGORITHMS_AND_DOTNET.md) 第 2-3 节

#### "Ollama 和 ONNX Runtime 哪个好？"
→ 查看 [OLLAMA_VS_ONNX.md](./OLLAMA_VS_ONNX.md)

#### "如何用 .NET 重写 Cherry Studio？"
→ 查看 [EMBEDDING_ALGORITHMS_AND_DOTNET.md](./EMBEDDING_ALGORITHMS_AND_DOTNET.md) 第 4 节

#### "是否需要安装向量数据库？"
→ 不需要！查看 [MEMORY_IMPLEMENTATION.md](./MEMORY_IMPLEMENTATION.md) 第 3 节

---

## 📖 推荐阅读顺序

### 对于普通用户

1. **首先**: [OLLAMA_VS_ONNX.md](./OLLAMA_VS_ONNX.md) - 了解本地方案
2. **然后**: [MEMORY_IMPLEMENTATION.md](./MEMORY_IMPLEMENTATION.md) - 了解工作原理

### 对于 .NET 开发者

1. **首先**: [MEMORY_IMPLEMENTATION.md](./MEMORY_IMPLEMENTATION.md) - 了解架构
2. **然后**: [EMBEDDING_ALGORITHMS_AND_DOTNET.md](./EMBEDDING_ALGORITHMS_AND_DOTNET.md) - .NET 实现方案
3. **最后**: [OLLAMA_VS_ONNX.md](./OLLAMA_VS_ONNX.md) - 技术选型

### 对于 AI 工程师

1. **首先**: [EMBEDDING_ALGORITHMS_AND_DOTNET.md](./EMBEDDING_ALGORITHMS_AND_DOTNET.md) - 算法和实现
2. **然后**: [OLLAMA_VS_ONNX.md](./OLLAMA_VS_ONNX.md) - 方案对比
3. **最后**: [MEMORY_IMPLEMENTATION.md](./MEMORY_IMPLEMENTATION.md) - 系统架构

---

## 🔧 快速配置指南

### 使用 Ollama 本地 Embedding（推荐）

```bash
# 1. 安装 Ollama
# Windows: 下载 https://ollama.ai/download
# macOS: brew install ollama
# Linux: curl https://ollama.ai/install.sh | sh

# 2. 启动服务
ollama serve

# 3. 下载模型（选择一个）
ollama pull nomic-embed-text        # 英文，274MB
ollama pull bge-large-zh-v1.5       # 中文，1.3GB
ollama pull bge-m3                  # 多语言，2.2GB

# 4. 在 Cherry Studio 中配置
# 设置 → 记忆设置 → Embedding 提供商
# Provider: Ollama
# Base URL: http://localhost:11434
# Model: nomic-embed-text（或其他模型）
```

### 文档位置

所有文档都在：`docs/zh/technical/`

```
docs/zh/technical/
├── README.md                              # 📍 当前文件（索引）
├── MEMORY_IMPLEMENTATION.md               # 记忆功能实现
├── EMBEDDING_ALGORITHMS_AND_DOTNET.md    # Embedding 和 .NET
└── OLLAMA_VS_ONNX.md                     # 方案对比
```

---

## 💡 常见问题

### Q: 文档在哪里？找不到文件

**A**: 文档在 `docs/zh/technical/` 目录下。如果你克隆了仓库，可以直接在本地查看。如果在 GitHub 上，点击上面的链接即可。

### Q: 我应该读哪个文档？

**A**: 
- 只想用功能 → [OLLAMA_VS_ONNX.md](./OLLAMA_VS_ONNX.md)
- 想了解原理 → [MEMORY_IMPLEMENTATION.md](./MEMORY_IMPLEMENTATION.md)
- 想自己开发 → [EMBEDDING_ALGORITHMS_AND_DOTNET.md](./EMBEDDING_ALGORITHMS_AND_DOTNET.md)

### Q: 为什么推荐 Ollama？

**A**: 
- ✅ 零代码集成（Cherry Studio 已内置）
- ✅ 免费无限使用
- ✅ 质量接近 OpenAI（80-90%）
- ✅ 完全本地，数据隐私
- ✅ 易于维护和升级

详见：[OLLAMA_VS_ONNX.md](./OLLAMA_VS_ONNX.md)

---

## 📞 获取帮助

- 📖 **技术文档**: 本目录下的 Markdown 文件
- 💬 **社区讨论**: [GitHub Discussions](https://github.com/CherryHQ/cherry-studio/discussions)
- 🐛 **问题反馈**: [GitHub Issues](https://github.com/CherryHQ/cherry-studio/issues)
- 📧 **联系开发者**: kangfenmao (WeChat)

---

**最后更新**: 2026-01-31  
**维护者**: Cherry Studio 技术团队
