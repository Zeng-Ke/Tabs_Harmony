
最近写鸿蒙项目时，需要用到类似Android的TabLayout控件，鸿蒙官方也有提供类似实现的组件Tabs。但是官方Tabs组件，实在有点鸡肋，首先 TabContent和 TabBar是绑定在一起的放在Tabs里面的，如果UI是TabBar的背景是一个整体的，这时就受限了。另一个最令人吐槽的是，这个TabBar无法设置居左显示，它是默认居中的。 
好吧，既然官方没有，就只能自己手动去实现了。
先看下效果：
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/655a1db2047b407fb4d00917ba3824b5.gif#pic_center)




**一、首先，需要分析Tab组件点击滚动时的交互， 需要把目标Tab滚动到屏幕中间为止，那么就要计算 组件中线与屏幕中间的位置，从而得出需要滚动的距离，看下图会比较直观**：

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b8eeafff083a43c681029b528352136f.png#pic_center)
那么就要首先要保存好每个Tab的坐标信息：

```javascript
 @State tabDatas: Array<string> = []

// tab ： 保存好每个Tab的坐标信息
 .onAreaChange((old, newArea) => {
              this.tabAreas.set(index, newArea)
            })
            
// scroll： 获取scroll组件的中线位置（屏幕的中线x坐标）
 .onAreaChange((oldValue, newValue) => {
        this.scrollerMiddleX = (newValue.width as number) / 2
      })
```

然后拿中线x坐标减去屏幕的中线x坐标 得到的就是 Tab需要滚动中间距离：

```javascript
 const selectedArea = this.tabAreas.get(index)
 const targetMiddleX = (selectedArea.width as number) / 2 + (selectedArea.globalPosition.x as number)
 const scrollOffsetX = targetMiddleX - this.scrollerMiddleX //滚动中间距离
 this.scroller.scrollTo({
      xOffset: this.scroller.currentOffset().xOffset + scrollOffsetX,//使用scrollTo,所以需要加上原有的偏移位置
      yOffset: 0,
      animation: { duration: 500 }
    })
 
```
至此，滚动功能就已经实现了。


**二、然后就到Item组件的实现了，因为组件的样式是不确定的，需要交由外部去实现，这时就需要用到@BuilderParam了。**
还有注意@BuilderParam如果需要按引用传递，需要把所有参数打包成一个对象，变量的改下才能传递触发事件

```javascript
export class TabItemParam {
  item?: string
  index: number = 0
  selectIndex: number = 0
}

 @Builder
  itemBuilder(item: TabItemParam ) {
  };

  @BuilderParam itemBuilderParam: (item: TabItemParam ) => void =
    this.itemBuilder;

...
 ForEach(this.tabDatas, (item: string, index: number) => {
            Column() {
              this.itemBuilderParam({ item: item, index: index, selectIndex: this.selectedIndex })
            }
            ...
          })
...

```

**三、就是需要提供一个方法给外部去调用，触发滚动到指定的Tab。（不得不说，习惯了Android直接操作对象的方法的方式， 鸿蒙这种操作组件方法，实在有点绕。如果大家有其它更方便快捷的方式，可以评论分享下）**

首先需要先定义一个Scroller，并且定义好一个给组件内部实现的方法A，一个给外部调用的方法B，并且 方法B内部是调用了方法A：

```javascript
export class ZTabScroller {
  tabScroll?: (value: number) => void;

  scrollTo(index: number) {
    if (this.tabScroll) {
      this.tabScroll(index);
    }
  }
}
```

然后Tab在内部定义好scroller变量，并且在生命周期aboutToAppear()时定义好Scroller的方法A

```javascript
  tabScroller?: TabScroller

  aboutToAppear(): void {
    if (this.tabScroller) {
      this.tabScroller.tabScroll = (index: number) => {
        this.itemScrollCenter(index)  //触发滚动到指定Tab的方法
      }
    }
  }


```
这样外部就可以创建TabScroller对象，赋值给Tab组件，并且可调用scrollTo方法从而触发Tab内部的itemScrollCenter（index）方法了


**四：外部使用**

搭配上Swiper组件， 并关联上selectedIndex就可以达到效果啦。

```javascript
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

//加上一个字体的选中和放大的动画效果
@AnimatableExtend(Text)
function animatableFontSize(fontSize: Length) {
  .fontSize(fontSize)
}
```


至此，就完成整个效果了。

完整代码：
[https://github.com/Zeng-Ke/Tabs_Harmony](https://github.com/Zeng-Ke/Tabs_Harmony)
