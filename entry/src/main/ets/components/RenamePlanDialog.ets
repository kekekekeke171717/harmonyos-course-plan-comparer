// 方案重命名对话框
@CustomDialog
export struct RenamePlanDialog {
  controller?: CustomDialogController
  initialValue: string = ''
  onConfirm: (newName: string) => void = (newName: string): void => {}
  @State inputValue: string = ''

  aboutToAppear(): void {
    this.inputValue = this.initialValue
  }

  confirm(): void {
    const name = this.inputValue.trim()
    if (name) {
      this.onConfirm(name)
    }
    this.controller?.close()
  }

  build() {
    Column() {
      Text('重命名方案')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2937')
        .width('100%')

      TextInput({ text: this.inputValue })
        .width('100%')
        .height(40)
        .fontSize(14)
        .margin({ top: 14 })
        .onChange((v: string): void => { this.inputValue = v })

      Row() {
        Button('取消')
          .layoutWeight(1)
          .height(36)
          .fontSize(13)
          .backgroundColor('#F3F4F6')
          .fontColor('#374151')
          .onClick((): void => this.controller?.close())
        Button('确定')
          .layoutWeight(1)
          .height(36)
          .fontSize(13)
          .backgroundColor('#4F8AF7')
          .margin({ left: 10 })
          .onClick((): void => this.confirm())
      }
      .width('100%')
      .margin({ top: 16 })
    }
    .width(320)
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
  }
}
