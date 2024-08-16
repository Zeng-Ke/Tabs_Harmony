/**
 * author: ZK.
 * date:   On 2024-08-16.
 * desc:
 */

import { HashMap } from '@kit.ArkTS'


export class TabItemData {
  title?: string
  index: number = 0
  selectIndex: number = 0
}


export class ZTabScroller {
  tabScroll?: (value: number) => void;

  scrollTo(index: number) {
    if (this.tabScroll) {
      this.tabScroll(index);
    }
  }
}


@Component
export struct TabComponent {
  tabScroller?: ZTabScroller
  private scroller: Scroller = new Scroller()
  @State private scrollerMiddleX: number = 0
  @State indicatorWidth: number = 20
  @State tabDatas: Array<string> = []
  @State selectedIndex: number = 0
  onPageSelectChange?: (index: number) => void
  tabAreas = new HashMap<number, Area>()
  isFixedCenter: boolean = true

  aboutToAppear(): void {
    if (this.tabScroller) {
      this.tabScroller.tabScroll = (index: number) => {
          this.itemScrollCenter(index)
      }
    }

  }

  @Builder
  itemBuilder(item: TabItemData) {
  };

  @BuilderParam itemBuilderParam: (item: TabItemData) => void =
    this.itemBuilder;

  build() {
    Row() {
      Scroll(this.scroller) {
        Row() {
          ForEach(this.tabDatas, (item: string, index: number) => {
            Column() {
              this.itemBuilderParam({ title: item, index: index, selectIndex: this.selectedIndex })
            }
            .onClick(() => {
              this.itemScrollCenter(index)
              this.onPageSelectChange?.(index)
            })
            .onAreaChange((old, newArea) => {
              this.tabAreas.set(index, newArea)
            })

          })
        }

      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .onAreaChange((oldValue, newValue) => {
        this.scrollerMiddleX = (newValue.width as number) / 2
      })
    }.width(this.isFixedCenter?`auto`:`100%`)
  }

  itemScrollCenter(index: number) {
    this.selectedIndex = index
    const selectedArea = this.tabAreas.get(index)
    const targetMiddleX = (selectedArea.width as number) / 2 + (selectedArea.globalPosition.x as number)
    const scrollOffsetX = targetMiddleX - this.scrollerMiddleX
    this.scroller.scrollTo({
      xOffset: this.scroller.currentOffset().xOffset + scrollOffsetX,
      yOffset: 0,
      animation: { duration: 500 }
    })

  }
}