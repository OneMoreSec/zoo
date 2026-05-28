import { Zoo } from '../zoo/core/Zoo';
import { ZooTemplate } from '../zoo/core/ZooTemplate';
import { ZooViewModel } from '../zoo/core/ZooViewModel';
import { ZooNodeBuilder } from '../zoo/core/ZooNodeBuilder';

@Entry
@Component
struct Index {
  @State private viewModel: ZooViewModel<object> = new ZooViewModel({
    title: 'app-list',
    list: [
      { image: 'https://via.placeholder.com/50', desc: 'app1' },
      { image: 'https://via.placeholder.com/50', desc: 'app2' },
      { image: 'https://via.placeholder.com/50', desc: 'app3' }
    ],
    count: 5,
    inputText: '',
    switchValue: false,
    sliderValue: 50
  });

  private template: string = `{
    "type": "column",
    "style": {
      "width": "100%",
      "height": "100%",
      "padding": 20,
      "background-color": "#F5F5F5"
    },
    "children": [
      {
        "type": "text",
        "id": "title",
        "style": {
          "font-size": 24,
          "font-weight": "bold",
          "color": "#333333",
          "margin": {"bottom": 20}
        },
        "data": {
          "content": "{{title}}"
        }
      },
      {
        "type": "column",
        "style": {
          "background-color": "#FFFFFF",
          "padding": 15,
          "border-radius": 12,
          "margin": {"bottom": 20}
        },
        "children": [
          {
            "type": "text",
            "style": {
              "font-size": 16,
              "color": "#666666",
              "margin": {"bottom": 10}
            },
            "data": {
              "content": "Badge示例"
            }
          },
          {
            "type": "badge",
            "style": {
              "badgeSize": 20,
              "badgeColor": "#FF0000"
            },
            "data": {
              "count": "{{count}}"
            },
            "children": [
              {
                "type": "button",
                "data": {
                  "label": "消息"
                },
                "style": {
                  "width": 80,
                  "height": 40
                }
              }
            ]
          }
        ]
      },
      {
        "type": "column",
        "style": {
          "background-color": "#FFFFFF",
          "padding": 15,
          "border-radius": 12,
          "margin": {"bottom": 20}
        },
        "children": [
          {
            "type": "text",
            "style": {
              "font-size": 16,
              "color": "#666666",
              "margin": {"bottom": 10}
            },
            "data": {
              "content": "Switch示例"
            }
          },
          {
            "type": "switch",
            "data": {
              "checked": "{{switchValue}}"
            },
            "style": {
              "selectedColor": "#4CAF50"
            }
          }
        ]
      },
      {
        "type": "column",
        "style": {
          "background-color": "#FFFFFF",
          "padding": 15,
          "border-radius": 12,
          "margin": {"bottom": 20}
        },
        "children": [
          {
            "type": "text",
            "style": {
              "font-size": 16,
              "color": "#666666",
              "margin": {"bottom": 10}
            },
            "data": {
              "content": "Slider示例"
            }
          },
          {
            "type": "slider",
            "data": {
              "value": "{{sliderValue}}",
              "min": 0,
              "max": 100
            },
            "style": {
              "width": "100%",
              "selectedColor": "#4CAF50"
            }
          }
        ]
      },
      {
        "type": "text",
        "style": {
          "font-size": 16,
          "color": "#666666",
          "margin": {"bottom": 10}
        },
        "data": {
          "content": "列表渲染示例"
        }
      },
      {
        "for": "{{item in list}}",
        "type": "row",
        "style": {
          "background-color": "#FFFFFF",
          "padding": 15,
          "border-radius": 8,
          "margin": {"bottom": 10},
          "alignItems": "center"
        },
        "event": {
          "onClick": "() => console.log('Row clicked:', item.desc)"
        },
        "children": [
          {
            "type": "image",
            "style": {
              "width": 50,
              "height": 50,
              "border-radius": 8,
              "margin": {"right": 15}
            },
            "data": {
              "src": "{{item.image}}"
            }
          },
          {
            "type": "text",
            "style": {
              "font-size": 16,
              "color": "#333333"
            },
            "data": {
              "content": "{{item.desc}}"
            }
          }
        ]
      },
      {
        "type": "row",
        "style": {
          "justifyContent": "space-between",
          "margin": {"top": 20}
        },
        "children": [
          {
            "type": "button",
            "id": "btnUpdate",
            "data": {
              "label": "更新标题"
            },
            "style": {
              "backgroundColor": "#4CAF50",
              "color": "#FFFFFF",
              "border-radius": 8,
              "margin": {"right": 10}
            },
            "event": {
              "onClick": "updateTitle"
            }
          },
          {
            "type": "button",
            "id": "btnAdd",
            "data": {
              "label": "添加项目"
            },
            "style": {
              "backgroundColor": "#2196F3",
              "color": "#FFFFFF",
              "border-radius": 8,
              "margin": {"right": 10}
            },
            "event": {
              "onClick": "addItem"
            }
          },
          {
            "type": "button",
            "id": "btnRemove",
            "data": {
              "label": "删除项目"
            },
            "style": {
              "backgroundColor": "#f44336",
              "color": "#FFFFFF",
              "border-radius": 8
            },
            "event": {
              "onClick": "removeItem"
            }
          }
        ]
      }
    ]
  }`;

  updateTitle() {
    const currentTitle = this.viewModel.get('title') as string;
    const newTitle = currentTitle === 'app-list' ? 'app-list2' : 'app-list';
    this.viewModel.set('title', newTitle);
  }

  addItem() {
    const list = this.viewModel.get('list') as Array<any>;
    const newItem = {
      image: 'https://via.placeholder.com/50',
      desc: `app${list.length + 1}`
    };
    this.viewModel.set('list', [...list, newItem]);
  }

  removeItem() {
    const list = this.viewModel.get('list') as Array<any>;
    if (list.length > 0) {
      this.viewModel.set('list', list.slice(0, -1));
    }
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
