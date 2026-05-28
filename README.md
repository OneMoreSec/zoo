# Zoo Framework - JSON驱动的MVVM框架

Zoo 是一个为 OpenHarmony 设计的轻量级 MVVM 框架，通过 JSON 模板描述 UI，实现声明式开发和响应式数据绑定。

## 特性

- 📄 **JSON 驱动的模板系统** - 使用 JSON 描述 UI 结构
- ⚡ **响应式数据绑定** - 数据变化自动更新 UI
- 🎨 **灵活的样式系统** - 支持内联样式、类选择器和 ID 选择器
- 🔄 **循环渲染** - 支持 `for` 循环渲染列表数据
- 📌 **事件绑定** - 支持组件事件绑定
- 🎯 **数据加载器** - 支持自定义数据加载器

## 快速开始

### 1. 定义模板

```typescript
const pageTemplate = {
  name: 'my-template',  // 模板名称
  type: 'column',
  link: {  // 样式选择器
    '.title': { 'font-size': 24 },
    '#my-button': { 'background-color': '#4CAF50' }
  },
  children: [
    {
      type: 'text',
      class: 'title',
      data: { content: '{{title}}' }
    }
  ]
}
```

### 2. 注册模板

```typescript
import { TemplateRegistry } from './zoo/core/TemplateRegistry'

TemplateRegistry.loadTemplate(pageTemplate)
```

### 3. 创建数据和管理器

```typescript
import { ZooManager } from './zoo/core/ZooManager'
import { JsonDataLoader } from './zoo/core/JsonDataLoader'

const initialData = {
  template: 'my-template',  // 指定使用的模板
  title: 'Hello Zoo!'
}

const dataLoader = new JsonDataLoader(initialData)
const zooManager = ZooManager.builder()
  .dataLoader(dataLoader)
  .build()
```

### 4. 使用 Zoo 组件

```typescript
import { Zoo } from './zoo/core/Zoo'

Zoo({
  manager: zooManager
})
```

## API 文档

### ZooTemplate 接口

```typescript
interface ZooTemplate {
  type: string                          // 组件类型
  children?: ZooTemplate[]              // 子组件
  style?: Record<string, any>           // 内联样式
  id?: string                           // 组件 ID
  class?: string                        // 组件类名
  data?: Record<string, any>            // 组件数据
  event?: Record<string, any>           // 事件绑定
  for?: string                          // 循环表达式
  link?: Record<string, any>            // 样式选择器（仅根节点）
}
```

### ZooViewModel

```typescript
const viewModel = new ZooViewModel(initialData)

// 设置单个值
viewModel.set('key', value)

// 批量更新
viewModel.setData({ key1: value1, key2: value2 })

// 数组操作
viewModel.insert('path.to.array', item)       // 插入
viewModel.insert('path.to.array', item, 0)   // 指定位置插入
viewModel.delete('path.to.array', index)      // 删除

// 更新嵌套属性
viewModel.update('path.to.nested.key', newValue)

// 订阅变化
viewModel.subscribe('key', () => console.log('changed'))
```

### ZooManager

```typescript
const manager = ZooManager.builder()
  .dataLoader(myDataLoader)
  .build()

// 访问数据
manager.viewModel.set('key', value)
```

### DataLoader 接口

```typescript
interface DataLoader {
  loadData(): Promise<PageResult>
}

interface PageResult {
  data: Record<string, any>
  template?: Record<string, any>
}

interface DataModel {
  data: Record<string, any>
  template?: string
}
```

## 模板语法

### 数据绑定

使用 `{{expression}}` 语法绑定数据：

```typescript
{
  type: 'text',
  data: {
    content: 'Hello {{username}}!'
  }
}

{
  type: 'text',
  data: {
    content: '{{user.firstName}} {{user.lastName}}'
  }
}
```

### 循环渲染

```typescript
{
  for: '{{item in items}}',
  type: 'row',
  children: [
    {
      type: 'text',
      data: {
        content: '{{item.name}}'
      }
    }
  ]
}
```

### 样式优先级

1. **内联样式** (最高优先级)
2. **ID 选择器** (`#id`)
3. **类选择器** (`.class`)

```typescript
{
  type: 'column',
  link: {
    '.my-class': { 'background-color': 'red' },
    '#my-id': { 'background-color': 'blue' }  // 优先级更高
  },
  children: [
    {
      type: 'text',
      id: 'my-id',
      class: 'my-class',
      style: { 'background-color': 'green' },  // 最高优先级
      data: { content: 'Hello' }
    }
  ]
}
```

### 事件绑定

```typescript
{
  type: 'button',
  data: { label: 'Click me' },
  event: {
    onClick: 'handleClick'
  }
}

// 在 ZooManager 上添加方法
;(manager as any).handleClick = () => {
  console.log('Button clicked')
}
```

## 支持的组件类型

### 布局组件
- `column` - 垂直布局容器
- `row` - 水平布局容器
- `stack` - 堆叠布局容器
- `flex` - 弹性布局容器

### 基础组件
- `text` - 文本组件
- `image` - 图片组件
- `button` - 按钮组件
- `input` / `textinput` - 文本输入组件
- `divider` - 分割线
- `symbol` - 符号图标
- `badge` - 徽标组件

### 表单组件
- `checkbox` - 复选框
- `radio` - 单选按钮
- `switch` - 开关
- `slider` - 滑动条

### 反馈组件
- `progress` - 进度条
- `loading` / `loadingprogress` - 加载动画

## 项目结构

```
zoo/
├── ets/
│   ├── zoo/
│   │   ├── core/
│   │   │   ├── Zoo.ets               # 主组件
│   │   │   ├── ZooTemplate.ets       # 模板接口
│   │   │   ├── ZooParser.ets         # 模板解析器
│   │   │   ├── ZooViewModel.ets      # 响应式数据
│   │   │   ├── ZooManager.ets        # 管理器
│   │   │   ├── JsonDataLoader.ets    # 数据加载器
│   │   │   └── TemplateRegistry.ets  # 模板注册
│   │   ├── common/
│   │   │   └── ZooLogger.ets         # 日志工具
│   │   └── index.ets
│   ├── entryability/
│   └── pages/
│       └── DemoPage.ets              # 示例页面
├── resources/
├── app.json5
└── module.json5
```

## 运行示例

1. 在 DevEco Studio 中打开项目
2. 选择 OpenHarmony 设备或模拟器
3. 运行项目
4. 查看 DemoPage 的演示效果

## 响应式特性

### 数据变更方式

框架支持三种修改数据的方式：

1. **直接操作代理对象**
```typescript
viewModel.data.title = 'New Title'  // 自动触发更新
```

2. **使用方法**
```typescript
viewModel.set('title', 'New Title')
viewModel.update('user.name', 'John')
viewModel.insert('items', newItem)
viewModel.delete('items', 0)
```

3. **批量操作**
```typescript
viewModel.batchUpdate(() => {
  viewModel.data.count++
  viewModel.data.title = 'New Title'
  viewModel.insert('items', newItem)
})  // 只在结束时触发一次更新
```

### 响应式更新机制

- 数据变更通过 Proxy 自动捕获
- 订阅者按路径通知，支持精确更新
- 多次变更自动合并，在下一帧统一渲染
- 支持路径订阅和通配符订阅

## 样式系统

### 支持的样式属性

所有 OpenHarmony ArkUI 组件支持的属性都可以使用。框架内部负责转换属性名和值。

```typescript
{
  style: {
    'width': '100%',
    'height': 100,
    'padding': { top: 10, bottom: 10 },
    'margin': 20,
    'background-color': '#FFFFFF',
    'font-size': 16,
    'font-weight': 'bold',
    'color': '#333333',
    'border-radius': 8,
    'align-items': 'center',
    'justify-content': 'space-around'
  }
}
```

## 技术亮点

1. **Proxy 响应式** - 使用 ES6 Proxy 实现高性能响应式系统
2. **路径解析** - 支持嵌套对象路径操作
3. **样式优先级** - CSS-like 的优先级系统
4. **构建器模式** - 流畅的 API 设计
5. **类型安全** - 完整的 TypeScript 类型定义

## 版本要求

- OpenHarmony API 9 及以上
- TypeScript 4.5+

## 许可证

MIT License
