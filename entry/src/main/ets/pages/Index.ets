import { TabComponent, TabItemData, ZTabScroller as TabScroller } from '../TabComponent';

@AnimatableExtend(Text)
function animatableFontSize(fontSize: Length) {
  .fontSize(fontSize)
}

@Entry
@Component
struct Index {


  tabsData: Array<string> = []
  @State selectedIndex: number = 0
  @State pagerIndex: number = 1
  tabScroller = new TabScroller()

  aboutToAppear(): void {

    this.tabsData.push('tab1')
    this.tabsData.push('tab2')
    this.tabsData.push('tab3')


  }

  build() {
   Column(){
     TabComponent({
       tabDatas: this.tabsData,
       selectedIndex: this.pagerIndex,
       tabScroller: this.tabScroller,
       itemBuilderParam: this.tabItemBuilder,
       isFixedCenter:false,
       onPageSelectChange: (index) => {
         this.pagerIndex = index
       }
     })


     Swiper() {
       this.swiperItem(`0`,Color.Green)
       this.swiperItem(`1`,Color.Red)
       this.swiperItem(`2`,Color.Orange)
     }
     .index(this.pagerIndex)
     .loop(false)
     .indicator(false)
     .onAnimationStart((index: number, targetIndex: number) => {
       this.tabScroller.scrollTo(targetIndex)
     })
     .padding({top:10})
     .height('100%')
     .width('100%')

   }
   .padding({top:20})
    .height('100%')
    .width('100%')
  }


  @Builder
  swiperItem(text:string,color:ResourceColor){
    Text(text)
      .width('100%')
      .height('100%')
      .backgroundColor(color)
      .textAlign(TextAlign.Center)
      .fontSize(30)

  }

  @Builder
  tabItemBuilder(item: TabItemData) {
    Column() {
      Text(item.title)
        .height(25)
        .fontSize(15)
        .textAlign(TextAlign.Center)
        .fontColor(item.index == item.selectIndex ? Color.Red : Color.Black)
        .margin({ left: 15, right: 15 })
        .animatableFontSize(item.index == item.selectIndex ? 20 : 15)
        .animation({ duration: 300, curve: Curve.Ease })

      if (item.index == item.selectIndex) {
        Blank()
          .backgroundColor(Color.Blue)
          .width(20)
          .height(3)
          .margin({ top: 5 })
          .borderRadius(2)
      }
    }
  };
}