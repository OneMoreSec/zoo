import { FrameNode, UIContext, nodeBuilder } from '@kit.ArkUI'
import { ZComponent, ZNode } from './ZooTemplate'
import { ZooLogger } from '../common/ZooLogger'

/**
 * 基础ZComponent抽象类
 */
abstract class BaseZComponent implements ZComponent {
  protected frameNode: FrameNode | null = null
  protected znode: ZNode
  protected uiContext: UIContext

  constructor(uiContext: UIContext, znode: ZNode) {
    this.uiContext = uiContext
    this.znode = znode
  }

  construct(uiContext: UIContext, znode: ZNode): void {
    this.uiContext = uiContext
    this.znode = znode
  }

  getFrameNode(): FrameNode {
    if (!this.frameNode) {
      throw new Error('FrameNode not initialized')
    }
    return this.frameNode
  }

  getZNode(): ZNode {
    return this.znode
  }

  protected applyStyles(): void {
    if (!this.frameNode || !this.znode.style) {
      return
    }

    const style = this.znode.style as Record<string, any>
    for (const key in style) {
      const value = style[key]
      const attributeMethod = (this.frameNode as any)?.attribute?.[key]
      if (typeof attributeMethod === 'function') {
        try {
          attributeMethod.call(this.frameNode, value)
        } catch (e) {
          ZooLogger.warn(`BaseZComponent: Failed to apply style ${key}: ${e}`)
        }
      }
    }
  }

  protected applyEvents(): void {
    if (!this.frameNode || !this.znode.event) {
      return
    }

    const events = this.znode.event as Record<string, any>
    for (const key in events) {
      const handler = events[key]
      const eventMethod = (this.frameNode as any)?.[key]
      if (typeof eventMethod === 'function') {
        try {
          eventMethod.call(this.frameNode, handler)
        } catch (e) {
          ZooLogger.warn(`BaseZComponent: Failed to apply event ${key}: ${e}`)
        }
      }
    }
  }
}

/**
 * Column组件
 */
export class ColumnZComponent extends BaseZComponent {
  constructor(uiContext: UIContext, znode: ZNode) {
    super(uiContext, znode)
    this.frameNode = nodeBuilder.createNode('Column', uiContext)
    this.applyStyles()
    this.applyEvents()
  }
}

/**
 * Row组件
 */
export class RowZComponent extends BaseZComponent {
  constructor(uiContext: UIContext, znode: ZNode) {
    super(uiContext, znode)
    this.frameNode = nodeBuilder.createNode('Row', uiContext)
    this.applyStyles()
    this.applyEvents()
  }
}

/**
 * Stack组件
 */
export class StackZComponent extends BaseZComponent {
  constructor(uiContext: UIContext, znode: ZNode) {
    super(uiContext, znode)
    this.frameNode = nodeBuilder.createNode('Stack', uiContext)
    this.applyStyles()
    this.applyEvents()
  }
}

/**
 * Text组件
 */
export class TextZComponent extends BaseZComponent {
  constructor(uiContext: UIContext, znode: ZNode) {
    super(uiContext, znode)
    const content = znode.data?.content || ''
    this.frameNode = nodeBuilder.createNode('Text', uiContext, [content])
    this.applyStyles()
    this.applyEvents()
  }
}

/**
 * Image组件
 */
export class ImageZComponent extends BaseZComponent {
  constructor(uiContext: UIContext, znode: ZNode) {
    super(uiContext, znode)
    const src = znode.data?.src || ''
    this.frameNode = nodeBuilder.createNode('Image', uiContext, [src])
    this.applyStyles()
    this.applyEvents()
  }
}

/**
 * Button组件
 */
export class ButtonZComponent extends BaseZComponent {
  constructor(uiContext: UIContext, znode: ZNode) {
    super(uiContext, znode)
    const label = znode.data?.label || ''
    this.frameNode = nodeBuilder.createNode('Button', uiContext, [label])
    this.applyStyles()
    this.applyEvents()
  }
}

/**
 * List组件
 */
export class ListZComponent extends BaseZComponent {
  constructor(uiContext: UIContext, znode: ZNode) {
    super(uiContext, znode)
    this.frameNode = nodeBuilder.createNode('List', uiContext)
    this.applyStyles()
    this.applyEvents()
  }
}

/**
 * 容器组件 - 用于没有特定类型的节点
 */
export class ContainerZComponent extends BaseZComponent {
  constructor(uiContext: UIContext, znode: ZNode) {
    super(uiContext, znode)
    this.frameNode = nodeBuilder.createNode('Column', uiContext)
    this.applyStyles()
    this.applyEvents()
  }
}
