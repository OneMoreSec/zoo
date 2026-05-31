
## 页面输入
### 页面模板Template
```json
{
    "name": "app-list-comp",
    "link": {
        ".item": {
            "width": "100%"
        }
    }
    "type": "column",
    "children": [
        {
            "type": "text",
            "id": "title",
            "style": {
                "font-size": 20
            },
            "data": {
                "content": "{{title}}"
            }
        },
        {
            "for": "{{item in list}}",
            "type": "row",
            "style": {
                "height": "10%",
            },
            "class": ".item",
            "event": {
                "onHover": "{{onHover}}"
            },
            "children": [
                {
                    "type": "image",
                    "id": "icon",
                    "class": ".image .icon",
                    "style": {
                        "background-color": "black"
                    },
                    "data": {
                        "src": "{{item.image}}"
                    }
                },
                {
                    "type": "text",
                    "id": "name",
                    "style": {
                        "font-size": 10
                    },
                    "data": {
                        "content": "{{item.desc}}"
                    }
                }
            ]
        }
    ]
}
```
接口定义
```typescript
interface Template {
    type: string,
    children?: Template
    style?: ESObject,
    id?: string
    class?: string
    data?: ESObject
    event?: ESObject
    for?: string
    link?: ESObject 
}
```

json字段描述：
1. `type`: 必填，指定节点类型，如column、row、image、button、text、symbol、list、tabs等
2. `children`: 非必填，子节点列表
3. `style`: 非必填，描述节点样式，为key-value格式
4. `id`: 非必填，指定节点id，为string格式
5. `class`：非必填，指定节点类别，为string格式，可有多种类别，空格隔开.
6. `data`：非必填，指定节点内数据，为key-value格式
7. `event`: 非必填，指定节点绑定事件
8. `for`: 非必填，指示当前节点需要循环构建
9. `link`: 非必填，当前页面的样式选择器需要包含于其中，只支持在根节点配置

### 页面数据DataModel
```json
{
    "template": "app-list-comp",
    "data": {
        "title": "app-list",
        "list": [
            { "image": "http://image1.png", "desc": "app1" },
            { "image": "http://image2.png", "desc": "app2" }
        ]
    }

}
```

#### DataModel定义
```typescript
type DataValueType = string | number | boolean | DataModel
    Record<string, DataValueType> | Array<DataValueType>
interface DataModel {
    data: ESObject      // 用于指定Template使用的数据
    template?: string   // 用于指定DataModel对应使用的Template
}
```
`DataModel`内可以嵌套其他的`DataModel`以支持动态渲染其他模板，但需要Template中有`component`节点来渲染该数据

### 生成的OpenHarmony结构
```
Column
    Text('app-list')
    Row
        Image('http://image1.png')
        Text('app1')
    Row
        Image('http://image2.png')
        Text('app2')
```
### Template和DataModel之间的关系
Template用于描述页面的节点结构，DataModel用于构建页面时数据绑定表达式的输入。一个ArkUI页面需要获取到到Template和DataModel才能构建出来。