import { ZooLogger } from '../common/ZooLogger'
import { ZooParser } from './ZooParser'
import { ZooTemplate, PageResult } from './ZooTemplate'
import { ZooManager } from './ZooManager'
import { TemplateRegistry } from './TemplateRegistry'
import {
  Column,
  Row,
  Stack,
  Flex,
  Text,
  Image,
  Button,
  TextInput,
  Checkbox,
  Radio,
  Switch,
  Slider,
  Progress,
  LoadingProgress,
  Divider,
  Badge,
  SymbolGlyph
} from '@kit.ArkUI'
import { Length } from '@kit.ArkGraphics2D'

@Component
export struct Zoo {
  @Prop manager: ZooManager
  @State currentTemplate: ZooTemplate | null = null
  @State isLoading: boolean = true
  @State updateKey: number = 0 // 用于触发UI更新

  aboutToAppear() {
    ZooLogger.info('Zoo component aboutToAppear')
    this.loadTemplateAndData()
    // 订阅数据变更
    this.manager.viewModel.subscribe('*', this.onDataChange.bind(this))
  }

  aboutToDisappear() {
    ZooLogger.info('Zoo component aboutToDisappear')
    this.manager.viewModel.unsubscribe('*', this.onDataChange.bind(this))
  }

  onDataChange() {
    this.updateKey++
    ZooLogger.debug('Zoo component: Data changed, updateKey incremented')
  }

  async loadTemplateAndData() {
    this.isLoading = true
    try {
      await this.manager.loadInitialData()
      const viewModelData = this.manager.viewModel.getData()

      // 检查是否有模板指定
      let template: ZooTemplate | null = null

      // 1. 检查PageResult中是否有template字段
      const dataLoaderResult = this.manager.viewModel.getData()

      // 2. 检查数据中是否有template字段
      if (dataLoaderResult && (dataLoaderResult as any).template) {
        const templateName = (dataLoaderResult as any).template as string
        template = TemplateRegistry.getTemplate(templateName)
        if (template) {
          ZooLogger.info(`Zoo: Using registered template ${templateName}`)
        }
      }

      if (template) {
        this.currentTemplate = template
      } else {
        ZooLogger.warn('Zoo: No template found, showing empty page')
      }
    } catch (error) {
      ZooLogger.error(`Zoo: Failed to load template and data - ${error}`)
    } finally {
      this.isLoading = false
    }
  }

  build() {
    if (this.isLoading) {
      Column() {
        LoadingProgress()
          .width(48)
          .height(48)
          .color('#4CAF50')
        Text('Loading...')
          .margin({ top: 16 })
          .fontSize(14)
          .color('#666666')
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    } else if (this.currentTemplate) {
      this.buildNode(this.currentTemplate, new Map(), this.currentTemplate.link || {})
    } else {
      Column() {
        Text('No template available')
          .fontSize(16)
          .color('#999999')
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
  }

  @Builder
  buildNode(node: ZooTemplate, forContext: Map<string, any>, linkStyles: Record<string, any>) {
    if (node.for) {
      this.buildForNode(node, forContext, linkStyles)
    } else {
      this.buildComponent(node, forContext, linkStyles)
    }
  }

  @Builder
  buildForNode(node: ZooTemplate, parentContext: Map<string, any>, linkStyles: Record<string, any>) {
    const forInfo = ZooParser.parseForExpression(node.for!)
    if (!forInfo) {
      ZooLogger.error('Zoo: Invalid for expression')
      return
    }

    const listData = this.manager.viewModel.evaluate(forInfo.listName)
    if (!Array.isArray(listData)) {
      ZooLogger.error(`Zoo: ${forInfo.listName} is not an array`)
      return
    }

    ForEach(listData, (item: any, index: number) => {
      const forCtx = new Map<string, any>(parentContext)
      forCtx.set(forInfo.itemName, item)
      forCtx.set('$' + forInfo.itemName, index)

      if (node.children) {
        ForEach(node.children, (child: ZooTemplate, idx: number) => {
          this.buildNode(child, forCtx, linkStyles)
        })
      }
    })
  }

  @Builder
  buildComponent(node: ZooTemplate, forContext: Map<string, any>, linkStyles: Record<string, any>) {
    const type = node.type.toLowerCase()
    const style = this.getMergedStyle(node, linkStyles, forContext)
    const data = this.resolveData(node.data, forContext)
    const event = this.resolveEvents(node.event)

    switch (type) {
      case 'column':
        this.buildColumn(node, style, event, forContext, linkStyles)
        break
      case 'row':
        this.buildRow(node, style, event, forContext, linkStyles)
        break
      case 'stack':
        this.buildStack(node, style, event, forContext, linkStyles)
        break
      case 'flex':
        this.buildFlex(node, style, event, forContext, linkStyles)
        break
      case 'text':
        this.buildText(node, style, data)
        break
      case 'image':
        this.buildImage(node, style, data)
        break
      case 'button':
        this.buildButton(node, style, data, event)
        break
      case 'input':
      case 'textinput':
        this.buildTextInput(node, style, data, event)
        break
      case 'checkbox':
        this.buildCheckbox(node, style, data, event)
        break
      case 'radio':
        this.buildRadio(node, style, data, event)
        break
      case 'switch':
        this.buildSwitch(node, style, data, event)
        break
      case 'slider':
        this.buildSlider(node, style, data, event)
        break
      case 'progress':
        this.buildProgress(node, style, data)
        break
      case 'loading':
      case 'loadingprogress':
        this.buildLoadingProgress(node, style, data)
        break
      case 'divider':
        this.buildDivider(node, style, data)
        break
      case 'badge':
        this.buildBadge(node, style, data, forContext, linkStyles)
        break
      case 'symbol':
        this.buildSymbol(node, style, data)
        break
      default:
        this.buildDefault(node, style)
    }
  }

  @Builder
  buildColumn(node: ZooTemplate, style: any, event: any, forContext: Map<string, any>, linkStyles: Record<string, any>) {
    Column() {
      if (node.children) {
        ForEach(node.children, (child: ZooTemplate, index: number) => {
          this.buildNode(child, forContext, linkStyles)
        })
      }
    }
    .width(this.parseLength(style.width))
    .height(this.parseLength(style.height))
    .padding(this.parsePadding(style.padding))
    .margin(this.parseMargin(style.margin))
    .backgroundColor(style.backgroundColor)
    .borderStyle(style.borderStyle)
    .borderWidth(style.borderWidth)
    .borderColor(style.borderColor)
    .borderRadius(this.parseLength(style.borderRadius))
    .alignItems(this.parseAlignItems(style.alignItems))
    .justifyContent(this.parseJustifyContent(style.justifyContent))
    .onClick(event.onClick)
    .onTouch(event.onTouch)
    .onHover(event.onHover)
  }

  @Builder
  buildRow(node: ZooTemplate, style: any, event: any, forContext: Map<string, any>, linkStyles: Record<string, any>) {
    Row() {
      if (node.children) {
        ForEach(node.children, (child: ZooTemplate, index: number) => {
          this.buildNode(child, forContext, linkStyles)
        })
      }
    }
    .width(this.parseLength(style.width))
    .height(this.parseLength(style.height))
    .padding(this.parsePadding(style.padding))
    .margin(this.parseMargin(style.margin))
    .backgroundColor(style.backgroundColor)
    .borderStyle(style.borderStyle)
    .borderWidth(style.borderWidth)
    .borderColor(style.borderColor)
    .borderRadius(this.parseLength(style.borderRadius))
    .alignItems(this.parseAlignItems(style.alignItems))
    .justifyContent(this.parseJustifyContent(style.justifyContent))
    .onClick(event.onClick)
    .onTouch(event.onTouch)
    .onHover(event.onHover)
  }

  @Builder
  buildStack(node: ZooTemplate, style: any, event: any, forContext: Map<string, any>, linkStyles: Record<string, any>) {
    Stack() {
      if (node.children) {
        ForEach(node.children, (child: ZooTemplate, index: number) => {
          this.buildNode(child, forContext, linkStyles)
        })
      }
    }
    .width(this.parseLength(style.width))
    .height(this.parseLength(style.height))
    .padding(this.parsePadding(style.padding))
    .margin(this.parseMargin(style.margin))
    .backgroundColor(style.backgroundColor)
    .alignContent(this.parseAlignment(style.alignContent))
    .onClick(event.onClick)
  }

  @Builder
  buildFlex(node: ZooTemplate, style: any, event: any, forContext: Map<string, any>, linkStyles: Record<string, any>) {
    Flex() {
      if (node.children) {
        ForEach(node.children, (child: ZooTemplate, index: number) => {
          this.buildNode(child, forContext, linkStyles)
        })
      }
    }
    .width(this.parseLength(style.width))
    .height(this.parseLength(style.height))
    .padding(this.parsePadding(style.padding))
    .margin(this.parseMargin(style.margin))
    .backgroundColor(style.backgroundColor)
    .direction(this.parseDirection(style.direction))
    .wrap(this.parseWrap(style.wrap))
    .justifyContent(this.parseJustifyContent(style.justifyContent))
    .alignItems(this.parseAlignItems(style.alignItems))
    .alignContent(this.parseAlignContent(style.alignContent))
    .onClick(event.onClick)
  }

  @Builder
  buildText(node: ZooTemplate, style: any, data: any) {
    Text(data.content || '')
      .id(node.id || '')
      .fontSize(this.parseFontSize(style['font-size'] || style.fontSize))
      .fontWeight(this.parseFontWeight(style.fontWeight))
      .fontStyle(this.parseFontStyle(style.fontStyle))
      .fontFamily(style.fontFamily || 'HarmonyOS Sans')
      .fontColor(style['font-color'] || style.fontColor || style.color || '#000000')
      .textAlign(this.parseTextAlign(style.textAlign))
      .maxLines(style.maxLines || 999)
      .textOverflow({ overflow: this.parseTextOverflow(style.textOverflow) })
      .width(this.parseLength(style.width))
      .height(this.parseLength(style.height))
      .padding(this.parsePadding(style.padding))
      .margin(this.parseMargin(style.margin))
      .backgroundColor(style.backgroundColor)
      .borderStyle(style.borderStyle)
      .borderWidth(style.borderWidth)
      .borderColor(style.borderColor)
      .borderRadius(this.parseLength(style.borderRadius))
  }

  @Builder
  buildImage(node: ZooTemplate, style: any, data: any) {
    Image(data.src || '')
      .id(node.id || '')
      .width(this.parseLength(style.width) || 100)
      .height(this.parseLength(style.height) || 100)
      .padding(this.parsePadding(style.padding))
      .margin(this.parseMargin(style.margin))
      .backgroundColor(style.backgroundColor)
      .borderStyle(style.borderStyle)
      .borderWidth(style.borderWidth)
      .borderColor(style.borderColor)
      .borderRadius(this.parseLength(style.borderRadius))
      .objectFit(this.parseObjectFit(style.objectFit))
      .alt(style.alt || '')
  }

  @Builder
  buildButton(node: ZooTemplate, style: any, data: any, event: any) {
    Button(data.label || 'Button', { type: this.parseButtonType(style.buttonType) })
      .id(node.id || '')
      .width(this.parseLength(style.width))
      .height(this.parseLength(style.height))
      .padding(this.parsePadding(style.padding))
      .margin(this.parseMargin(style.margin))
      .fontSize(this.parseFontSize(style['font-size'] || style.fontSize))
      .fontWeight(this.parseFontWeight(style.fontWeight))
      .fontColor(style['font-color'] || style.fontColor || style.color || '#FFFFFF')
      .backgroundColor(style.backgroundColor || '#4CAF50')
      .borderStyle(style.borderStyle)
      .borderWidth(style.borderWidth)
      .borderColor(style.borderColor)
      .borderRadius(this.parseLength(style.borderRadius || 10))
      .onClick(event.onClick)
      .onTouch(event.onTouch)
      .onHover(event.onHover)
  }

  @Builder
  buildTextInput(node: ZooTemplate, style: any, data: any, event: any) {
    TextInput({ placeholder: data.placeholder, text: data.text || '' })
      .id(node.id || '')
      .width(this.parseLength(style.width))
      .height(this.parseLength(style.height || 40))
      .padding(this.parsePadding(style.padding))
      .margin(this.parseMargin(style.margin))
      .fontSize(this.parseFontSize(style['font-size'] || style.fontSize))
      .fontColor(style['font-color'] || style.fontColor || style.color || '#000000')
      .placeholderColor(style.placeholderColor || '#999999')
      .backgroundColor(style.backgroundColor || '#FFFFFF')
      .borderStyle(style.borderStyle)
      .borderWidth(style.borderWidth)
      .borderColor(style.borderColor)
      .borderRadius(this.parseLength(style.borderRadius || 8))
      .onChange(event.onChange)
      .onFocus(event.onFocus)
      .onBlur(event.onBlur)
  }

  @Builder
  buildCheckbox(node: ZooTemplate, style: any, data: any, event: any) {
    Checkbox()
      .id(node.id || '')
      .width(this.parseLength(style.width))
      .height(this.parseLength(style.height))
      .padding(this.parsePadding(style.padding))
      .margin(this.parseMargin(style.margin))
      .select(data.checked || false)
      .selectedColor(style.selectedColor || '#4CAF50')
      .onChange(event.onChange)
  }

  @Builder
  buildRadio(node: ZooTemplate, style: any, data: any, event: any) {
    Radio({ value: data.value || '', group: data.group || '' })
      .id(node.id || '')
      .width(this.parseLength(style.width))
      .height(this.parseLength(style.height))
      .padding(this.parsePadding(style.padding))
      .margin(this.parseMargin(style.margin))
      .checked(data.checked || false)
      .onChange(event.onChange)
  }

  @Builder
  buildSwitch(node: ZooTemplate, style: any, data: any, event: any) {
    Switch()
      .id(node.id || '')
      .width(this.parseLength(style.width))
      .height(this.parseLength(style.height))
      .padding(this.parsePadding(style.padding))
      .margin(this.parseMargin(style.margin))
      .checked(data.checked || false)
      .selectedColor(style.selectedColor || '#4CAF50')
      .onChange(event.onChange)
  }

  @Builder
  buildSlider(node: ZooTemplate, style: any, data: any, event: any) {
    Slider({ value: data.value || 0, min: data.min || 0, max: data.max || 100, step: data.step || 1 })
      .id(node.id || '')
      .width(this.parseLength(style.width))
      .height(this.parseLength(style.height))
      .padding(this.parsePadding(style.padding))
      .margin(this.parseMargin(style.margin))
      .blockColor(style.blockColor || '#4CAF50')
      .trackColor(style.trackColor || '#E0E0E0')
      .selectedColor(style.selectedColor || '#4CAF50')
      .onChange(event.onChange)
  }

  @Builder
  buildProgress(node: ZooTemplate, style: any, data: any) {
    Progress({ value: data.value || 0, total: data.total || 100, type: this.parseProgressType(style.type) })
      .id(node.id || '')
      .width(this.parseLength(style.width || 200))
      .height(this.parseLength(style.height || 10))
      .padding(this.parsePadding(style.padding))
      .margin(this.parseMargin(style.margin))
      .color(style.color || '#4CAF50')
      .backgroundColor(style.backgroundColor || '#E0E0E0')
  }

  @Builder
  buildLoadingProgress(node: ZooTemplate, style: any, data: any) {
    LoadingProgress()
      .id(node.id || '')
      .width(this.parseLength(style.width || 48))
      .height(this.parseLength(style.height || 48))
      .padding(this.parsePadding(style.padding))
      .margin(this.parseMargin(style.margin))
      .color(style.color || '#4CAF50')
  }

  @Builder
  buildDivider(node: ZooTemplate, style: any, data: any) {
    Divider()
      .id(node.id || '')
      .width(this.parseLength(style.width || '100%'))
      .height(this.parseLength(style.height || 1))
      .padding(this.parsePadding(style.padding))
      .margin(this.parseMargin(style.margin))
      .vertical(style.vertical || false)
      .color(style.color || '#E0E0E0')
      .strokeWidth(style.strokeWidth || 1)
  }

  @Builder
  buildBadge(node: ZooTemplate, style: any, data: any, forContext: Map<string, any>, linkStyles: Record<string, any>) {
    Badge({
      count: data.count || 0,
      style: {
        badgeSize: style.badgeSize || 12,
        badgeColor: style.badgeColor || '#FF0000'
      }
    }) {
      if (node.children && node.children.length > 0) {
        this.buildNode(node.children[0], forContext, linkStyles)
      }
    }
    .id(node.id || '')
  }

  @Builder
  buildSymbol(node: ZooTemplate, style: any, data: any) {
    SymbolGlyph(data.value || $r('sys.symbol.oh_logo'))
      .id(node.id || '')
      .fontSize(this.parseFontSize(style['font-size'] || style.fontSize || 24))
      .fontColor(style['font-color'] || style.fontColor || '#000000')
      .renderingStrategy(this.parseSymbolRenderingStrategy(style.renderingStrategy))
      .width(this.parseLength(style.width))
      .height(this.parseLength(style.height))
      .padding(this.parsePadding(style.padding))
      .margin(this.parseMargin(style.margin))
  }

  @Builder
  buildDefault(node: ZooTemplate, style: any) {
    Column() {
      Text(`Unsupported type: ${node.type}`)
        .fontSize(12)
        .fontColor('#FF0000')
    }
    .width(this.parseLength(style.width))
    .height(this.parseLength(style.height))
    .padding(this.parsePadding(style.padding))
    .margin(this.parseMargin(style.margin))
  }

  // 合并样式，考虑优先级：内联样式 > ID选择器 > 类选择器
  private getMergedStyle(node: ZooTemplate, linkStyles: Record<string, any>, forContext: Map<string, any>): any {
    const merged: any = {}

    // 类选择器样式
    if (node.class) {
      const classes = node.class.trim().split(/\s+/).filter(Boolean)
      classes.forEach(className => {
        const selector = '.' + className
        const classStyle = linkStyles[selector]
        if (classStyle) {
          Object.assign(merged, this.resolveStyle(classStyle, forContext))
        }
      })
    }

    // ID选择器样式
    if (node.id) {
      const idSelector = '#' + node.id
      const idStyle = linkStyles[idSelector]
      if (idStyle) {
        Object.assign(merged, this.resolveStyle(idStyle, forContext))
      }
    }

    // 内联样式（最高优先级）
    if (node.style) {
      Object.assign(merged, this.resolveStyle(node.style, forContext))
    }

    return merged
  }

  private resolveStyle(style: any, forContext: Map<string, any>): any {
    if (!style) {
      return {}
    }

    const resolved: any = {}
    for (const key in style) {
      const value = style[key]
      if (typeof value === 'string' && ZooParser.isBindingExpression(value)) {
        resolved[key] = this.resolveBinding(value, forContext)
      } else if (typeof value === 'object' && value !== null) {
        resolved[key] = this.resolveStyle(value, forContext)
      } else {
        resolved[key] = value
      }
    }
    return resolved
  }

  private resolveData(data: any, forContext: Map<string, any>): any {
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
          resolved[key] = this.resolveBinding(value, forContext)
        } else {
          resolved[key] = value
        }
      } else {
        resolved[key] = value
      }
    }
    return resolved
  }

  private resolveBinding(expression: string, forContext: Map<string, any>): any {
    const match = expression.match(/\{\{([^}]+)\}\}/)
    if (match) {
      const expr = match[1].trim()
      const context: Record<string, any> = {}

      for (const [key, value] of forContext) {
        context[key] = value
      }

      const data = this.manager.viewModel.getData()
      for (const key in data) {
        context[key] = data[key]
      }

      try {
        const keys = Object.keys(context)
        const values = Object.values(context)
        const func = new Function(...keys, `return ${expr}`)
        return func(...values)
      } catch (e) {
        ZooLogger.error(`Zoo: Failed to resolve binding ${expression}: ${e}`)
        return ''
      }
    }
    return expression
  }

  private resolveEvents(event: any): any {
    if (!event) {
      return {}
    }

    const resolved: any = {}
    for (const key in event) {
      const handler = event[key]
      if (typeof handler === 'string') {
        const methodName = handler.trim()
        if (this.manager && (this.manager as any)[methodName]) {
          resolved[key] = (this.manager as any)[methodName].bind(this.manager)
        } else {
          ZooLogger.warn(`Zoo: Event handler method ${methodName} not found`)
        }
      } else if (typeof handler === 'function') {
        resolved[key] = handler
      }
    }
    return resolved
  }

  private parseLength(value: any): Length {
    if (value === undefined || value === null || value === '') {
      return 'auto'
    }
    if (typeof value === 'number') {
      return value
    }
    if (typeof value === 'string') {
      if (value === 'auto' || value === 'match_content' || value.endsWith('%')) {
        return value
      }
      if (value.endsWith('px')) {
        return Number(value.replace('px', ''))
      }
      return value
    }
    return value
  }

  private parseFontSize(value: any): Length {
    if (typeof value === 'number') {
      return value
    }
    return this.parseLength(value)
  }

  private parsePadding(value: any): Length | LocalizedPadding {
    if (!value) {
      return 0
    }
    if (typeof value === 'number') {
      return value
    }
    if (typeof value === 'string') {
      return this.parseLength(value)
    }
    if (typeof value === 'object') {
      const vp = value as Record<string, any>
      return {
        top: this.parseLength(vp.top),
        bottom: this.parseLength(vp.bottom),
        left: this.parseLength(vp.left),
        right: this.parseLength(vp.right)
      }
    }
    return 0
  }

  private parseMargin(value: any): Length | LocalizedMargin {
    if (!value) {
      return 0
    }
    if (typeof value === 'number') {
      return value
    }
    if (typeof value === 'string') {
      return this.parseLength(value)
    }
    if (typeof value === 'object') {
      const vm = value as Record<string, any>
      return {
        top: this.parseLength(vm.top),
        bottom: this.parseLength(vm.bottom),
        left: this.parseLength(vm.left),
        right: this.parseLength(vm.right)
      }
    }
    return 0
  }

  private parseAlignItems(align: string): HorizontalAlign {
    switch (align?.toLowerCase()) {
      case 'start':
      case 'flexstart':
        return HorizontalAlign.Start
      case 'center':
        return HorizontalAlign.Center
      case 'end':
      case 'flexend':
        return HorizontalAlign.End
      default:
        return HorizontalAlign.Center
    }
  }

  private parseJustifyContent(justify: string): FlexAlign {
    switch (justify?.toLowerCase()) {
      case 'start':
      case 'flexstart':
        return FlexAlign.Start
      case 'center':
        return FlexAlign.Center
      case 'end':
      case 'flexend':
        return FlexAlign.End
      case 'spacearound':
        return FlexAlign.SpaceAround
      case 'spacebetween':
        return FlexAlign.SpaceBetween
      case 'spaceevenly':
        return FlexAlign.SpaceEvenly
      default:
        return FlexAlign.Start
    }
  }

  private parseAlignment(align: string): Alignment {
    switch (align?.toLowerCase()) {
      case 'top':
      case 'start':
        return Alignment.TopStart
      case 'topend':
        return Alignment.TopEnd
      case 'center':
        return Alignment.Center
      case 'bottomstart':
        return Alignment.BottomStart
      case 'bottom':
      case 'bottomend':
        return Alignment.BottomEnd
      default:
        return Alignment.Center
    }
  }

  private parseTextAlign(align: string): TextAlign {
    switch (align?.toLowerCase()) {
      case 'start':
        return TextAlign.Start
      case 'center':
        return TextAlign.Center
      case 'end':
        return TextAlign.End
      case 'justify':
        return TextAlign.JUSTIFY
      default:
        return TextAlign.Start
    }
  }

  private parseTextOverflow(overflow: string): Overflow {
    switch (overflow?.toLowerCase()) {
      case 'clip':
        return Overflow.Clip
      case 'ellipsis':
        return Overflow.Ellipsis
      case 'marquee':
        return Overflow.MARQUEE
      default:
        return Overflow.Clip
    }
  }

  private parseObjectFit(fit: string): ImageFit {
    switch (fit?.toLowerCase()) {
      case 'contain':
        return ImageFit.Contain
      case 'cover':
        return ImageFit.Cover
      case 'fill':
        return ImageFit.Fill
      case 'none':
        return ImageFit.None
      case 'scaledown':
        return ImageFit.ScaleDown
      case 'auto':
      default:
        return ImageFit.Auto
    }
  }

  private parseButtonType(type: string): ButtonType {
    switch (type?.toLowerCase()) {
      case 'normal':
        return ButtonType.Normal
      case 'circle':
        return ButtonType.Circle
      case 'capsule':
        return ButtonType.Capsule
      default:
        return ButtonType.Normal
    }
  }

  private parseDirection(dir: string): Direction {
    switch (dir?.toLowerCase()) {
      case 'rtl':
        return Direction.Rtl
      case 'ltr':
        return Direction.Ltr
      case 'auto':
      default:
        return Direction.Auto
    }
  }

  private parseWrap(wrap: string): FlexWrap {
    switch (wrap?.toLowerCase()) {
      case 'nowrap':
        return FlexWrap.NoWrap
      case 'wrap':
        return FlexWrap.Wrap
      case 'wrapreverse':
        return FlexWrap.WrapReverse
      default:
        return FlexWrap.NoWrap
    }
  }

  private parseAlignContent(align: string): FlexAlign {
    return this.parseJustifyContent(align)
  }

  private parseProgressType(type: string): ProgressType {
    switch (type?.toLowerCase()) {
      case 'linear':
        return ProgressType.Linear
      case 'circular':
        return ProgressType.Circular
      case 'ring':
        return ProgressType.Ring
      case 'eclipse':
        return ProgressType.Eclipse
      case 'scale':
        return ProgressType.Scale
      default:
        return ProgressType.Linear
    }
  }

  private parseSymbolRenderingStrategy(strategy: string): SymbolRenderingStrategy {
    switch (strategy?.toLowerCase()) {
      case 'single':
        return SymbolRenderingStrategy.SINGLE
      case 'multiple':
        return SymbolRenderingStrategy.MULTIPLE
      case 'hierarchical':
        return SymbolRenderingStrategy.HIERARCHICAL
      default:
        return SymbolRenderingStrategy.SINGLE
    }
  }

  private parseFontWeight(weight: string | number): FontWeight {
    if (typeof weight === 'number') {
      return weight as FontWeight
    }
    switch (weight?.toLowerCase()) {
      case 'normal':
        return FontWeight.Normal
      case 'bold':
        return FontWeight.Bold
      case 'bolder':
        return FontWeight.Bolder
      case 'lighter':
        return FontWeight.Lighter
      case 'medium':
        return FontWeight.Medium
      case 'regular':
        return FontWeight.Regular
      case 'w100':
        return FontWeight.W100
      case 'w200':
        return FontWeight.W200
      case 'w300':
        return FontWeight.W300
      case 'w400':
        return FontWeight.W400
      case 'w500':
        return FontWeight.W500
      case 'w600':
        return FontWeight.W600
      case 'w700':
        return FontWeight.W700
      case 'w800':
        return FontWeight.W800
      case 'w900':
        return FontWeight.W900
      default:
        return FontWeight.Normal
    }
  }

  private parseFontStyle(style: string): FontStyle {
    switch (style?.toLowerCase()) {
      case 'normal':
        return FontStyle.Normal
      case 'italic':
        return FontStyle.Italic
      default:
        return FontStyle.Normal
    }
  }
}
