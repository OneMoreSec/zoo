# 样式
## 开发者用法
### 在Template中通过style定义样式
```json
{
    "type": "text",
    "id": "title",
    "style": {
        "font-size": 20
    },
    "data": {
        "content": "{{title}}"
    }
}
```
### 在Template中通过link定义样式
在`link`中包含样式选择器，支持通过class和id来定义选择器
当选择器和内联样式同时生效时，优先级为内联样式 > ID选择器 > 类选择器
**Template**
```json
{
    "link": {
        ".item": {      // .xxx为类选择器
            "width": "100%"
        },
        "#title": {     // #xxx为ID选择器
            "font-color": "black"
        }
    }
    "type": "text",
    "id": "title",
    "class": "item",
    "style": {
        "font-size": 20
    },
    "data": {
        "content": "{{title}}"
    }
}
```

样式的key范围不做限定，对于不同类型的节点，可以使用不同的样式key，并且Template中指定的key与在ArkUI中使用的节点属性名保持一致。样式值的转换在Zoo内实现。

## 内部实现
避免通过硬编码的形式对各个节点的各个属性进行复制，比如下面的方式
```typescript
Column() {

}.width(style.width)
.height(style.height)
```

通过类似以下方法，做样式到节点属性的通用性设置
```typescript
let columnNode = typeNode.create('Column', uiContext);

fot (let key of this.style) {
    columnNode.attribute[key]?.(this.style[key])
}
```

### link中的样式
link中配置的样式同样也需要在节点中生效