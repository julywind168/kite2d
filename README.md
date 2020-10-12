## ![kite logo](https://github.com/HYbutterfly/kite/wiki/image/kite_logo.png)

Kite is a simple cross-platform 2d game engine for Lua

## Build & Test (for windows mingw)
```
见 Wiki 环境搭建
```

## 概述
```
kite 是基于 c + lua(5.4) 的 跨平台2D游戏引擎
```

## UI
```
kite.ui 是正在开发中的一套 纯lua ui模块, 已经实现了 sprite, label, button. 
该模块基于数据驱动, 节点可以挂载脚本. 开发流程与 godot, unity 类似
```
 
## Android Support (文档待 wiki 完善)
```
目前已经完成了安卓的开发, 安卓assets资源并不能直接使用, 为了方便我在初次启动时将assets中的资源都拷贝到了文件系统
```

## 路线图 (不分先后)
```
资源: 安卓中 拷贝assets的实现只是个暂时方案, 最终还是要实现自己的 Assets Loader
文本: 目前的文本只支持 位图字体(Bitmap Font), 在缩放时会比较糊, 后面应该还是会加入 FreeType 支持
多线程: 异步加载资源 或者网络IO, 都需要用到多线程, 构想中的实现类似于 一个thread 持有一个lua vm,
	可以像 skynet service 一样, 被 call 和 send
音频: 用的是openAL (只支持 ogg), 目前的问题是加载背景音乐会卡住几秒, 目前优化方案有 1.流式播放 2.单独放到一个线程
UI & 编辑器: 要做编辑器需要先实现很多 ui, 比如 输入框, 选择框, ... 慢慢来把 
IOS MAC支持: 等我有了 MAC 和 APPLE 后再说把
```

## 捐赠 
```
如果你对这个项目感兴趣, 并有能力的话, 可以选择赞助一杯咖啡 :)
```
<img src="https://raw.githubusercontent.com/HYbutterfly/Fantasy-scorpio-donation/master/wechatpay.png" align="left" height="400" width="300">
<img src="https://raw.githubusercontent.com/HYbutterfly/Fantasy-scorpio-donation/master/alipay.png" height="400" width="300">


## Donors
```
*笑        2018/12/24
*亮        2018/11/13
Cabrite    2018/11/13
```
