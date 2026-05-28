import { Zoo } from '../zoo/core/Zoo'
import { ZooViewModel } from '../zoo/core/ZooViewModel'
import { ZooManager } from '../zoo/core/ZooManager'
import { JsonDataLoader } from '../zoo/core/JsonDataLoader'
import { TemplateRegistry } from '../zoo/core/TemplateRegistry'

// 定义模板
const pageTemplate = {
  name: 'app-list-comp',
  type: 'column',
  link: {
    '.title': {
      'font-size': 24,
      'font-weight': 'bold',
      'margin': { bottom: 20 }
    },
    '.list-item': {
      'background-color': '#FFFFFF',
      'padding': 15,
      'border-radius': 12,
      'margin': { bottom: 10 }
    },
    '.item-text': {
      'font-size': 16
    },
    '#main-title': {
      'color': '#333333'
    }
  },
  children: [
    {
      type: 'text',
      id: 'main-title',
      class: 'title',
      data: {
        content: '{{title}}'
      }
    },
    {
      type: 'row',
      style: {
        'justify-content': 'space-around',
        'margin': { bottom: 20 }
      },
      children: [
        {
          type: 'button',
          data: { label: '添加项目' },
          style: {
            'background-color': '#4CAF50'
          },
          event: {
            onClick: 'addItem'
          }
        },
        {
          type: 'button',
          data: { label: '删除项目' },
          style: {
            'background-color': '#f44336'
          },
          event: {
            onClick: 'removeItem'
          }
        },
        {
          type: 'button',
          data: { label: '修改标题' },
          style: {
            'background-color': '#2196F3'
          },
          event: {
            onClick: 'updateTitle'
          }
        }
      ]
    },
    {
      for: '{{item in items}}',
      type: 'row',
      class: 'list-item',
      style: {
        'align-items': 'center'
      },
      children: [
        {
          type: 'text',
          class: 'item-text',
          style: {
            'font-weight': 'bold'
          },
          data: {
            content: '{{item.id}}. '
          }
        },
        {
          type: 'text',
          class: 'item-text',
          data: {
            content: '{{item.name}}'
          }
        },
        {
          type: 'text',
          class: 'item-text',
          style: {
            'margin-left': 10,
            'color': '#FF5722'
          },
          data: {
            content: '¥{{item.price}}'
          }
        }
      ]
    }
  ]
}

@Entry
@Component
struct DemoPage {
  zooManager: ZooManager

  aboutToAppear() {
    // 注册模板
    TemplateRegistry.loadTemplate(pageTemplate)

    // 创建数据加载器
    const initialData = {
      template: 'app-list-comp',
      title: '应用列表',
      items: [
        { id: 1, name: '商品 A', price: 99.9 },
        { id: 2, name: '商品 B', price: 199.9 },
        { id: 3, name: '商品 C', price: 299.9 }
      ]
    }

    const dataLoader = new JsonDataLoader(initialData)

    // 创建管理器
    this.zooManager = ZooManager.builder()
      .dataLoader(dataLoader)
      .build()

    // 向管理器添加自定义方法，用于事件处理
    ;(this.zooManager as any).addItem = () => this.addItem()
    ;(this.zooManager as any).removeItem = () => this.removeItem()
    ;(this.zooManager as any).updateTitle = () => this.updateTitle()
  }

  addItem() {
    const items = this.zooManager.viewModel.get('items') as any[]
    const newId = items.length + 1
    const newItem = {
      id: newId,
      name: `商品 ${String.fromCharCode(64 + newId)}`,
      price: Math.round(Math.random() * 300 + 50)
    }
    // 使用 insert 方法
    this.zooManager.viewModel.insert('items', newItem)
  }

  removeItem() {
    const items = this.zooManager.viewModel.get('items') as any[]
    if (items.length > 0) {
      // 使用 delete 方法，删除最后一个
      this.zooManager.viewModel.delete('items', items.length - 1)
    }
  }

  updateTitle() {
    const currentTitle = this.zooManager.viewModel.get('title') as string
    const newTitle = currentTitle === '应用列表' ? '新标题' : '应用列表'
    // 使用 update 方法
    this.zooManager.viewModel.update('title', newTitle)
  }

  build() {
    Column() {
      Zoo({
        manager: this.zooManager
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .padding(20)
  }
}
