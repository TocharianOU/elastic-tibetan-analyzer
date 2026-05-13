# Elasticsearch 藏文分词插件

**语言选择:** [English](./README.md) | [中文版](#elasticsearch-藏文分词插件)

---

基于词典的藏文分词器插件，支持 Elasticsearch 8.x 和 9.x，采用最长匹配算法。

## 特性

- ✅ 词典分词（65,000+ 词条）
- ✅ 最长匹配算法
- ✅ 藏文语法后缀处理
- ✅ 自定义词典支持
- ✅ Elasticsearch 8.x/9.x stable plugin 打包
- ✅ Docker 测试环境

## Docker 快速开始

最快的测试方式：

```bash
# 启动 Elasticsearch + Kibana + 藏文分词器
docker-compose up -d

# 等待服务就绪（约30秒）
docker-compose ps

# 测试分词
curl -X POST "http://localhost:9200/_analyze" -H 'Content-Type: application/json' -d '{
  "analyzer": "tibetan_analyzer",
  "text": "ང་ཚོས་སློབ་གྲྭར་འགྲོ་དགོས།"
}'

# 访问 Kibana Dev Tools
# http://localhost:5601/app/dev_tools#/console

# 停止服务
docker-compose down
```

**默认数据**：启动服务时，会自动创建以下索引：
- **tibetan_docs**: 5 条简单演示文档（问候语和常用短语）
- **tibetan_qa**: 2000 条综合问答（历史、文化、地理等）
- **tibetan_medical_qa**: 239 条传统藏医知识问答

所有数据在首次启动时自动导入 - 无需额外步骤！

## 📖 文档

完整文档位于 `docs/` 目录：

- **[快速开始指南](./docs/quick-start.md)** - 5分钟设置
- **[查询示例](./docs/query-examples.md)** ⭐ - 可直接使用的 Kibana 查询
- **[分词器使用](./docs/analyzer-usage.md)** - 分词器工作原理
- **[API 参考](./docs/api-reference.md)** - 完整 API 文档

**新用户：** 从[快速开始指南](./docs/quick-start.md)开始，然后在 Kibana Dev Tools 中尝试[查询示例](./docs/query-examples.md)！

### 快速搜索示例

```bash
# 统计各索引文档数
curl "http://localhost:9200/tibetan_docs/_count"        # 5 条
curl "http://localhost:9200/tibetan_qa/_count"          # 2000 条
curl "http://localhost:9200/tibetan_medical_qa/_count"  # 239 条

# 搜索综合问答
curl -X POST "http://localhost:9200/tibetan_qa/_search" -H 'Content-Type: application/json' -d '{
  "query": {"match": {"question": "ལོ་རྒྱུས"}},
  "size": 5
}'

# 搜索藏医问答
curl -X POST "http://localhost:9200/tibetan_medical_qa/_search" -H 'Content-Type: application/json' -d '{
  "query": {"match": {"question": "སྙིང་གཟེར"}},
  "size": 3
}'

# 多字段搜索
curl -X POST "http://localhost:9200/tibetan_qa/_search" -H 'Content-Type: application/json' -d '{
  "query": {
    "multi_match": {
      "query": "བོད་ཀྱི་ལོ་རྒྱུས",
      "fields": ["title", "content", "question", "answer"]
    }
  },
  "size": 10
}'
```

## 样本数据

所有测试数据已预生成并包含在 `docker/` 目录中：

| 文件 | 大小 | 记录数 | 说明 | 索引名称 |
|------|------|--------|------|----------|
| `docker/sample-data.json` | 1.3KB | 5 | 演示问候语和短语 | `tibetan_docs` |
| `docker/tibetan-qa-data.json` | 6.7MB | 2000 | 综合知识问答（历史、文化、地理） | `tibetan_qa` |
| `docker/tibetan-medical-qa-data.json` | 290KB | 239 | 传统藏医知识问答 | `tibetan_medical_qa` |

**数据来源：**
- 综合问答：来自公开藏文知识库
- 藏医问答：提取自传统藏医文献（གསོ་རིག་རྒྱུན་ཤེས།）

**注意：** 转换脚本（`convert-qa-csv.py`、`convert-medical-qa.py`）已包含供参考，但正常使用无需运行。

## 从源码构建

### 环境要求

- Elasticsearch 8.x 构建需要 Java 17 或更高版本
- Elasticsearch 9.x 构建需要 Java 21 或更高版本

### 构建步骤

```bash
# 克隆仓库
git clone https://github.com/TocharianOU/elastic-tibetan-analyzer.git
cd elastic-tibetan-analyzer

# 构建并测试插件
./gradlew clean check

# 插件文件位置：
# - build/distributions/tibetan-analyzer-plugin-2.0.0-es8.zip
```

## 手动安装

### 安装插件

```bash
# 从本地文件安装
bin/elasticsearch-plugin install file:///path/to/tibetan-analyzer-plugin-2.0.0-es8.zip

# 重启 Elasticsearch
```

### 创建使用藏文分词器的索引

```json
PUT /tibetan_test
{
  "settings": {
    "analysis": {
      "analyzer": {
        "my_tibetan": {
          "type": "tibetan_analyzer"
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "content": {
        "type": "text",
        "analyzer": "my_tibetan"
      }
    }
  }
}
```

### 测试分词

```json
POST /_analyze
{
  "analyzer": "tibetan_analyzer",
  "text": "བཀྲ་ཤིས་བདེ་ལེགས།"
}
```

**结果：**
```json
{
  "tokens": [
    { "token": "བཀྲ་ཤིས་བདེ་ལེགས", "position": 0 },
    { "token": "།", "position": 1 }
  ]
}
```

## 分词示例

| 输入 | 分词结果 | 翻译 |
|------|---------|------|
| `ང་ཚོས་སློབ་གྲྭར་འགྲོ་དགོས།` | `ང་ཚོ` `ས` `སློབ་གྲྭ` `ར` `འགྲོ་དགོས` `།` | 我们去学校 |
| `ངའི་ཕ་མ་གཉིས་དགོན་པར་ཕྱིན་པ་རེད།` | `ང` `འི` `ཕ་མ` `གཉིས` `དགོན་པ` `ར` `ཕྱིན་པ` `རེད` `།` | 我的父母去了寺院 |
| `བོད་ཀྱི་ལོ་རྒྱུས།` | `བོད` `ཀྱི` `ལོ་རྒྱུས` `།` | 西藏历史 |

## 算法原理

- **最长匹配分词**：优先匹配长词（4→3→2→1 音节）
- **词典查询**：65,000+ 词条覆盖多个类别
- **后缀处理**：自动分离语法助词（ས, ར, འི 等）
- **Unicode 支持**：正确处理藏文组合字符

## 自定义词典

在 `src/main/resources/dictionaries/custom_dictionary.txt` 添加自定义词汇（每行一个词）：

```
བོད་ལྗོངས་
རྒྱལ་ས་
ལྷ་ས་
```

添加后需重新构建插件。

## 词典统计

- 动词：3,117
- 单音节词：1,560
- 双音节词：38,647
- 三音节词：11,663
- 四音节词：10,232
- 虚词：38
- 后缀：10

## 兼容性

- Elasticsearch: 8.7.0+
- Lucene: 9.5+
- Java: 17+

## 许可证

Apache License 2.0

## 贡献

欢迎提交 Issue 和 Pull Request：https://github.com/TocharianOU/elastic-tibetan-analyzer

---

**注意**：本插件使用词典分词。对于特定领域文本，建议添加自定义词汇到词典以获得最佳效果。
