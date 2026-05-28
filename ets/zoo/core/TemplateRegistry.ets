import { ZooTemplate, ZooTemplateWithName } from './ZooTemplate'
import { ZooLogger } from '../common/ZooLogger'

export class TemplateRegistry {
  private static instance: TemplateRegistry
  private templates: Map<string, ZooTemplate> = new Map()

  private constructor() {}

  static getInstance(): TemplateRegistry {
    if (!TemplateRegistry.instance) {
      TemplateRegistry.instance = new TemplateRegistry()
    }
    return TemplateRegistry.instance
  }

  static loadTemplate(template: ESObject): void {
    const registry = TemplateRegistry.getInstance()
    const templateWithName = template as ZooTemplateWithName

    if (!templateWithName.name) {
      ZooLogger.error('TemplateRegistry: Template must have a name field')
      return
    }

    registry.templates.set(templateWithName.name, template as ZooTemplate)
    ZooLogger.info(`TemplateRegistry: Template ${templateWithName.name} loaded successfully')
  }

  static getTemplate(name: string): ZooTemplate | undefined {
    const registry = TemplateRegistry.getInstance()
    const template = registry.templates.get(name)
    if (!template) {
      ZooLogger.warn(`TemplateRegistry: Template ${name} not found')
    }
    return template
  }
}
