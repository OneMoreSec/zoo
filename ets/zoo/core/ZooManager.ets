import { DataLoader } from './ZooTemplate'
import { ZooViewModel } from './ZooViewModel'
import { ZooLogger } from '../common/ZooLogger'

export class ZooManager {
  dataLoader: DataLoader
  viewModel: ZooViewModel<object>

  private constructor(builder: ZooManagerBuilder) {
    this.dataLoader = builder.dataLoader
    this.viewModel = new ZooViewModel<object>({})
  }

  static builder(): ZooManagerBuilder {
    return new ZooManagerBuilder()
  }

  async loadInitialData(): Promise<void> {
    ZooLogger.info('ZooManager: Loading initial data...')
    try {
      const pageResult = await this.dataLoader.loadData()
      this.viewModel.setData(pageResult.data)
      ZooLogger.info('ZooManager: Initial data loaded successfully')
    } catch (error) {
      ZooLogger.error(`ZooManager: Failed to load initial data - ${error}`)
    }
  }
}

export class ZooManagerBuilder {
  dataLoader: DataLoader

  dataLoader(loader: DataLoader): ZooManagerBuilder {
    this.dataLoader = loader
    return this
  }

  build(): ZooManager {
    if (!this.dataLoader) {
      throw new Error('ZooManagerBuilder: dataLoader must be set')
    }
    return new ZooManager(this)
  }
}
