# 组件
## ZNode
Template中描述的页面结构中的每个节点，在ts代码中都会被转换成`ZNode`，用于承载该节点的信息。
```typescript
interface ZNode {
    type: string
    parent?: ZNode
    children?: ZNode[]
    data?: ESObject
    style?: ESObject
    id?: string,
    class?: string[]
}
```

## ZComponent
每个ZNode都会在ArkUI中生成一个组件，这些组件都使用ArkUI的FrameNode接口创建节点。ZCompoent用于管理ZNode和创建的ArkUI的FrameNode
FrameNode接口文档：https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-arkui-framenode
```typescript
interface ZComponent {
    construct(uiContext: UIContext, znode: ZNode)
    getFrameNode(): FrameNodew
    getZNode(): ZNode
}
```

## 组件类型
### 内置组件
Template中支持以下组件（没有列举出来的暂不支持）
| 组件名 | 对应ArkUI组件 |
| ---    | --- |
| column | Column |
| row | Row |
| stack | Stack |
| text | Text |
| image | Image |
| button | Button |
| list | List |

### 自定义组件
支持开发者在ArkUI中自定义组件并注册，注册后的自定义组件可在Template中按内置组件的用法使用
#### 接口定义
```typescript
interface ComponentRegistry {
    register(option: ComponentOption)
}

interface ComponentOption {
    name: string,   // 组件名称，用于在Template中引用
    builder: (uiContext: UIContext, compNode: ZNode) => ZComponent
}
```