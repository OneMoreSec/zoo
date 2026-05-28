## 集成入口
```typescript
// 页面数据结果
interface PageResult {
    data: DataModel,         // 页面数据，必须返回
    template?: Template     // 页面模板，如果该字段有值优先使用此处模板，否则使用data中template字段指定的预先加载的模板
}

// 数据加载器接口，根据具体场景可实现本地数据加载器或云侧数据加载器
interface DataLoader {
    loadData(): Promise<PageResult>
}

interface ZooManager {
    builder() ZooManagerBuilder， // manager构造器
    dataLoader: DataLoader
}

// 模板注册类，为全局单例
interface TemplateRegistry {
    loadTemplate(template: ESObject) // 加载模板，以模板中根节点name字段作为模板名
}

struct Zoo {
    manager: ZooManager // 必填
}
```

### 使用实例
```typescript
import template from './pageTemplate.json';
import data from './pageData.json';

Class JsonDataLoader implements DataLoader {
    constructor(private readonly data: ESObject) {

    }
    loadData(): Promise<PageResult> {
        return Promise.resolve(this.data);
    }
}

@Entry
@Component
struct TestPage {
    zooManager: ZooManager;

    aboutToAppear() {
        // 注册页面模板
        TemplateRegistry.loadTemplate(template);
        // 构建manager
        this.zooManager = ZooManager.builder()
            .dataLoader(new JsonDataLoader(data))
            .build();
    }

    build() {
        Zoo({
            manager: this.zooManager
        })
    }
}
```
