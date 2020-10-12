## ![kite logo](https://github.com/HYbutterfly/kite/wiki/image/kite_logo.png)

Kite is a simple 2d game engine for Lua

## Build (for windows mingw)
```
可以参考 wiki 环境搭建 (以前写的)
但是需要先编译3rd/lua-5.4.0
其实仓库里都已经把lua 和 引擎编译好了, 所以可以直接进行下面的 Test
```

## Test
```
运行 start_helloworld.sh
```

## 简单讲讲 (由于还在开发中, 所以讲讲思路 和 路线, 具体 API 文档暂时不会提供)
```
kite 非常小, 不算 lua54.dll, kite.exe 目前只有 365KB
kite 是 c + lua 的引擎 (base lua5.4), 我尝试过用lua当主程序的方案,但是不太稳定, 就放弃了.
内核代码沿用了18年 kite 0.1的版本, 小有修改
kite 定位 轻量 2D 引擎, 内部只有一个sprite2d的渲染对象, 内部自动合批处理 (前提是 shader program 和 texture 不变)
kite 的坐标系 是笛卡尔坐标系, 别问为什么, 问就是巧合
这些天主要开发了 UI的场景树, 目前已实现的 UI 有 Sprite Label Button
场景节点可以绑定 lua 脚本, eg: examples/helloworld/Game.lua
基本开发流程与现代游戏引擎类似了 (比如 Godot)
```

## 接下来
```
音频功能的支持, 之前做过, 所以加上 也会很快 基于 openal
安卓的支持, 需要研究一下, 小白一个
编辑器开发, 用自己实现一个编辑自己的 【编辑器】 (场景树在运行时, 并不会破坏它的结构, 这将很简单的把当前场景树 dump 下来)
网络模块的增加, 应该会直接用成熟的 luasocket
我打算用这个开发一个比较完整的斗地主, 开发中完善需要的 UI
```


## 捐赠 
```
个人项目, 着实不易, 如果你对这个项目感兴趣, 并有能力的话, 可以赞助一下下, 作者将会更有动力开发下去 :)
```
<img src="https://raw.githubusercontent.com/HYbutterfly/Fantasy-scorpio-donation/master/wechatpay.png" align="left" height="400" width="300">
<img src="https://raw.githubusercontent.com/HYbutterfly/Fantasy-scorpio-donation/master/alipay.png" height="400" width="300">


## Donors
```
1. *亮        2018/11/13
2. Cabrite    2018/11/13
3. *笑        2018/12/24
```
