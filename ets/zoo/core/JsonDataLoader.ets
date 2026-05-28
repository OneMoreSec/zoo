import { DataLoader, PageResult } from './ZooTemplate'

export class JsonDataLoader implements DataLoader {
  constructor(private readonly data: ESObject) {
  }

  loadData(): Promise<PageResult> {
    return Promise.resolve({
      data: this.data
    })
  }
}
