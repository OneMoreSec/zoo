import { ZooLogger } from '../common/ZooLogger'

export class ZooViewModel<T extends Record<string, any>> {
  private _data: T
  private listeners: Map<string, Set<() => void>> = new Map()
  private isBatching: boolean = false
  private pendingUpdate: boolean = false
  private proxy: T

  constructor(initialData: T) {
    this._data = this.deepClone(initialData)
    this.proxy = this.createProxy(this._data)
  }

  get data(): T {
    return this.proxy
  }

  setData(newData: Partial<T>, notify: boolean = true): void {
    const oldData = this.deepClone(this._data)
    Object.assign(this._data, newData)

    if (notify) {
      this.notifyAll(oldData, this._data)
    }
  }

  get<K extends keyof T>(key: K): T[K] {
    return this.proxy[key]
  }

  set<K extends keyof T>(key: K, value: T[K], notify: boolean = true): void {
    const oldValue = this._data[key]
    if (oldValue !== value) {
      this._data[key] = value
      if (notify) {
        this.notify(key as string, oldValue, value)
      }
    }
  }

  // 插入操作
  insert(path: string, value: any, index?: number): void {
    const array = this.getValueByPath(path)
    if (Array.isArray(array)) {
      if (index !== undefined) {
        array.splice(index, 0, value)
      } else {
        array.push(value)
      }
      this.notify(path, array, array)
    } else {
      ZooLogger.warn(`ZooViewModel: Path ${path} is not an array for insert`)
    }
  }

  // 更新操作
  update(path: string, value: any): void {
    const keys = path.split('.')
    let current: any = this._data
    for (let i = 0; i < keys.length - 1; i++) {
      if (current[keys[i]] === undefined) {
        current[keys[i]] = {}
      }
      current = current[keys[i]]
    }
    const lastKey = keys[keys.length - 1]
    const oldValue = current[lastKey]
    current[lastKey] = value
    this.notify(path, oldValue, value)
  }

  // 删除操作
  delete(path: string, index?: number): void {
    if (index !== undefined) {
      // 删除数组元素
      const array = this.getValueByPath(path)
      if (Array.isArray(array)) {
        const oldValue = array[index]
        array.splice(index, 1)
        this.notify(path, oldValue, array)
      }
    } else {
      // 删除对象属性
      const keys = path.split('.')
      let current: any = this._data
      for (let i = 0; i < keys.length - 1; i++) {
        if (current[keys[i]] === undefined) {
          return
        }
        current = current[keys[i]]
      }
      const lastKey = keys[keys.length - 1]
      const oldValue = current[lastKey]
      delete current[lastKey]
      this.notify(path, oldValue, undefined)
    }
  }

  // 批量更新 - 多次修改汇总到下一帧
  batchUpdate(callback: () => void): void {
    this.isBatching = true
    try {
      callback()
    } finally {
      this.isBatching = false
      if (this.pendingUpdate) {
        this.pendingUpdate = false
        this.scheduleUpdate()
      }
    }
  }

  subscribe(key: string, listener: () => void): void {
    if (!this.listeners.has(key)) {
      this.listeners.set(key, new Set())
    }
    this.listeners.get(key)!.add(listener)
  }

  unsubscribe(key: string, listener: () => void): void {
    const keyListeners = this.listeners.get(key)
    if (keyListeners) {
      keyListeners.delete(listener)
      if (keyListeners.size === 0) {
        this.listeners.delete(key)
      }
    }
  }

  private notify(path: string, oldValue: any, newValue: any): void {
    if (this.isBatching) {
      this.pendingUpdate = true
      return
    }

    ZooLogger.debug(`ZooViewModel: Notifying change for path ${path}`)

    // 通知该路径及其父路径的监听器
    const keys = path.split('.')
    for (let i = keys.length; i >= 0; i--) {
      const key = i === 0 ? '*' : keys.slice(0, i).join('.')
      const keyListeners = this.listeners.get(key)
      if (keyListeners) {
        keyListeners.forEach(listener => listener())
      }
    }

    // 下一帧更新
    this.scheduleUpdate()
  }

  private notifyAll(oldData: T, newData: T): void {
    ZooLogger.debug(`ZooViewModel: Notifying all listeners`)
    const allKeys = new Set([...this.listeners.keys(), '*'])
    allKeys.forEach(key => {
      if (key === '*') {
        const allListeners = this.listeners.get('*')
        if (allListeners) {
          allListeners.forEach(listener => listener())
        }
      } else if (this.listeners.has(key)) {
        const keyListeners = this.listeners.get(key)!
        keyListeners.forEach(listener => listener())
      }
    })
  }

  private scheduleUpdate(): void {
    // 使用requestAnimationFrame或者类似机制，这里简化处理
    // 在实际ArkUI中，可以使用postTask或者其他机制
  }

  evaluate(expression: string): any {
    try {
      const context = this._data
      const func = new Function(...Object.keys(context), `return ${expression}`)
      return func(...Object.values(context))
    } catch (e) {
      ZooLogger.error(`ZooViewModel: Failed to evaluate expression ${expression}: ${e.message}`)
      return undefined
    }
  }

  evaluatePath(path: string): any {
    return this.getValueByPath(path)
  }

  private getValueByPath(path: string): any {
    const keys = path.split('.')
    let result: any = this._data
    for (const key of keys) {
      if (result === null || result === undefined) {
        return undefined
      }
      result = result[key]
    }
    return result
  }

  private createProxy(target: any, path: string = ''): any {
    const self = this
    return new Proxy(target, {
      get(target, key: string) {
        const value = target[key]
        if (typeof value === 'object' && value !== null) {
          return self.createProxy(value, path ? `${path}.${key}` : key)
        }
        return value
      },
      set(target, key: string, value: any) {
        const oldValue = target[key]
        if (oldValue !== value) {
          target[key] = value
          const fullPath = path ? `${path}.${key}` : key
          self.notify(fullPath, oldValue, value)
        }
        return true
      },
      deleteProperty(target, key: string) {
        const oldValue = target[key]
        delete target[key]
        const fullPath = path ? `${path}.${key}` : key
        self.notify(fullPath, oldValue, undefined)
        return true
      }
    })
  }

  private deepClone(obj: any): any {
    if (obj === null || typeof obj !== 'object') {
      return obj
    }
    if (Array.isArray(obj)) {
      return obj.map(item => this.deepClone(item))
    }
    const cloned: any = {}
    for (const key in obj) {
      cloned[key] = this.deepClone(obj[key])
    }
    return cloned
  }
}
