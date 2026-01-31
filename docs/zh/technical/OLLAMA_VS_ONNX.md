# Ollama vs ONNX Runtime 对比指南

> 本地 Embedding 方案选择指南

## 快速对比

| 特性 | Ollama | ONNX Runtime |
|-----|--------|--------------|
| **安装难度** | ⭐ 非常简单 | ⭐⭐⭐ 复杂 |
| **使用难度** | ⭐ 一键启动 | ⭐⭐⭐⭐ 需要编程 |
| **模型管理** | ✅ 自动下载和管理 | ❌ 手动下载和配置 |
| **模型切换** | ✅ 一条命令 | ❌ 需要重新配置 |
| **内存占用** | 2-4GB | 1-3GB |
| **启动速度** | 快（秒级） | 非常快（毫秒级） |
| **性能** | 优秀 | 优秀 |
| **集成方式** | HTTP API | 库调用 |
| **Cherry Studio支持** | ✅ 已内置 | ❌ 需要自己实现 |

---

## 什么是 Ollama？

### 定义

**Ollama** 是一个开源的本地 AI 模型运行工具，类似于 "AI 模型的 Docker"。它简化了大语言模型和 Embedding 模型的本地部署。

### 特点

```
Ollama = 模型管理器 + 模型运行器 + HTTP API 服务器
```

- 📦 **模型仓库**: 预配置了 70+ 个优化的模型
- 🚀 **一键启动**: 无需复杂配置
- 🔄 **自动管理**: 自动下载、更新、卸载模型
- 🌐 **HTTP API**: 提供标准的 RESTful 接口
- 🔧 **开箱即用**: 无需编写代码即可使用

### 使用示例

```bash
# 1. 安装 Ollama（一次性）
# Windows: 下载安装器
# macOS: brew install ollama
# Linux: curl https://ollama.ai/install.sh | sh

# 2. 启动服务
ollama serve

# 3. 下载模型
ollama pull nomic-embed-text

# 4. 直接使用（通过 HTTP API）
curl http://localhost:11434/api/embeddings -d '{
  "model": "nomic-embed-text",
  "prompt": "我喜欢编程"
}'

# 返回结果
{
  "embedding": [0.23, -0.45, 0.67, ..., 0.12]
}
```

### Cherry Studio 中的使用

Cherry Studio **已经内置了 Ollama 支持**，配置非常简单：

```
设置 → 记忆设置 → Embedding 提供商
├─ Provider: Ollama
├─ Base URL: http://localhost:11434
└─ Model: nomic-embed-text
```

**无需写代码**，只需配置即可使用！

---

## 什么是 ONNX Runtime？

### 定义

**ONNX Runtime** 是微软开发的跨平台机器学习推理引擎。它是一个底层的 **C++ 库**，需要程序员自己编写代码来加载和运行模型。

### 特点

```
ONNX Runtime = 底层推理引擎
```

- 🔧 **底层库**: 需要编程集成
- ⚡ **极致性能**: 优化到极致的推理速度
- 💾 **轻量级**: 库本身体积小
- 🌍 **跨平台**: 支持多种语言（C++, Python, C#, Java）
- 🎛️ **完全控制**: 可以精细控制每个细节

### 使用示例

#### C# 示例

```csharp
using Microsoft.ML.OnnxRuntime;
using Microsoft.ML.OnnxRuntime.Tensors;

public class OnnxEmbeddingService
{
    private InferenceSession _session;
    private BertTokenizer _tokenizer;
    
    public OnnxEmbeddingService()
    {
        // 1. 手动加载模型文件（需要自己下载）
        _session = new InferenceSession("models/bge-large-zh.onnx");
        
        // 2. 手动加载 tokenizer（需要自己配置）
        _tokenizer = new BertTokenizer("models/vocab.txt");
    }
    
    public float[] GetEmbedding(string text)
    {
        // 3. 手动 tokenize
        var tokens = _tokenizer.Encode(text);
        var inputIds = tokens.InputIds;
        
        // 4. 创建输入张量
        var inputTensor = new DenseTensor<long>(
            inputIds.ToArray(), 
            new[] { 1, inputIds.Count }
        );
        
        // 5. 创建输入
        var inputs = new List<NamedOnnxValue>
        {
            NamedOnnxValue.CreateFromTensor("input_ids", inputTensor)
        };
        
        // 6. 运行推理
        using var results = _session.Run(inputs);
        var outputTensor = results[0].AsTensor<float>();
        
        // 7. 手动处理输出（mean pooling）
        return ProcessOutput(outputTensor);
    }
    
    private float[] ProcessOutput(Tensor<float> output)
    {
        // 需要自己实现 mean pooling 算法
        // ...
    }
}
```

#### Python 示例

```python
import onnxruntime as ort
import numpy as np

# 1. 手动加载模型
session = ort.InferenceSession("models/bge-large-zh.onnx")

# 2. 准备输入
inputs = {
    "input_ids": np.array([[101, 2769, 3221, ...]]),
    "attention_mask": np.array([[1, 1, 1, ...]])
}

# 3. 运行推理
outputs = session.run(None, inputs)

# 4. 手动处理输出
embedding = outputs[0].mean(axis=1)
```

---

## 详细对比

### 1. 安装和配置

#### Ollama

```bash
# 总共 3 步，5 分钟完成
1. 下载安装器 → 双击安装
2. ollama serve
3. ollama pull nomic-embed-text
```

**难度**: ⭐ (非常简单)

#### ONNX Runtime

```bash
# 需要多个步骤
1. 安装 ONNX Runtime 库
   - C#: Install-Package Microsoft.ML.OnnxRuntime
   - Python: pip install onnxruntime

2. 下载 ONNX 模型文件（需要找到正确的模型）
   - 从 HuggingFace 或其他源下载
   - 可能需要转换 PyTorch/TensorFlow 模型

3. 下载 tokenizer 文件
   - vocab.txt
   - tokenizer_config.json
   - special_tokens_map.json

4. 编写代码集成
   - 实现 tokenization
   - 实现 mean pooling
   - 处理 padding/truncation

5. 调试和优化
```

**难度**: ⭐⭐⭐⭐ (复杂)

### 2. 模型管理

#### Ollama

```bash
# 列出可用模型
ollama list

# 下载新模型
ollama pull bge-m3

# 切换模型（配置文件改一下即可）
Provider: Ollama
Model: bge-m3  # 改这里

# 删除模型
ollama rm bge-m3

# 查看模型信息
ollama show nomic-embed-text
```

**优势**: 
- ✅ 中心化管理
- ✅ 版本控制
- ✅ 一键切换

#### ONNX Runtime

```bash
# 需要手动管理
models/
├── nomic-embed-text/
│   ├── model.onnx
│   ├── vocab.txt
│   └── config.json
├── bge-m3/
│   ├── model.onnx
│   ├── vocab.txt
│   └── config.json
└── bge-large-zh/
    ├── model.onnx
    └── ...
```

**劣势**:
- ❌ 手动下载
- ❌ 手动配置
- ❌ 需要重写代码切换模型

### 3. 使用方式

#### Ollama - HTTP API

```typescript
// Cherry Studio 中的实现（已内置）
const response = await fetch('http://localhost:11434/api/embeddings', {
  method: 'POST',
  body: JSON.stringify({
    model: 'nomic-embed-text',
    prompt: text
  })
});

const { embedding } = await response.json();
```

**优势**:
- ✅ 语言无关（任何语言都可以调用 HTTP API）
- ✅ 进程隔离（Ollama 崩溃不影响应用）
- ✅ 易于集成

#### ONNX Runtime - 库调用

```csharp
// 需要自己实现
public class MyEmbeddingService
{
    private InferenceSession _session;
    
    // 需要实现 tokenization
    // 需要实现 tensor 创建
    // 需要实现 output 处理
    // ...
}
```

**劣势**:
- ❌ 需要编程能力
- ❌ 语言绑定（C# 代码不能直接在其他语言使用）
- ❌ 紧耦合（模型加载在应用进程内）

### 4. 性能对比

#### 启动时间

```
Ollama:
- 首次启动: 2-3 秒
- 后续请求: 100-200ms

ONNX Runtime:
- 模型加载: 500ms-2s（首次）
- 推理: 50-100ms
```

**结论**: ONNX Runtime 稍快，但差距不大

#### 内存占用

```
Ollama:
- 进程本身: ~500MB
- 加载模型: 1.5-3GB
- 总计: 2-4GB

ONNX Runtime:
- 库本身: ~50MB
- 加载模型: 1-2.5GB
- 总计: 1-3GB
```

**结论**: ONNX Runtime 稍低，节省 500MB-1GB

#### 推理速度

```
两者使用相同的优化技术:
- 量化（Quantization）
- 图优化（Graph Optimization）
- 算子融合（Operator Fusion）

实际速度: 几乎相同（差异 <10%）
```

**结论**: 性能相当

---

## 适用场景

### 选择 Ollama 的场景

✅ **推荐使用 Ollama**（适合 90% 的用户）

**场景 1: 普通开发者**
- 你只是想用 Embedding 功能
- 不想深入学习 AI 模型细节
- 希望快速集成

**场景 2: 原型开发**
- 快速验证想法
- 需要频繁切换模型
- 追求开发效率

**场景 3: 多语言项目**
- 使用多种编程语言
- 希望统一的 API 接口
- 微服务架构

**场景 4: 团队协作**
- 团队成员技能水平不同
- 需要降低学习成本
- 统一开发环境

**场景 5: Cherry Studio 用户**
- 已内置支持，开箱即用
- 无需写任何代码
- 配置即可使用

### 选择 ONNX Runtime 的场景

⚠️ **仅在特殊情况使用**（适合 <10% 的用户）

**场景 1: 嵌入式应用**
- 需要将模型打包到应用内
- 完全离线环境（无法运行独立服务）
- 移动端应用（iOS/Android）

**场景 2: 极致性能优化**
- 需要榨取每一点性能
- 节省 500MB 内存很重要
- 高并发场景（每毫秒都很重要）

**场景 3: 特殊模型**
- 使用自定义训练的模型
- Ollama 不支持的模型格式
- 需要特殊的前后处理

**场景 4: 有经验的 AI 工程师**
- 熟悉 ONNX 生态
- 有模型优化经验
- 愿意投入时间调优

---

## 实战对比

### 实现相同功能的代码量

#### Ollama 方式

```typescript
// Cherry Studio 中的配置（0 行代码）
// 只需在设置中填写:
Provider: Ollama
Base URL: http://localhost:11434
Model: nomic-embed-text

// 如果要自己调用（10 行代码）
const getEmbedding = async (text) => {
  const response = await fetch('http://localhost:11434/api/embeddings', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ model: 'nomic-embed-text', prompt: text })
  });
  const { embedding } = await response.json();
  return embedding;
};
```

**代码量**: 0-10 行

#### ONNX Runtime 方式

```csharp
// C# 实现（需要 200+ 行代码）
public class OnnxEmbeddingService
{
    private InferenceSession _session;
    private Dictionary<string, int> _vocab;
    
    // 1. 加载模型（30 行）
    public void LoadModel(string modelPath) { ... }
    
    // 2. 加载词汇表（20 行）
    private void LoadVocab(string vocabPath) { ... }
    
    // 3. Tokenize（50 行）
    private (long[] inputIds, long[] attentionMask) Tokenize(string text) { ... }
    
    // 4. 创建张量（30 行）
    private NamedOnnxValue CreateTensor(long[] data, string name) { ... }
    
    // 5. 推理（20 行）
    private float[] Inference(long[] inputIds, long[] attentionMask) { ... }
    
    // 6. Mean Pooling（30 行）
    private float[] MeanPooling(float[,] output, long[] attentionMask) { ... }
    
    // 7. Normalize（20 行）
    private float[] Normalize(float[] vector) { ... }
    
    // 主接口
    public float[] GetEmbedding(string text)
    {
        var (inputIds, attentionMask) = Tokenize(text);
        var output = Inference(inputIds, attentionMask);
        var pooled = MeanPooling(output, attentionMask);
        return Normalize(pooled);
    }
}
```

**代码量**: 200+ 行

**对比结果**: Ollama 方式代码量减少 **95%**

---

## 成本对比

### 开发成本

| 阶段 | Ollama | ONNX Runtime |
|-----|--------|--------------|
| 学习 | 1 小时 | 1-2 天 |
| 集成 | 30 分钟 | 2-5 天 |
| 测试 | 1 小时 | 1-2 天 |
| 优化 | 可选 | 必须 |
| **总计** | **半天** | **1-2 周** |

### 维护成本

| 项目 | Ollama | ONNX Runtime |
|-----|--------|--------------|
| 模型更新 | 一条命令 | 重新下载+测试 |
| 切换模型 | 改配置 | 重写代码 |
| Bug 修复 | 社区支持 | 自己解决 |
| 依赖更新 | 自动 | 手动 |

---

## 最佳实践建议

### 推荐方案（95% 场景）

```
使用 Ollama + Cherry Studio
└─ 理由:
   ✅ 零代码集成
   ✅ 快速上手
   ✅ 易于维护
   ✅ 性能足够好
   ✅ 免费无限使用
```

### 使用步骤

```bash
# 1. 安装 Ollama
# 访问 https://ollama.ai 下载

# 2. 启动服务
ollama serve

# 3. 下载推荐模型
# 英文:
ollama pull nomic-embed-text

# 中文:
ollama pull bge-large-zh-v1.5

# 多语言:
ollama pull bge-m3

# 4. 在 Cherry Studio 中配置
# 设置 → 记忆 → Embedding 提供商 → Ollama
```

### 高级场景（5% 场景）

```
使用 ONNX Runtime
└─ 条件:
   1. 必须完全离线（无法运行 Ollama 服务）
   2. 移动端应用（iOS/Android）
   3. 嵌入式设备
   4. 有专业 AI 工程师
   
└─ 准备工作:
   - 预算 1-2 周开发时间
   - 学习 ONNX 和 Transformer 模型
   - 准备调试和优化
```

---

## 常见问题 FAQ

### Q1: Ollama 是否需要联网？

**答**: 
- 下载模型时需要联网（一次性）
- 运行时完全离线，无需网络

### Q2: ONNX Runtime 比 Ollama 快多少？

**答**: 
- 推理速度几乎相同（差异 <10%）
- 启动速度 ONNX 更快（快约 100ms）
- 但开发效率 Ollama 高 10 倍以上

### Q3: 可以先用 Ollama，以后换 ONNX 吗？

**答**: 
- ✅ 可以！
- 两者生成的向量是相同的（使用相同模型）
- 迁移成本低，数据可以复用

### Q4: Cherry Studio 为什么选择 Ollama？

**答**:
- ✅ 用户体验好（零配置）
- ✅ 降低使用门槛
- ✅ 易于维护和升级
- ✅ 社区生态活跃

### Q5: 我应该选哪个？

**答**:
```
决策树:

你在用 Cherry Studio 吗？
├─ 是 → 使用 Ollama（已内置）
└─ 否 → 你需要完全离线吗？
    ├─ 是 → 考虑 ONNX Runtime
    └─ 否 → 使用 Ollama
```

**90% 的情况下，选择 Ollama！**

---

## 总结

### 一句话总结

- **Ollama**: "傻瓜式"本地 AI 工具，开箱即用 ⭐⭐⭐⭐⭐
- **ONNX Runtime**: 底层推理库，需要编程集成 ⭐⭐

### 核心区别

| 角度 | Ollama | ONNX Runtime |
|-----|--------|--------------|
| 定位 | 应用程序 | 开发库 |
| 类比 | Docker | gcc/g++ |
| 用户 | 终端用户 + 开发者 | 开发者 |
| 使用 | 命令行 + HTTP API | 编程接口 |
| 学习曲线 | ⭐ | ⭐⭐⭐⭐ |

### 推荐建议

```
🎯 对于 Cherry Studio 用户:
→ 直接使用 Ollama，已内置支持

🎯 对于新项目:
→ 优先选择 Ollama，除非有特殊需求

🎯 对于有经验的 AI 工程师:
→ 可以尝试 ONNX Runtime 获得更多控制
```

---

## 相关文档

- 📄 [Embedding 算法与 .NET 实现方案](./EMBEDDING_ALGORITHMS_AND_DOTNET.md) - 完整技术文档
- 📄 [记忆功能实现原理](./MEMORY_IMPLEMENTATION.md) - RAG 架构详解
- 🌐 [Ollama 官网](https://ollama.ai) - 下载和文档
- 🌐 [ONNX Runtime 官网](https://onnxruntime.ai) - 开发文档

---

**文档作者**: Cherry Studio 技术团队  
**最后更新**: 2026-01-31  
**适用版本**: v1.7.15+
