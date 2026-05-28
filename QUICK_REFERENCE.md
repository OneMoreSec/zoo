# Zoo Framework 快速参考

## 基础使用 (5步快速上手)

### Step 1: 引入组件
```typescript
import { Zoo } from '../zoo/core/Zoo';
import { ZooViewModel } from '../zoo/core/ZooViewModel';
```

### Step 2: 创建数据模型
```typescript
@State private viewModel: ZooViewModel<object> = new ZooViewModel({
  title: 'Hello Zoo',
  count: 0,
  items: []
});
```

### Step 3: 定义JSON模板
```typescript
private template = `{
  "type": "column",
  "children": [
    {"type": "text", "data": {"content": "{{title}}"}}
  ]
}`;
```

### Step 4: 使用Zoo组件
```typescript
build() {
  Column() {
    Zoo({
      template: this.template,
      viewModel: this.viewModel
    })
  }
}
```

### Step 5: 更新数据
```typescript
this.viewModel.set('title', 'New Title');
```

---

## 模板语法速查

| 语法 | 示例 | 说明 |
|------|------|------|
| 数据绑定 | `{{title}}` | 绑定变量 |
| 循环渲染 | `"for": "{{item in list}}"` | 遍历列表 |
| 条件渲染 | `{{flag ? '是' : '否'}}` | 三元表达式 |
| 属性绑定 | `"src": "{{item.image}}"` | 绑定属性 |
| 样式绑定 | `"color": "{{color}}"` | 动态样式 |

---

## 组件速查

### 布局组件
```
column  - 纵向布局
row    - 横向布局
stack  - 层叠布局
flex   - 弹性布局
```

### 基础组件
```
text   - 文本
image  - 图片
button - 按钮
input  - 输入框
divider - 分割线
symbol - 符号图标
```

### 表单组件
```
checkbox - 复选框
radio   - 单选框
switch  - 开关
slider  - 滑动条
```

### 反馈组件
```
progress      - 进度条
loading       - 加载动画
badge         - 徽章
```

---

## 常用样式速查

### 尺寸
```json
{
  "width": "100%",
  "height": 100,
  "padding": 10,
  "margin": {"top": 5, "bottom": 10}
}
```

### 背景
```json
{
  "backgroundColor": "#FFFFFF",
  "borderRadius": 8,
  "borderWidth": 1,
  "borderColor": "#E0E0E0"
}
```

### 文本
```json
{
  "font-size": 16,
  "fontWeight": "bold",
  "color": "#333333",
  "textAlign": "center"
}
```

### 布局
```json
{
  "alignItems": "center",
  "justifyContent": "space-between"
}
```

---

## ViewModel API

```typescript
// 创建
new ZooViewModel(initialData)

// 获取数据
viewModel.getData()

// 获取单个值
viewModel.get('key')

// 设置单个值 (推荐)
viewModel.set('key', value)

// 批量设置
viewModel.setData({ key1: value1, key2: value2 })

// 订阅变化
viewModel.subscribe('key', () => {
  console.log('数据变化了');
})

// 取消订阅
viewModel.unsubscribe('key', callback)
```

---

## 事件绑定

```json
{
  "type": "button",
  "event": {
    "onClick": "handleClick",
    "onTouch": "handleTouch",
    "onFocus": "handleFocus"
  }
}
```

在组件中定义处理方法：
```typescript
handleClick() {
  console.log('按钮被点击');
  this.viewModel.set('count', this.viewModel.get('count') + 1);
}
```

---

## For循环上下文

```json
{
  "for": "{{item in items}}",
  "type": "row",
  "children": [
    {
      "type": "text",
      "data": {"content": "{{item.name}}"}
    },
    {
      "type": "text",
      "data": {"content": "{{$item}}"}  // 当前索引
    }
  ]
}
```

---

## 完整示例模板

```typescript
import { Zoo } from '../zoo/core/Zoo';
import { ZooViewModel } from '../zoo/core/ZooViewModel';

@Entry
@Component
struct Demo {
  @State private viewModel: ZooViewModel<object> = new ZooViewModel({
    title: '标题',
    list: [{ name: '项目1' }, { name: '项目2' }]
  });

  private template = `{
    "type": "column",
    "style": {"padding": 20},
    "children": [
      {"type": "text", "data": {"content": "{{title}}"}},
      {
        "for": "{{item in list}}",
        "type": "text",
        "data": {"content": "{{item.name}}"}
      }
    ]
  }`;

  build() {
    Column() {
      Zoo({ template: this.template, viewModel: this.viewModel })
    }
  }
}
```

---

## 常用技巧

### 1. 条件样式
```json
"style": {
  "backgroundColor": "{{isActive ? '#4CAF50' : '#E0E0E0'}}"
}
```

### 2. 字符串字面量
```json
"data": {
  "content": "`这是一个字符串`"
}
```

### 3. 嵌套循环
```json
{
  "for": "{{category in categories}}",
  "children": [{
    "for": "{{item in category.items}}",
    "type": "text",
    "data": {"content": "{{item.name}}"}
  }]
}
```

### 4. 动态计算
```json
"data": {
  "content": "{{count * 10}}"
}
```

---

## 调试建议

1. **查看日志**：ZooLogger会输出组件渲染信息
2. **检查数据**：使用`viewModel.getData()`查看当前状态
3. **验证模板**：确保JSON格式正确
4. **检查绑定**：确认变量名称拼写正确
5. **查看控制台**：检查事件绑定是否生效

---

## 下一步

- 📖 查看 [README.md](README.md) 了解完整功能
- 📚 查看 [USAGE_GUIDE.md](USAGE_GUIDE.md) 学习高级用法
- 💡 运行示例代码体验框架能力
