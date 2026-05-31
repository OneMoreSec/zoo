import { FrameNode, UIContext } from '@kit.ArkUI'

// 数据值类型
type DataValueType = string | number | boolean | DataModel
    | Record<string, DataValueType> | Array<DataValueType>

// 页面数据模型
export interface DataModel {
    data: ESObject      // 用于指定Template使用的数据
    template?: string   // 用于指定DataModel对应使用的Template
}

// 页面结果
export interface PageResult {
  data: ESObject      // 页面数据，必须返回
  template?: ESObject // 页面模板，如果该字段有值优先使用此处模板，否则使用data中template字段指定的预先加载的模板
}

// 数据加载器接口
export interface DataLoader {
  loadData(): Promise<PageResult>
}

// 模板接口
export interface ZooTemplate {
    type: string,
    children?: ZooTemplate[],
    style?: Record<string, any>,
    id?: string,
    class?: string,
    data?: Record<string, any>,
    event?: Record<string, any>,
    for?: string,
    link?: Record<string, any>
}

// 带名称的模板接口
export interface ZooTemplateWithName extends ZooTemplate {
    name: string
}

// ZNode接口 - 对应component.md中的定义
export interface ZNode {
    type: string
    parent?: ZNode
    children?: ZNode[]
    data?: ESObject
    style?: ESObject
    id?: string
    class?: string[]
    event?: ESObject
}

// ZComponent接口 - 对应component.md中的定义
export interface ZComponent {
    construct(uiContext: UIContext, znode: ZNode): void
    getFrameNode(): FrameNode
    getZNode(): ZNode
}

// 组件选项接口
export interface ComponentOption {
    name: string,   // 组件名称，用于在Template中引用
    builder: (uiContext: UIContext, znode: ZNode) => ZComponent
}
