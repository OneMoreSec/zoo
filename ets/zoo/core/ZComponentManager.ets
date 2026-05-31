import { UIContext } from '@kit.ArkUI'
import { ZComponent, ZNode } from './ZooTemplate'
import { ComponentRegistry } from './ComponentRegistry'
import { 
  ColumnZComponent, 
  RowZComponent, 
  StackZComponent, 
  TextZComponent, 
  ImageZComponent, 
  ButtonZComponent, 
  ListZComponent, 
  ContainerZComponent 
} from './ZComponentImpl'
import { ZooLogger } from '../common/ZooLogger'

/**
 * ZComponent管理器 - 管理ZComponent的构建和组装
 */
export class ZComponentManager {
  private uiContext: UIContext
  private componentRegistry: ComponentRegistry

  constructor(uiContext: UIContext) {
    this.uiContext = uiContext
    this.componentRegistry = ComponentRegistry.getInstance()
    this.registerDefaultComponents()
  }

  private registerDefaultComponents(): void {
    this.componentRegistry.register({
      name: 'column',
      builder: (uiContext, znode) => new ColumnZComponent(uiContext, znode)
    })
    this.componentRegistry.register({
      name: 'row',
      builder: (uiContext, znode) => new RowZComponent(uiContext, znode)
    })
    this.componentRegistry.register({
      name: 'stack',
      builder: (uiContext, znode) => new StackZComponent(uiContext, znode)
    })
    this.componentRegistry.register({
      name: 'text',
      builder: (uiContext, znode) => new TextZComponent(uiContext, znode)
    })
    this.componentRegistry.register({
      name: 'image',
      builder: (uiContext, znode) => new ImageZComponent(uiContext, znode)
    })
    this.componentRegistry.register({
      name: 'button',
      builder: (uiContext, znode) => new ButtonZComponent(uiContext, znode)
    })
    this.componentRegistry.register({
      name: 'list',
      builder: (uiContext, znode) => new ListZComponent(uiContext, znode)
    })
  }

  /**
   * 从ZNode树构建组件树
   */
  buildComponentTree(rootZNode: ZNode): ZComponent {
    const rootComponent = this.createComponent(rootZNode)
    this.buildChildren(rootComponent, rootZNode)
    return rootComponent
  }

  private createComponent(znode: ZNode): ZComponent {
    const type = znode.type.toLowerCase()
    let component: ZComponent

    const customBuilder = this.componentRegistry.getBuilder(type)
    if (customBuilder) {
      component = customBuilder(this.uiContext, znode)
    } else {
      component = this.createBuiltInComponent(type, znode)
    }

    return component
  }

  private createBuiltInComponent(type: string, znode: ZNode): ZComponent {
    switch (type) {
      case 'column':
        return new ColumnZComponent(this.uiContext, znode)
      case 'row':
        return new RowZComponent(this.uiContext, znode)
      case 'stack':
        return new StackZComponent(this.uiContext, znode)
      case 'text':
        return new TextZComponent(this.uiContext, znode)
      case 'image':
        return new ImageZComponent(this.uiContext, znode)
      case 'button':
        return new ButtonZComponent(this.uiContext, znode)
      case 'list':
        return new ListZComponent(this.uiContext, znode)
      default:
        ZooLogger.warn(`ZComponentManager: Unknown component type ${type}, using container`)
        return new ContainerZComponent(this.uiContext, znode)
    }
  }

  private buildChildren(parentComponent: ZComponent, parentZNode: ZNode): void {
    if (!parentZNode.children || parentZNode.children.length === 0) {
      return
    }

    const parentFrameNode = parentComponent.getFrameNode()

    parentZNode.children.forEach(childZNode => {
      const childComponent = this.createComponent(childZNode)
      this.buildChildren(childComponent, childZNode)

      const childFrameNode = childComponent.getFrameNode()
      parentFrameNode.appendChild(childFrameNode)
    })
  }
}
