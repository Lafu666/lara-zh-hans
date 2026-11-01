//
//  dirtyZeroTweakArray.swift
//  lara
//
//  Created by lunginspector on 5/14/26.
//  you'll never guess where i got this one from...
//

import SwiftUI

struct ZeroSection: Identifiable, Equatable, Encodable, Decodable {
    var id: String { name }
    var name: String
    var icon: String
    var isExpanded: Bool = true
    var tweaks: [ZeroTweak]
}

struct ZeroTweak: Identifiable, Equatable, Encodable, Decodable {
    var id: String { name }
    var name: String
    var icon: String
    var minSupportedVersion: Double = 0.0
    var maxSupportedVersion: Double = 99.0
    var isOn: Bool = false
    var paths: [String]
}

enum TweakArray {
    static var tweaks: [ZeroSection] = [
        ZeroSection(name: "主屏幕", icon: "house", tweaks: [
            ZeroTweak(name: "隐藏 Dock 背景", icon: "dock.rectangle", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/CoreMaterial.framework/dockDark.materialrecipe", "/System/Library/PrivateFrameworks/CoreMaterial.framework/dockLight.materialrecipe"]),
            ZeroTweak(name: "清除文件夹背景", icon: "folder", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/SpringBoardHome.framework/folderDark.materialrecipe", "/System/Library/PrivateFrameworks/SpringBoardHome.framework/folderLight.materialrecipe"]),
            ZeroTweak(name: "清除小组件设置背景", icon: "square.text.square", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/SpringBoardHome.framework/stackConfigurationBackground.materialrecipe", "/System/Library/PrivateFrameworks/SpringBoardHome.framework/stackConfigurationForeground.materialrecipe"]),
            ZeroTweak(name: "清除 App 资源库背景", icon: "square.dashed", minSupportedVersion: 18.0, maxSupportedVersion: 26.9, paths: ["/System/Library/PrivateFrameworks/SpringBoardHome.framework/coplanarLeadingTrailingBackgroundBlur.materialrecipe"]),
            ZeroTweak(name: "清除资源库搜索背景", icon: "magnifyingglass", minSupportedVersion: 18.0, maxSupportedVersion: 26.9, paths: ["/System/Library/PrivateFrameworks/SpringBoardHome.framework/homeScreenOverlay.materialrecipe"]),
            ZeroTweak(name: "清除聚焦搜索背景", icon: "rectangle.and.text.magnifyingglass", minSupportedVersion: 16.0, maxSupportedVersion: 26.9, paths: ["/System/Library/PrivateFrameworks/SpringBoardHome.framework/knowledgeBackgroundDarkZoomed.descendantrecipe", "/System/Library/PrivateFrameworks/SpringBoardHome.framework/knowledgeBackgroundZoomed.descendantrecipe"]),
            ZeroTweak(name: "隐藏删除图标", icon: "xmark", minSupportedVersion: 16.0, maxSupportedVersion: 26.9, paths: ["/System/Library/PrivateFrameworks/SpringBoardHome.framework/Assets.car"])
        ]),
        ZeroSection(name: "锁屏", icon: "lock", tweaks: [
            ZeroTweak(name: "清除密码界面背景", icon: "ellipsis.rectangle", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/CoverSheet.framework/dashBoardPasscodeBackground.materialrecipe"]),
            ZeroTweak(name: "隐藏锁图标", icon: "lock", minSupportedVersion: 16.0, maxSupportedVersion: 26.9, paths: ["/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/lock@2x-812h.ca/main.caml", "/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/lock@2x-896h.ca/main.caml", "/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/lock@3x-812h.ca/main.caml", "/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/lock@3x-896h.ca/main.caml", "/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/lock@3x-d73.ca/main.caml"]),
            ZeroTweak(name: "隐藏快捷操作图标", icon: "flashlight.off.fill", minSupportedVersion: 16.0, maxSupportedVersion: 17.9, paths: ["/System/Library/PrivateFrameworks/CoverSheet.framework/Assets.car"]),
            ZeroTweak(name: "隐藏大号电池图标", icon: "bolt", minSupportedVersion: 18.0, maxSupportedVersion: 26.9, paths: ["/System/Library/PrivateFrameworks/CoverSheet.framework/Assets.car"])
        ]),
        ZeroSection(name: "提醒与浮层", icon: "platter.filled.top.iphone", tweaks: [
            ZeroTweak(name: "清除通知与小组件背景", icon: "platter.filled.top.iphone", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/CoreMaterial.framework/platterStrokeLight.visualstyleset", "/System/Library/PrivateFrameworks/CoreMaterial.framework/platterStrokeDark.visualstyleset", "/System/Library/PrivateFrameworks/CoreMaterial.framework/plattersDark.materialrecipe", "/System/Library/PrivateFrameworks/CoreMaterial.framework/platters.materialrecipe", "/System/Library/PrivateFrameworks/UserNotificationsUIKit.framework/stackDimmingLight.visualstyleset", "/System/Library/PrivateFrameworks/UserNotificationsUIKit.framework/stackDimmingDark.visualstyleset"]),
            ZeroTweak(name: "蓝色通知阴影", icon: "paintpalette", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: [
                "/System/Library/PrivateFrameworks/PlatterKit.framework/platterVibrantShadowLight.visualstyleset", "/System/Library/PrivateFrameworks/PlatterKit.framework/platterVibrantShadowDark.visualstyleset"]),
            ZeroTweak(name: "清除触控与提醒背景", icon: "list.bullet.rectangle", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/CoreMaterial.framework/platformContentDark.materialrecipe", "/System/Library/PrivateFrameworks/CoreMaterial.framework/platformContentLight.materialrecipe"]),
            ZeroTweak(name: "隐藏主屏幕横条", icon: "line.3.horizontal", minSupportedVersion: 16.0, maxSupportedVersion: 26.9, paths: ["/System/Library/PrivateFrameworks/MaterialKit.framework/Assets.car"]),
            ZeroTweak(name: "移除玻璃质感浮层", icon: "text.rectangle.page", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/CoreMaterial.framework/platformChromeDark.materialrecipe", "/System/Library/PrivateFrameworks/CoreMaterial.framework/platformChromeLight.materialrecipe"]),
            ZeroTweak(name: "清除多任务切换背景", icon: "switch.programmable", minSupportedVersion: 16.0, maxSupportedVersion: 26.9, paths: ["/System/Library/PrivateFrameworks/SpringBoard.framework/homeScreenBackdrop-application.materialrecipe", "/System/Library/PrivateFrameworks/SpringBoard.framework/homeScreenBackdrop-switcher.materialrecipe"])
        ]),
        ZeroSection(name: "字体与图标", icon: "paintbrush", tweaks: [
            ZeroTweak(name: "启用 Helvetica 字体", icon: "character.cursor.ibeam", minSupportedVersion: 17.0, maxSupportedVersion: 26.9, paths: ["/System/Library/Fonts/Core/SFUI.ttf"]),
            ZeroTweak(name: "启用 Helvetica 字体 ", icon: "character.cursor.ibeam", minSupportedVersion: 16.0, maxSupportedVersion: 16.9, paths: ["/System/Library/Fonts/CoreUI/SFUI.ttf"]),
            ZeroTweak(name: "禁用表情符号", icon: "circle.slash", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/Fonts/CoreAddition/AppleColorEmoji-160px.ttc"]),
            ZeroTweak(name: "隐藏静音图标", icon: "bell.slash", minSupportedVersion: 16.0, maxSupportedVersion: 26.9, paths: ["/System/Library/PrivateFrameworks/SpringBoard.framework/Ringer-Leading-D73.ca/main.caml"]),
            ZeroTweak(name: "隐藏个人热点图标", icon: "link", minSupportedVersion: 16.0, maxSupportedVersion: 26.9, paths: ["/System/Library/PrivateFrameworks/SpringBoard.framework/Tethering-D73.ca/main.caml"])
        ]),
        ZeroSection(name: "控制中心", icon: "square.grid.2x2", tweaks: [
            ZeroTweak(name: "清除控制中心模块背景", icon: "circle.grid.2x2", minSupportedVersion: 18.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/CoreMaterial.framework/modulesSheer.descendantrecipe", "/System/Library/ControlCenter/Bundles/FocusUIModule.bundle/Info.plist"]),
            ZeroTweak(name: "禁用滑块图标 ", icon: "sun.max", minSupportedVersion: 16.0, maxSupportedVersion: 17.9, paths: ["/System/Library/ControlCenter/Bundles/DisplayModule.bundle/Brightness.ca/index.xml", "/System/Library/PrivateFrameworks/MediaControls.framework/Volume.ca/index.xml"]),
            ZeroTweak(name: "禁用滑块图标", icon: "sun.max", minSupportedVersion: 18.0, maxSupportedVersion: 26.9, paths: ["/System/Library/ControlCenter/Bundles/DisplayModule.bundle/Brightness.ca/index.xml", "/System/Library/PrivateFrameworks/MediaControls.framework/VolumeSemibold.ca/index.xml"]),
            ZeroTweak(name: "隐藏播放器按钮", icon: "play", minSupportedVersion: 17.0, maxSupportedVersion: 26.9, paths: ["/System/Library/PrivateFrameworks/MediaControls.framework/PlayPauseStop.ca/index.xml", "/System/Library/PrivateFrameworks/MediaControls.framework/ForwardBackward.ca/index.xml"]),
            ZeroTweak(name: "隐藏勿扰图标", icon: "moon", minSupportedVersion: 16.0, maxSupportedVersion: 26.9, paths: ["/System/Library/PrivateFrameworks/FocusUI.framework/dnd_cg_02.ca/main.caml"]),
            ZeroTweak(name: "隐藏 Wi-Fi 与蓝牙图标", icon: "wifi", minSupportedVersion: 16.0, maxSupportedVersion: 17.9, paths: ["/System/Library/ControlCenter/Bundles/ConnectivityModule.bundle/Bluetooth.ca/index.xml", "/System/Library/ControlCenter/Bundles/ConnectivityModule.bundle/WiFi.ca/index.xml"]),
            ZeroTweak(name: "禁用屏幕镜像模块", icon: "rectangle.on.rectangle", minSupportedVersion: 16.0, maxSupportedVersion: 17.9, paths: ["/System/Library/ControlCenter/Bundles/AirPlayMirroringModule.bundle/Info.plist"]),
            ZeroTweak(name: "禁用方向锁定模块", icon: "lock.rotation", minSupportedVersion: 16.0, maxSupportedVersion: 17.9, paths: ["/System/Library/ControlCenter/Bundles/OrientationLockModule.bundle/Info.plist"]),
            ZeroTweak(name: "禁用专注模式模块", icon: "moon", minSupportedVersion: 16.0, maxSupportedVersion: 17.9, paths: ["/System/Library/ControlCenter/Bundles/FocusUIModule.bundle/Info.plist"])
        ]),
        ZeroSection(name: "音效", icon: "speaker.wave.2", tweaks: [
            ZeroTweak(name: "关闭隔空投送提示音", icon: "dot.radiowaves.left.and.right", minSupportedVersion: 16.0, maxSupportedVersion: 26.9, paths: ["/System/Library/Audio/UISounds/Modern/airdrop_invite.cat"]),
            ZeroTweak(name: "关闭充电提示音", icon: "bolt", minSupportedVersion: 16.0, maxSupportedVersion: 26.9, paths: ["/System/Library/Audio/UISounds/connect_power.caf"]),
            ZeroTweak(name: "关闭低电量提示音", icon: "battery.25", minSupportedVersion: 16.0, maxSupportedVersion: 26.9, paths: ["/System/Library/Audio/UISounds/low_power.caf"]),
            ZeroTweak(name: "关闭支付提示音", icon: "creditcard", minSupportedVersion: 16.0, maxSupportedVersion: 26.9, paths: ["/System/Library/Audio/UISounds/payment_success.caf", "/System/Library/Audio/UISounds/payment_failure.caf"]),
            ZeroTweak(name: "关闭拨号按键音", icon: "phone", minSupportedVersion: 16.0, maxSupportedVersion: 26.9, paths: ["/System/Library/Audio/UISounds/nano/dtmf-0.caf", "/System/Library/Audio/UISounds/nano/dtmf-1.caf", "/System/Library/Audio/UISounds/nano/dtmf-2.caf", "/System/Library/Audio/UISounds/nano/dtmf-3.caf", "/System/Library/Audio/UISounds/nano/dtmf-4.caf", "/System/Library/Audio/UISounds/nano/dtmf-5.caf", "/System/Library/Audio/UISounds/nano/dtmf-6.caf", "/System/Library/Audio/UISounds/nano/dtmf-7.caf", "/System/Library/Audio/UISounds/nano/dtmf-8.caf", "/System/Library/Audio/UISounds/nano/dtmf-9.caf", "/System/Library/Audio/UISounds/nano/dtmf-pound.caf", "/System/Library/Audio/UISounds/nano/dtmf-star.caf"])
        ]),
        ZeroSection(name: "高风险调整", icon: "exclamationmark.triangle.fill", tweaks: [
            ZeroTweak(name: "移除控制中心背景", icon: "square.dashed", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/CoreMaterial.framework/modulesBackground.materialrecipe"]),
            ZeroTweak(name: "关闭全部横幅通知", icon: "exclamationmark.triangle", minSupportedVersion: 16.0, maxSupportedVersion: 26.9, paths: ["/System/Library/PrivateFrameworks/SpringBoard.framework/BannersAuthorizedBundleIDs.plist"]),
            ZeroTweak(name: "关闭全部强调色", icon: "paintpalette", minSupportedVersion: 16.0, maxSupportedVersion: 26.9, paths: ["/System/Library/PrivateFrameworks/CoreUI.framework/DesignLibrary-iOS.bundle/iOSRepositories/DarkStandard.car"]),
            ZeroTweak(name: "破坏系统字体", icon: "text.badge.xmark", minSupportedVersion: 16.0, maxSupportedVersion: 26.9, paths: ["/System/Library/Fonts/Core/SFUI.ttf", "/System/Library/Fonts/Core/Helvetica.ttc"]),
            ZeroTweak(name: "破坏时钟字体", icon: "clock", minSupportedVersion: 16.0, maxSupportedVersion: 26.9, paths: ["/System/Library/Fonts/Core/ADTNumeric.ttc"]),
            ZeroTweak(name: "破坏 SpringBoard 名称", icon: "house", minSupportedVersion: 16.0, maxSupportedVersion: 26.9, paths: ["/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/SpringBoardUIServices.loctable", "/System/Library/PrivateFrameworks/SpringBoardHome.framework/SpringBoardHome.loctable", "/System/Library/CoreServices/SpringBoard.app/SpringBoard.loctable"]),
        ])
    ]
}

