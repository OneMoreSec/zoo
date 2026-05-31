import { ZooTemplate, ZNode, DataModel } from './ZooTemplate'
import { ZooParser } from './ZooParser'
import { ZooLogger } from '../common/ZooLogger'

/**
 * ZNode树构建器 - 从Template和DataModel生成ZNode树
 */
export class ZNodeTreeBuilder {
  private data: ESObject = {}
  private linkStyles: Record<string, any> = {}

  /**
   * 从Template和DataModel构建ZNode树
   */
  build(template: ZooTemplate, dataModel: DataModel): ZNode {
    this.data = dataModel.data
    this.linkStyles = template.link || {}
    
    return this.buildNode(template)
  }

  private buildNode(template: ZooTemplate, parent?: ZNode): ZNode {
    if (template.for) {
      return this.buildForNode(template, parent)
    }
    
    return this.buildNormalNode(template, parent)
  }

  private buildForNode(template: ZooTemplate, parent?: ZNode): ZNode {
    const forInfo = ZooParser.parseForExpression(template.for!)
    if (!forInfo) {
      ZooLogger.error('ZNodeTreeBuilder: Invalid for expression')
      return { type: 'column', parent, children: [] }
    }

    const listData = this.getDataByPath(forInfo.listName)
    if (!Array.isArray(listData)) {
      ZooLogger.error(`ZNodeTreeBuilder: ${forInfo.listName} is not an array`)
      return { type: 'column', parent, children: [] }
    }

    const containerNode: ZNode = {
      type: 'column',
      parent,
      children: []
    }

    listData.forEach((item: any, index: number) => {
      if (template.children) {
        template.children.forEach(childTemplate => {
          const originalData = { ...this.data }
          
          this.data[forInfo.itemName] = item
          this.data[`$${forInfo.itemName}`] = index
          
          const childNode = this.buildNormalNode(childTemplate, containerNode)
          containerNode.children!.push(childNode)
          
          this.data = originalData
        })
      }
    })

    return containerNode
  }

  private buildNormalNode(template: ZooTemplate, parent?: ZNode): ZNode {
    const node: ZNode = {
      type: template.type,
      parent,
      children: []
    }

    if (template.id) {
      node.id = template.id
    }

    if (template.class) {
      node.class = template.class.trim().split(/\s+/).filter(Boolean)
    }

    node.style = this.getMergedStyle(template)

    if (template.data) {
      node.data = this.resolveData(template.data)
    }

    if (template.event) {
      node.event = template.event
    }

    if (template.children) {
      node.children = template.children.map(child => 
        this.buildNode(child, node)
      )
    }

    return node
  }

  private getMergedStyle(template: ZooTemplate): ESObject {
    const merged: any = {}

    if (template.class) {
      const classes = template.class.trim().split(/\s+/).filter(Boolean)
      classes.forEach(className => {
        const selector = '.' + className
        const classStyle = this.linkStyles[selector]
        if (classStyle) {
          Object.assign(merged, this.resolveStyle(classStyle))
        }
      })
    }

    if (template.id) {
      const idSelector = '#' + template.id
      const idStyle = this.linkStyles[idSelector]
      if (idStyle) {
        Object.assign(merged, this.resolveStyle(idStyle))
      }
    }

    if (template.style) {
      Object.assign(merged, this.resolveStyle(template.style))
    }

    return merged
  }

  private resolveStyle(style: any): any {
    if (!style) {
      return {}
    }

    const resolved: any = {}
    for (const key in style) {
      const value = style[key]
      if (typeof value === 'string' && ZooParser.isBindingExpression(value)) {
        resolved[key] = this.resolveBinding(value)
      } else if (typeof value === 'object' && value !== null) {
        resolved[key] = this.resolveStyle(value)
      } else {
        resolved[key] = value
      }
    }
    return resolved
  }

  private resolveData(data: any): any {
    if (!data) {
      return {}
    }

    const resolved: any = {}
    for (const key in data) {
      const value = data[key]
      if (typeof value === 'string') {
        if (ZooParser.isStringLiteral(value)) {
          resolved[key] = ZooParser.extractStringLiteral(value)
        } else if (ZooParser.isBindingExpression(value)) {
          resolved[key] = this.resolveBinding(value)
        } else {
          resolved[key] = value
        }
      } else {
        resolved[key] = value
      }
    }
    return resolved
  }

  private resolveBinding(expression: string): any {
    const match = expression.match(/\{\{([^}]+)\}\}/)
    if (match) {
      const expr = match[1].trim()

      try {
        const keys = Object.keys(this.data)
        const values = Object.values(this.data)
        const func = new Function(...keys, `return ${expr}`)
        return func(...values)
      } catch (e) {
        ZooLogger.error(`ZNodeTreeBuilder: Failed to resolve binding ${expression}: ${e}`)
        return ''
      }
    }
    return expression
  }

  private getDataByPath(path: string): any {
    const parts = path.split('.')
    let result = this.data
    for (const part of parts) {
      if (result && typeof result === 'object' && part in result) {
        result = result[part]
      } else {
        return undefined
      }
    }
    return result
  }
}
