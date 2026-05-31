import { ZooLogger } from '../common/ZooLogger'
import { ZooTemplate, ZNode, DataModel } from './ZooTemplate'
import { ZooManager } from './ZooManager'
import { TemplateRegistry } from './TemplateRegistry'
import { ZNodeTreeBuilder } from './ZNodeTreeBuilder'
import {
  Column,
  Row,
  Stack,
  Text,
  Image,
  Button,
  LoadingProgress,
  Flex,
  TextInput,
  Checkbox,
  Radio,
  Switch,
  Slider,
  Progress,
  Divider,
  Badge,
  SymbolGlyph
} from '@kit.ArkUI'
import { Length } from '@kit.ArkGraphics2D'

/**
 * 样式转换器 - 将JSON样式转换为ArkUI属性
 */
class StyleConverter {
  static convert(style: any): any {
    if (!style) return {}
    const converted: any = {}

    for (const key in style) {
      const value = style[key]
      const arkKey = this.camelCase(key)
      
      if (key.includes('-')) {
        converted[arkKey] = value
      } else {
        converted[key] = value
      }
    }

    return converted
  }

  private static camelCase(str: string): string {
    return str.replace(/-([a-z])/g, (_, letter) => letter.toUpperCase())
  }
}

@Component
export struct Zoo {
  @Prop manager: ZooManager
  @State rootZNode: ZNode | null = null
  @State isLoading: boolean = true
  @State updateKey: number = 0

  aboutToAppear() {
    ZooLogger.info('Zoo component aboutToAppear')
    this.loadTemplateAndData()
    this.manager.viewModel.subscribe('*', this.onDataChange.bind(this))
  }

  aboutToDisappear() {
    ZooLogger.info('Zoo component aboutToDisappear')
    this.manager.viewModel.unsubscribe('*', this.onDataChange.bind(this))
  }

  onDataChange() {
    this.updateKey++
    this.buildZNodeTree()
    ZooLogger.debug('Zoo component: Data changed, ZNode tree rebuilt')
  }

  async loadTemplateAndData() {
    this.isLoading = true
    try {
      await this.manager.loadInitialData()
      this.buildZNodeTree()
    } catch (error) {
      ZooLogger.error(`Zoo: Failed to load template and data - ${error}`)
    } finally {
      this.isLoading = false
    }
  }

  buildZNodeTree() {
    const viewModelData = this.manager.viewModel.getData()
    let template: ZooTemplate | null = null

    if (viewModelData && (viewModelData as any).template) {
      const templateName = (viewModelData as any).template as string
      template = TemplateRegistry.getTemplate(templateName)
      if (template) {
        ZooLogger.info(`Zoo: Using registered template ${templateName}`)
      }
    }

    if (template) {
      const dataModel: DataModel = {
        data: viewModelData
      }
      const treeBuilder = new ZNodeTreeBuilder()
      this.rootZNode = treeBuilder.build(template, dataModel)
    } else {
      ZooLogger.warn('Zoo: No template found')
      this.rootZNode = null
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
    } else if (this.rootZNode) {
      this.buildZNode(this.rootZNode)
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
  buildZNode(znode: ZNode) {
    const type = znode.type.toLowerCase()
    const style = StyleConverter.convert(znode.style)
    const event = znode.event || {}

    switch (type) {
      case 'column':
        this.buildColumn(znode, style, event)
        break
      case 'row':
        this.buildRow(znode, style, event)
        break
      case 'stack':
        this.buildStack(znode, style, event)
        break
      case 'flex':
        this.buildFlex(znode, style, event)
        break
      case 'text':
        this.buildText(znode, style)
        break
      case 'image':
        this.buildImage(znode, style)
        break
      case 'button':
        this.buildButton(znode, style, event)
        break
      case 'input':
      case 'textinput':
        this.buildTextInput(znode, style, event)
        break
      case 'checkbox':
        this.buildCheckbox(znode, style, event)
        break
      case 'radio':
        this.buildRadio(znode, style, event)
        break
      case 'switch':
        this.buildSwitch(znode, style, event)
        break
      case 'slider':
        this.buildSlider(znode, style, event)
        break
      case 'progress':
        this.buildProgress(znode, style)
        break
      case 'loading':
      case 'loadingprogress':
        this.buildLoadingProgress(znode, style)
        break
      case 'divider':
        this.buildDivider(znode, style)
        break
      case 'badge':
        this.buildBadge(znode, style)
        break
      case 'symbol':
        this.buildSymbol(znode, style)
        break
      default:
        this.buildDefault(znode)
    }
  }

  @Builder
  buildColumn(znode: ZNode, style: any, event: any) {
    Column() {
      if (znode.children) {
        ForEach(znode.children, (child: ZNode) => {
          this.buildZNode(child)
        })
      }
    }
    .width(style.width)
    .height(style.height)
    .padding(style.padding)
    .margin(style.margin)
    .backgroundColor(style.backgroundColor)
    .borderStyle(style.borderStyle)
    .borderWidth(style.borderWidth)
    .borderColor(style.borderColor)
    .borderRadius(style.borderRadius)
    .alignItems(this.parseAlignItems(style.alignItems))
    .justifyContent(this.parseJustifyContent(style.justifyContent))
    .onClick(this.resolveEventHandler(event.onClick))
    .onTouch(this.resolveEventHandler(event.onTouch))
    .onHover(this.resolveEventHandler(event.onHover))
    .key(this.updateKey)
  }

  @Builder
  buildRow(znode: ZNode, style: any, event: any) {
    Row() {
      if (znode.children) {
        ForEach(znode.children, (child: ZNode) => {
          this.buildZNode(child)
        })
      }
    }
    .width(style.width)
    .height(style.height)
    .padding(style.padding)
    .margin(style.margin)
    .backgroundColor(style.backgroundColor)
    .borderStyle(style.borderStyle)
    .borderWidth(style.borderWidth)
    .borderColor(style.borderColor)
    .borderRadius(style.borderRadius)
    .alignItems(this.parseAlignItems(style.alignItems))
    .justifyContent(this.parseJustifyContent(style.justifyContent))
    .onClick(this.resolveEventHandler(event.onClick))
    .onTouch(this.resolveEventHandler(event.onTouch))
    .onHover(this.resolveEventHandler(event.onHover))
    .key(this.updateKey)
  }

  @Builder
  buildStack(znode: ZNode, style: any, event: any) {
    Stack() {
      if (znode.children) {
        ForEach(znode.children, (child: ZNode) => {
          this.buildZNode(child)
        })
      }
    }
    .width(style.width)
    .height(style.height)
    .padding(style.padding)
    .margin(style.margin)
    .backgroundColor(style.backgroundColor)
    .alignContent(this.parseAlignment(style.alignContent))
    .onClick(this.resolveEventHandler(event.onClick))
    .key(this.updateKey)
  }

  @Builder
  buildFlex(znode: ZNode, style: any, event: any) {
    Flex() {
      if (znode.children) {
        ForEach(znode.children, (child: ZNode) => {
          this.buildZNode(child)
        })
      }
    }
    .width(style.width)
    .height(style.height)
    .padding(style.padding)
    .margin(style.margin)
    .backgroundColor(style.backgroundColor)
    .direction(this.parseDirection(style.direction))
    .wrap(this.parseWrap(style.wrap))
    .justifyContent(this.parseJustifyContent(style.justifyContent))
    .alignItems(this.parseAlignItems(style.alignItems))
    .alignContent(this.parseAlignContent(style.alignContent))
    .onClick(this.resolveEventHandler(event.onClick))
    .key(this.updateKey)
  }

  @Builder
  buildText(znode: ZNode, style: any) {
    Text(znode.data?.content || '')
      .id(znode.id || '')
      .fontSize(style.fontSize || style['font-size'])
      .fontWeight(this.parseFontWeight(style.fontWeight))
      .fontStyle(this.parseFontStyle(style.fontStyle))
      .fontFamily(style.fontFamily || 'HarmonyOS Sans')
      .fontColor(style.fontColor || style['font-color'] || style.color || '#000000')
      .textAlign(this.parseTextAlign(style.textAlign))
      .maxLines(style.maxLines || 999)
      .textOverflow({ overflow: this.parseTextOverflow(style.textOverflow) })
      .width(style.width)
      .height(style.height)
      .padding(style.padding)
      .margin(style.margin)
      .backgroundColor(style.backgroundColor)
      .borderStyle(style.borderStyle)
      .borderWidth(style.borderWidth)
      .borderColor(style.borderColor)
      .borderRadius(style.borderRadius)
      .key(this.updateKey)
  }

  @Builder
  buildImage(znode: ZNode, style: any) {
    Image(znode.data?.src || '')
      .id(znode.id || '')
      .width(style.width || 100)
      .height(style.height || 100)
      .padding(style.padding)
      .margin(style.margin)
      .backgroundColor(style.backgroundColor)
      .borderStyle(style.borderStyle)
      .borderWidth(style.borderWidth)
      .borderColor(style.borderColor)
      .borderRadius(style.borderRadius)
      .objectFit(this.parseObjectFit(style.objectFit))
      .alt(style.alt || '')
      .key(this.updateKey)
  }

  @Builder
  buildButton(znode: ZNode, style: any, event: any) {
    Button(znode.data?.label || 'Button', { type: this.parseButtonType(style.buttonType) })
      .id(znode.id || '')
      .width(style.width)
      .height(style.height)
      .padding(style.padding)
      .margin(style.margin)
      .fontSize(style.fontSize || style['font-size'])
      .fontWeight(this.parseFontWeight(style.fontWeight))
      .fontColor(style.fontColor || style['font-color'] || style.color || '#FFFFFF')
      .backgroundColor(style.backgroundColor || '#4CAF50')
      .borderStyle(style.borderStyle)
      .borderWidth(style.borderWidth)
      .borderColor(style.borderColor)
      .borderRadius(style.borderRadius || 10)
      .onClick(this.resolveEventHandler(event.onClick))
      .onTouch(this.resolveEventHandler(event.onTouch))
      .onHover(this.resolveEventHandler(event.onHover))
      .key(this.updateKey)
  }

  @Builder
  buildTextInput(znode: ZNode, style: any, event: any) {
    TextInput({ placeholder: znode.data?.placeholder, text: znode.data?.text || '' })
      .id(znode.id || '')
      .width(style.width)
      .height(style.height || 40)
      .padding(style.padding)
      .margin(style.margin)
      .fontSize(style.fontSize || style['font-size'])
      .fontColor(style.fontColor || style['font-color'] || style.color || '#000000')
      .placeholderColor(style.placeholderColor || '#999999')
      .backgroundColor(style.backgroundColor || '#FFFFFF')
      .borderStyle(style.borderStyle)
      .borderWidth(style.borderWidth)
      .borderColor(style.borderColor)
      .borderRadius(style.borderRadius || 8)
      .onChange(this.resolveEventHandler(event.onChange))
      .onFocus(this.resolveEventHandler(event.onFocus))
      .onBlur(this.resolveEventHandler(event.onBlur))
      .key(this.updateKey)
  }

  @Builder
  buildCheckbox(znode: ZNode, style: any, event: any) {
    Checkbox()
      .id(znode.id || '')
      .width(style.width)
      .height(style.height)
      .padding(style.padding)
      .margin(style.margin)
      .select(znode.data?.checked || false)
      .selectedColor(style.selectedColor || '#4CAF50')
      .onChange(this.resolveEventHandler(event.onChange))
      .key(this.updateKey)
  }

  @Builder
  buildRadio(znode: ZNode, style: any, event: any) {
    Radio({ value: znode.data?.value || '', group: znode.data?.group || '' })
      .id(znode.id || '')
      .width(style.width)
      .height(style.height)
      .padding(style.padding)
      .margin(style.margin)
      .checked(znode.data?.checked || false)
      .onChange(this.resolveEventHandler(event.onChange))
      .key(this.updateKey)
  }

  @Builder
  buildSwitch(znode: ZNode, style: any, event: any) {
    Switch()
      .id(znode.id || '')
      .width(style.width)
      .height(style.height)
      .padding(style.padding)
      .margin(style.margin)
      .checked(znode.data?.checked || false)
      .selectedColor(style.selectedColor || '#4CAF50')
      .onChange(this.resolveEventHandler(event.onChange))
      .key(this.updateKey)
  }

  @Builder
  buildSlider(znode: ZNode, style: any, event: any) {
    Slider({ 
      value: znode.data?.value || 0, 
      min: znode.data?.min || 0, 
      max: znode.data?.max || 100, 
      step: znode.data?.step || 1 
    })
      .id(znode.id || '')
      .width(style.width)
      .height(style.height)
      .padding(style.padding)
      .margin(style.margin)
      .blockColor(style.blockColor || '#4CAF50')
      .trackColor(style.trackColor || '#E0E0E0')
      .selectedColor(style.selectedColor || '#4CAF50')
      .onChange(this.resolveEventHandler(event.onChange))
      .key(this.updateKey)
  }

  @Builder
  buildProgress(znode: ZNode, style: any) {
    Progress({ 
      value: znode.data?.value || 0, 
      total: znode.data?.total || 100, 
      type: this.parseProgressType(style.type) 
    })
      .id(znode.id || '')
      .width(style.width || 200)
      .height(style.height || 10)
      .padding(style.padding)
      .margin(style.margin)
      .color(style.color || '#4CAF50')
      .backgroundColor(style.backgroundColor || '#E0E0E0')
      .key(this.updateKey)
  }

  @Builder
  buildLoadingProgress(znode: ZNode, style: any) {
    LoadingProgress()
      .id(znode.id || '')
      .width(style.width || 48)
      .height(style.height || 48)
      .padding(style.padding)
      .margin(style.margin)
      .color(style.color || '#4CAF50')
      .key(this.updateKey)
  }

  @Builder
  buildDivider(znode: ZNode, style: any) {
    Divider()
      .id(znode.id || '')
      .width(style.width || '100%')
      .height(style.height || 1)
      .padding(style.padding)
      .margin(style.margin)
      .vertical(style.vertical || false)
      .color(style.color || '#E0E0E0')
      .strokeWidth(style.strokeWidth || 1)
      .key(this.updateKey)
  }

  @Builder
  buildBadge(znode: ZNode, style: any) {
    Badge({
      count: znode.data?.count || 0,
      style: {
        badgeSize: style.badgeSize || 12,
        badgeColor: style.badgeColor || '#FF0000'
      }
    }) {
      if (znode.children && znode.children.length > 0) {
        this.buildZNode(znode.children[0])
      }
    }
    .id(znode.id || '')
    .key(this.updateKey)
  }

  @Builder
  buildSymbol(znode: ZNode, style: any) {
    SymbolGlyph(znode.data?.value || $r('sys.symbol.oh_logo'))
      .id(znode.id || '')
      .fontSize(style.fontSize || style['font-size'] || 24)
      .fontColor(style.fontColor || style['font-color'] || '#000000')
      .renderingStrategy(this.parseSymbolRenderingStrategy(style.renderingStrategy))
      .width(style.width)
      .height(style.height)
      .padding(style.padding)
      .margin(style.margin)
      .key(this.updateKey)
  }

  @Builder
  buildDefault(znode: ZNode) {
    Column() {
      Text(`Unsupported type: ${znode.type}`)
        .fontSize(12)
        .fontColor('#FF0000')
    }
    .key(this.updateKey)
  }

  private resolveEventHandler(handler: any): any {
    if (typeof handler === 'string') {
      const methodName = handler.trim()
      if (this.manager && (this.manager as any)[methodName]) {
        return (this.manager as any)[methodName].bind(this.manager)
      } else {
        ZooLogger.warn(`Zoo: Event handler method ${methodName} not found`)
      }
    } else if (typeof handler === 'function') {
      return handler
    }
    return undefined
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
