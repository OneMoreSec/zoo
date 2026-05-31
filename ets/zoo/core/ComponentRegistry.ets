import { ComponentOption, ZComponent, ZNode } from './ZooTemplate'
import { ZooLogger } from '../common/ZooLogger'

/**
 * 组件注册表 - 用于注册和获取自定义组件的构建器
 */
export class ComponentRegistry {
  private static instance: ComponentRegistry
  private builders: Map<string, (uiContext: any, znode: ZNode) => ZComponent> = new Map()

  private constructor() {}

  static getInstance(): ComponentRegistry {
    if (!ComponentRegistry.instance) {
      ComponentRegistry.instance = new ComponentRegistry()
    }
    return ComponentRegistry.instance
  }

  register(option: ComponentOption): void {
    ZooLogger.info(`ComponentRegistry: Registering component ${option.name}`)
    this.builders.set(option.name.toLowerCase(), option.builder)
  }

  getBuilder(name: string): ((uiContext: any, znode: ZNode) => ZComponent) | undefined {
    return this.builders.get(name.toLowerCase())
  }
}
