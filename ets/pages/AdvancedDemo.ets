import { Zoo } from '../zoo/core/Zoo';
import { ZooViewModel } from '../zoo/core/ZooViewModel';

@Entry
@Component
struct AdvancedDemo {
  @State private viewModel: ZooViewModel<object> = new ZooViewModel({
    userName: '张三',
    userAvatar: 'https://via.placeholder.com/100',
    email: 'zhangsan@example.com',
    notifications: 3,
    isPremium: true,
    items: [
      { id: 1, name: '商品A', price: 99.9, image: 'https://via.placeholder.com/80' },
      { id: 2, name: '商品B', price: 199.9, image: 'https://via.placeholder.com/80' },
      { id: 3, name: '商品C', price: 299.9, image: 'https://via.placeholder.com/80' }
    ],
    categories: ['手机', '电脑', '平板', '配件'],
    selectedCategory: '手机'
  });

  private template: string = `{
    "type": "column",
    "style": {
      "width": "100%",
      "height": "100%",
      "background-color": "#F0F0F0"
    },
    "children": [
      {
        "type": "column",
        "style": {
          "background-color": "#FFFFFF",
          "padding": 20,
          "margin": 15,
          "border-radius": 16,
          "shadow": {"radius": 10, "color": "#20000000"}
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
                  "border-radius": 30
                },
                "data": {
                  "src": "{{userAvatar}}"
                }
              },
              {
                "type": "column",
                "style": {
                  "margin": {"left": 15},
                  "flexGrow": 1
                },
                "children": [
                  {
                    "type": "text",
                    "style": {
                      "font-size": 20,
                      "font-weight": "bold",
                      "color": "#333333"
                    },
                    "data": {
                      "content": "{{userName}}"
                    }
                  },
                  {
                    "type": "text",
                    "style": {
                      "font-size": 14,
                      "color": "#666666",
                      "margin": {"top": 5}
                    },
                    "data": {
                      "content": "{{email}}"
                    }
                  }
                ]
              },
              {
                "type": "badge",
                "style": {
                  "badgeSize": 18,
                  "badgeColor": "#FF5722"
                },
                "data": {
                  "count": "{{notifications}}"
                },
                "children": [
                  {
                    "type": "symbol",
                    "data": {
                      "value": "$r('sys.symbol.bell')"
                    },
                    "style": {
                      "font-size": 24,
                      "color": "#333333"
                    }
                  }
                ]
              }
            ]
          },
          {
            "type": "divider",
            "style": {
              "margin": {"top": 20, "bottom": 20}
            }
          },
          {
            "type": "row",
            "style": {
              "justifyContent": "space-around"
            },
            "children": [
              {
                "type": "column",
                "style": {
                  "alignItems": "center"
                },
                "children": [
                  {
                    "type": "text",
                    "style": {
                      "font-size": 24,
                      "font-weight": "bold",
                      "color": "#4CAF50"
                    },
                    "data": {
                      "content": "VIP"
                    }
                  },
                  {
                    "type": "text",
                    "style": {
                      "font-size": 12,
                      "color": "#999999",
                      "margin": {"top": 5}
                    },
                    "data": {
                      "content": "会员状态"
                    }
                  }
                ]
              },
              {
                "type": "column",
                "style": {
                  "alignItems": "center"
                },
                "children": [
                  {
                    "type": "text",
                    "style": {
                      "font-size": 24,
                      "font-weight": "bold",
                      "color": "#2196F3"
                    },
                    "data": {
                      "content": "{{notifications}}"
                    }
                  },
                  {
                    "type": "text",
                    "style": {
                      "font-size": 12,
                      "color": "#999999",
                      "margin": {"top": 5}
                    },
                    "data": {
                      "content": "未读消息"
                    }
                  }
                ]
              }
            ]
          }
        ]
      },
      {
        "type": "text",
        "style": {
          "font-size": 18,
          "font-weight": "bold",
          "color": "#333333",
          "margin": {"left": 15, "top": 20, "bottom": 10}
        },
        "data": {
          "content": "商品列表"
        }
      },
      {
        "for": "{{item in items}}",
        "type": "column",
        "style": {
          "background-color": "#FFFFFF",
          "padding": 15,
          "margin": {"left": 15, "right": 15, "bottom": 10},
          "border-radius": 12
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
                  "width": 80,
                  "height": 80,
                  "border-radius": 8
                },
                "data": {
                  "src": "{{item.image}}"
                }
              },
              {
                "type": "column",
                "style": {
                  "margin": {"left": 15},
                  "flexGrow": 1
                },
                "children": [
                  {
                    "type": "text",
                    "style": {
                      "font-size": 16,
                      "font-weight": "bold",
                      "color": "#333333"
                    },
                    "data": {
                      "content": "{{item.name}}"
                    }
                  },
                  {
                    "type": "text",
                    "style": {
                      "font-size": 18,
                      "color": "#FF5722",
                      "font-weight": "bold",
                      "margin": {"top": 8}
                    },
                    "data": {
                      "content": "¥{{item.price}}"
                    }
                  }
                ]
              },
              {
                "type": "button",
                "data": {
                  "label": "购买"
                },
                "style": {
                  "backgroundColor": "#FF5722",
                  "color": "#FFFFFF",
                  "border-radius": 8,
                  "height": 36
                }
              }
            ]
          }
        ]
      },
      {
        "type": "text",
        "style": {
          "font-size": 18,
          "font-weight": "bold",
          "color": "#333333",
          "margin": {"left": 15, "top": 20, "bottom": 10}
        },
        "data": {
          "content": "分类"
        }
      },
      {
        "type": "row",
        "style": {
          "background-color": "#FFFFFF",
          "padding": 10,
          "margin": {"left": 15, "right": 15},
          "border-radius": 12
        },
        "children": [
          {
            "for": "{{category in categories}}",
            "type": "button",
            "style": {
              "backgroundColor": "{{selectedCategory === category ? '#4CAF50' : '#E0E0E0'}}",
              "color": "{{selectedCategory === category ? '#FFFFFF' : '#666666'}}",
              "border-radius": 20,
              "margin": {"right": 10},
              "height": 36,
              "padding": {"left": 16, "right": 16}
            },
            "data": {
              "label": "{{category}}"
            }
          }
        ]
      }
    ]
  }`;

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
