# Zoo Framework 使用指南

## 项目概述

Zoo是一个基于JSON模板的声明式MVVM框架，专为OpenHarmony设计。它允许开发者通过JSON描述页面结构，结合响应式数据绑定，快速构建应用界面。

## 核心概念

### 1. ZooViewModel - 响应式数据容器

```typescript
import { ZooViewModel } from '../zoo/core/ZooViewModel';

// 创建带有初始数据的ViewModel
@State private viewModel: ZooViewModel<object> = new ZooViewModel({
  title: 'app-list',
  count: 5,
  list: [
    { image: 'https://example.com/1.png', desc: 'app1' },
    { image: 'https://example.com/2.png', desc: 'app2' }
  ]
});

// 更新数据 - UI会自动响应
this.viewModel.set('title', 'new title');

// 批量更新数据
this.viewModel.setData({
  title: 'new title',
  count: 10
});

// 获取当前数据
const data = this.viewModel.getData();
```

### 2. JSON模板语法

#### 基础字段

```json
{
  "type": "column",        // 必填：组件类型
  "id": "myId",            // 可选：组件ID
  "class": "container",    // 可选：样式类
  "style": {},             // 可选：样式对象
  "data": {},               // 可选：数据对象
  "event": {},             // 可选：事件绑定
  "children": [],          // 可选：子组件列表
  "for": "{{item in list}}" // 可选：循环渲染
}
```

#### 数据绑定

使用 `{{expression}}` 语法进行数据绑定：

```json
{
  "type": "text",
  "data": {
    "content": "{{title}}"           // 绑定简单变量
  }
}

{
  "type": "image",
  "data": {
    "src": "{{item.image}}"          // 绑定循环中的变量
  }
}

{
  "type": "text",
  "data": {
    "content": "{{selected ? '是' : '否'}}"  // 绑定表达式
  }
}
```

#### 循环渲染

```json
{
  "for": "{{item in list}}",
  "type": "row",
  "children": [
    {
      "type": "image",
      "data": { "src": "{{item.image}}" }
    },
    {
      "type": "text",
      "data": { "content": "{{item.desc}}" }
    }
  ]
}
```

#### 事件绑定

```json
{
  "type": "button",
  "data": { "label": "点击我" },
  "event": {
    "onClick": "handleClick"    // 引用当前页面的方法
  }
}
```

### 3. 样式系统

#### 支持的样式属性

布局样式：
- `width`: 宽度
- `height`: 高度
- `padding`: 内边距
- `margin`: 外边距
- `backgroundColor`: 背景色
- `borderRadius`: 圆角
- `borderWidth`: 边框宽度
- `borderColor`: 边框颜色

文本样式：
- `font-size`: 字号
- `fontWeight`: 字重
- `fontColor`: 文字颜色
- `textAlign`: 文本对齐
- `fontFamily`: 字体

#### 样式示例

```json
{
  "style": {
    "width": "100%",
    "height": 50,
    "padding": 10,
    "margin": {"top": 5, "bottom": 10},
    "backgroundColor": "#FFFFFF",
    "borderRadius": 8,
    "font-size": 16,
    "fontWeight": "bold",
    "color": "#333333",
    "alignItems": "center",
    "justifyContent": "space-between"
  }
}
```

## 完整示例

### 基础列表页面

```typescript
import { Zoo } from '../zoo/core/Zoo';
import { ZooViewModel } from '../zoo/core/ZooViewModel';

@Entry
@Component
struct MyPage {
  @State private viewModel: ZooViewModel<object> = new ZooViewModel({
    title: '商品列表',
    items: [
      { name: '商品A', price: 99.9, image: 'https://example.com/a.png' },
      { name: '商品B', price: 199.9, image: 'https://example.com/b.png' }
    ]
  });

  private template = `{
    "type": "column",
    "style": {
      "width": "100%",
      "height": "100%",
      "padding": 20,
      "backgroundColor": "#F5F5F5"
    },
    "children": [
      {
        "type": "text",
        "data": {
          "content": "{{title}}"
        },
        "style": {
          "font-size": 24,
          "font-weight": "bold",
          "color": "#333333",
          "margin": {"bottom": 20}
        }
      },
      {
        "for": "{{item in items}}",
        "type": "column",
        "style": {
          "backgroundColor": "#FFFFFF",
          "padding": 15,
          "border-radius": 12,
          "margin": {"bottom": 10}
        },
        "children": [
          {
            "type": "row",
            "style": {
              "alignItems": "center"
            },
            "children": [
              {
                "type": "image",
                "style": {
                  "width": 60,
                  "height": 60,
                  "border-radius": 8
                },
                "data": {
                  "src": "{{item.image}}"
                }
              },
              {
                "type": "column",
                "style": {
                  "margin": {"left": 15}
                },
                "children": [
                  {
                    "type": "text",
                    "data": {
                      "content": "{{item.name}}"
                    },
                    "style": {
                      "font-size": 16,
                      "font-weight": "bold"
                    }
                  },
                  {
                    "type": "text",
                    "data": {
                      "content": "¥{{item.price}}"
                    },
                    "style": {
                      "font-size": 14,
                      "color": "#FF5722",
                      "margin": {"top": 5}
                    }
                  }
                ]
              }
            ]
          }
        ]
      },
      {
        "type": "button",
        "data": {
          "label": "添加商品"
        },
        "style": {
          "backgroundColor": "#4CAF50",
          "color": "#FFFFFF",
          "border-radius": 8,
          "height": 44,
          "margin": {"top": 20}
        },
        "event": {
          "onClick": "addItem"
        }
      }
    ]
  }`;

  addItem() {
    const items = this.viewModel.get('items') as Array<any>;
    const newItem = {
      name: `商品${items.length + 1}`,
      price: Math.random() * 100 + 50,
      image: 'https://example.com/default.png'
    };
    this.viewModel.set('items', [...items, newItem]);
  }

  build() {
    Column() {
      Zoo({
        template: this.template,
        viewModel: this.viewModel
      })
    }
    .width('100%')
    .height('100%')
  }
}
```

## 支持的组件列表

### 布局组件
- `column`: 纵向布局
- `row`: 横向布局
- `stack`: 层叠布局
- `flex`: 弹性布局

### 基础组件
- `text`: 文本
- `image`: 图片
- `button`: 按钮
- `input` / `textinput`: 文本输入框
- `divider`: 分割线
- `symbol`: 符号图标

### 表单组件
- `checkbox`: 复选框
- `radio`: 单选框
- `switch`: 开关
- `slider`: 滑动条

### 反馈组件
- `progress`: 进度条
- `loading` / `loadingprogress`: 加载进度
- `badge`: 徽章

## 高级特性

### 1. 条件渲染

```json
{
  "type": "text",
  "data": {
    "content": "{{isVip ? 'VIP用户' : '普通用户'}}"
  },
  "style": {
    "color": "{{isVip ? '#FFD700' : '#666666'}}"
  }
}
```

### 2. 嵌套循环

```json
{
  "type": "column",
  "children": [
    {
      "for": "{{category in categories}}",
      "type": "column",
      "children": [
        {
          "type": "text",
          "data": { "content": "{{category.name}}" }
        },
        {
          "for": "{{item in category.items}}",
          "type": "row",
          "children": [
            {
              "type": "text",
              "data": { "content": "{{item.name}}" }
            }
          ]
        }
      ]
    }
  ]
}
```

### 3. 复杂样式绑定

```json
{
  "type": "button",
  "data": {
    "label": "状态按钮"
  },
  "style": {
    "backgroundColor": "{{isActive ? '#4CAF50' : '#999999'}}",
    "opacity": "{{isDisabled ? 0.5 : 1}}",
    "border-radius": "{{radius}}"
  }
}
```

## 最佳实践

### 1. 数据管理
- 将所有页面数据集中在ViewModel中管理
- 使用`set`方法更新数据以确保响应式更新
- 避免直接修改ViewModel内部的数据对象

### 2. 模板组织
- 将复杂的JSON模板存储在单独的文件或常量中
- 使用缩进和对齐提高模板可读性
- 为组件添加`id`属性便于调试

### 3. 性能优化
- 避免在模板中使用过于复杂的表达式
- 对于大型列表，考虑使用虚拟滚动
- 合理使用`for`循环的键值以优化渲染性能

### 4. 类型安全
- 使用TypeScript的接口定义数据结构
- 为ViewModel提供完整的类型注解
- 利用IDE的智能提示提高开发效率

## 注意事项

1. **数据响应式**：修改ViewModel数据后UI会自动更新，无需手动刷新
2. **循环中的上下文**：在`for`循环内，循环变量在子节点中可直接使用
3. **事件处理**：事件处理方法需要在页面组件中正确定义
4. **样式单位**：数值类型默认为vp，无需额外单位
5. **资源引用**：图片等资源使用URL或资源引用

## 常见问题

### Q: 如何调试模板渲染？
A: 使用浏览器的开发者工具或DevEco Studio的日志查看ZooLogger的输出。

### Q: 如何实现自定义组件？
A: 目前版本支持OpenHarmony内置组件，后续版本将支持自定义组件注册。

### Q: 数据更新后UI没有响应？
A: 确保使用`viewModel.set()`方法更新数据，而不是直接修改数据对象。

### Q: 如何处理异步数据加载？
A: 在数据加载完成后调用`viewModel.set()`方法更新数据即可。
