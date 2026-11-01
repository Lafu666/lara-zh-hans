//
//  EditorView.swift
//  lara
//
//  Created by ruter on 27.03.26.
//

// Most of the code is from Duy's SparseBox
// thank you @jurre111 for the original implementation + all the nugget tweak implements
// thank you @lunginspector for the rewrite + tweak additions

import SwiftUI

enum fileloc: String, CaseIterable {
    case springboard = "/var/Managed Preferences/mobile/com.apple.springboard.plist"
    case footnote = "/var/containers/Shared/SystemGroup/systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles/SharedDeviceConfiguration.plist"
    case airdrop = "/var/Managed Preferences/mobile/com.apple.sharingd.plist"
    case nanoregistry = "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist"

    case globalprefs = "/var/Managed Preferences/mobile/.GlobalPreferences.plist"
    case appstore = "/var/Managed Preferences/mobile/com.apple.AppStore.plist"
    case backboardd = "/var/Managed Preferences/mobile/com.apple.backboardd.plist"
    case coremotion = "/var/Managed Preferences/mobile/com.apple.CoreMotion.plist"
    case pasteboard = "/var/Managed Preferences/mobile/com.apple.Pasteboard.plist"
    case notes = "/var/Managed Preferences/mobile/com.apple.mobilenotes.plist"
    case uikit = "/var/Managed Preferences/mobile/com.apple.UIKit.plist"
}

let mgCurrentPath = "/private/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist"

struct GestaltView: View {
    @AppStorage("gestaltwarn") private var gestaltwarn: Bool = true
    @AppStorage("mgDeviceName") private var mgDeviceName: String = ""
    
    let mgr: laramgr
    @State private var mgCurrentDict: NSMutableDictionary = NSMutableDictionary()
    @State private var isGestaltVaild: Bool = false
    
    @State private var showgestaltwarn: Bool = false
    @State private var mgSubtype: Int = 0
    @State private var mgOriginalSubtype: Int = 0
    @State private var mgEnableDeviceName: Bool = false
    @State private var mgProductType: String = ""
    
    @State private var mgShowFileSheet: Bool = false
    
    @State private var nuggetValues: [String: Bool] = [:]
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: HeaderLabel(text: "正在应用", icon: "checkmark")) {
                    Button {
                        applyGestalt()
                    } label: {
                        Text("应用调整")
                    }
                    
                    Button {
                        resetnugget()
                        restoreGestalt()
                    } label: {
                        Text("重置调整")
                    }
                }
                
                // artwork tweaks will be added when applying mobilegestalt because there's no "toggleable" bindings.
                Section(header: HeaderLabel(text: "设备外观", icon: "paintbrush.pointed")) {
                    Picker(selection: $mgSubtype) {
                        Text("原始（\(mgOriginalSubtype)）").tag(mgOriginalSubtype)
                        if isDeviceNotBroke() {
                            Text("关闭灵动岛").tag(2436)
                        }
                        Text("iPhone 14 Pro").tag(2436)
                        Text("iPhone 14 Pro Max").tag(2796)
                        Text("iPhone 15 Pro Max").tag(2976)
                        if doubleSystemVersion() >= 18.0 {
                            Text("iPhone 16 Pro").tag(2622)
                            Text("iPhone 16 Pro Max").tag(2868)
                        }
                        if doubleSystemVersion() >= 26.0 {
                            Text("iPhone Air").tag(2736)
                        }
                        if UIDevice._hasHomeButton() {
                            Text("iPhone X 手势").tag(2436)
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "iphone")
                                .frame(width: 20, alignment: .center)
                            Text("子类型")
                            Spacer()
                        }
                    }
                    
                    Toggle("自定义设备名称", isOn: $mgEnableDeviceName)
                    
                    if mgEnableDeviceName {
                        TextField("设备名称", text: $mgDeviceName)
                    }
                }
                
                // basic tweak toggles
                Section(header: HeaderLabel(text: "软件层功能", icon: "gearshape")) {
                    PlainToggle(text: "灵动岛", icon: "platter.filled.top.iphone", minSupportedVersion: 19.0, isOn: mgKeyBinding(["YlEtTtHlNesRBMal1CqRaA"]))
                    PlainToggle(text: "全天候显示", icon: "sun.max", minSupportedVersion: 18.0, isOn: mgKeyBinding(["j8/Omm6s1lsmTDFsXjsBfA", "2OOJf1VhaM7NxfRok3HbWQ"]))
                    PlainToggle(text: "全天候显示鲜艳度", icon: "rays", minSupportedVersion: 18.0, isOn: mgKeyBinding(["ykpu7qyhqFweVMKtxNylWA"]))
                    PlainToggle(text: "充电上限", icon: "battery.100.bolt", minSupportedVersion: 17.0, isOn: mgKeyBinding(["37NVydb//GP/GrhuTN+exg"]))
                    PlainToggle(text: "开机提示音", icon: "speaker.wave.3", isOn: mgKeyBinding(["QHxt+hGLaBPbQJbXiUJX3w"]))
                    PlainToggle(text: "液态玻璃低电量模式", icon: "app.background.dotted", minSupportedVersion: 19.0, isOn: mgKeyBinding(["SAGvsp6O6kAQ4fEfDJpC4Q"]))
                }
                
                Section(header: HeaderLabel(text: "硬件层功能", icon: "iphone")) {
                    PlainToggle(text: "相机控制按钮", icon: "camera.shutter.button", minSupportedVersion: 18.0, isOn: mgKeyBinding(["CwvKxM2cEogD3p+HYgaW0Q", "oOV1jhJbdV3AddkcCg0AEA"]))
                    PlainToggle(text: "操作按钮", icon: "button.vertical.left.press", minSupportedVersion: 17.0, isOn: mgKeyBinding(["cT44WE1EohiwRzhsZ8xEsw"]))
                    PlainToggle(text: "车祸检测", icon: "car", isOn: mgKeyBinding(["HCzWusHQwZDea6nNhaKndw"]))
                    if UIDevice._hasHomeButton() {
                        PlainToggle(text: "启用轻点唤醒", icon: "hand.tap", isOn: mgKeyBinding(["yZf3GTRMGTuwSV/lD7Cagw"]))
                    }
                    PlainToggle(text: "脉宽调制调光", icon: "eye", minSupportedVersion: 19.0, isOn: mgKeyBinding(["6IejgN+1Fmu5/QrZFOIeNw"]))
                }
                
                // some odd bindings in here that i dislike.
                Section(header: HeaderLabel(text: "资格判定", icon: "checklist")) {
                    PlainToggle(text: "安全研究设备界面", icon: "terminal", minSupportedVersion: 26.0, isOn: mgKeyBinding(["XYlJKKkj2hztRP1NWWnhlw"]))
                    PlainToggle(text: "解除地区限制", icon: "globe", isOn: mgRegionRestrictionsBinding())
                    PlainToggle(text: "Apple 智能", icon: "apple.intelligence", minSupportedVersion: 18.1, isOn: mgKeyBinding(["A62OafQ85EJAiiqKn4agtg"]))
                    HStack(spacing: 10) {
                        Picker("伪装", selection: $mgProductType) {
                            Text("默认").tag(machineName())
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                if doubleSystemVersion() >= 17.4 {
                                    Text("iPad Pro 11-inch (M4)").tag("iPad16,3")
                                    Text("iPad Pro 11-inch (M4, Cellular)").tag("iPad16,4")
                                }
                                Text("iPad Pro 11-inch (4th Gen)").tag("iPad14,3")
                                Text("iPad Pro 11-inch (4th Gen, Cellular)").tag("iPad14,4")
                            } else {
                                Text("iPhone 15 Pro").tag("iPhone16,1")
                                Text("iPhone 15 Pro Max").tag("iPhone16,2")
                                if doubleSystemVersion() >= 18.0 {
                                    Text("iPhone 16").tag("iPhone17,3")
                                    Text("iPhone 16 Plus").tag("iPhone17,4")
                                    Text("iPhone 16 Pro").tag("iPhone17,1")
                                    Text("iPhone 16 Pro Max").tag("iPhone17,2")
                                }
                                if doubleSystemVersion() >= 19.0 {
                                    Text("iPhone 17").tag("iPhone18,3")
                                    Text("iPhone 17 Pro").tag("iPhone18,1")
                                    Text("iPhone 17 Pro Max").tag("iPhone18,2")
                                    Text("iPhone Air").tag("iPhone18,4")
                                }
                            }
                        }
                        
                        Button(action: {
                            Alertinator.shared.alert(title: "设备伪装说明", body: "仅在需要下载 Apple 智能时才伪装设备型号。此操作可能导致面容 ID 失效。如果你打算取消伪装又想保留 Apple 智能，请不要再进入“设置”中的“Apple 智能与 Siri”菜单。")
                        }) {
                            Image(systemName: "info.circle")
                                .frame(width: 24, height: 22)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Section(header: HeaderLabel(text: "iPadOS 功能", icon: "ipad")) {
                    let cacheExtra = mgCurrentDict["CacheExtra"] as? NSMutableDictionary
                    
                    PlainToggle(text: "允许安装 iPadOS 应用", icon: "plus.app", isOn: mgKeyBinding(["9MZ5AdH43csAUajl/dU+IQ"], type: [Int].self, defaultValue: [1], enableValue: [1, 2]))
                    PlainToggle(text: "Apple Pencil 设置", icon: "pencil", isOn: mgKeyBinding(["yhHcB0iH0d1XzPO/CFd3ow"]))
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        PlainToggle(text: "台前调度", icon: "squares.leading.rectangle", isOn: mgKeyBinding(["qeaj75wk3HF4DwQ8qbIi7g"]))
                    }
                    PlainToggle(text: "iPadOS 界面", icon: "ipad", infoType: .warning, infoMessage: "This is a very dangerous tweak to use! If you use an alphanumeric passcode, DO NOT USE THIS TWEAK AT ALL! Please do not turn off \"Show Dock In Stage Manager\" or your device will BOOTLOOP when rotating to landscape! With these two things in mind, you may experience general instability, or other major issues such as app data randomly disappearing. But I guess some funny multitasking features that still make the device relatively unusable are cool? Whatever dude, I'm not here to tell you how to use your own device.", isOn: mgTrollPadBinding())
                        .disabled(cacheExtra?["+3Uf0Pm5F8Xy7Onyvko0vA"] as? String != "iPhone")
                }
                
                Section(header: HeaderLabel(text: "内部", icon: "ant")) {
                    PlainToggle(text: "内部存储", icon: "externaldrive", isOn: mgKeyBinding(["LBJfwOEzExRxzlAnSuI7eg"]))
                    PlainToggle(text: "内部功能", icon: "gearshape", isOn: mgInternalStuffBinding())
                    PlainToggle(text: "在所有应用中显示 Metal HUD", icon: "terminal", isOn: mgKeyBinding(["EqrsVvjcYDdxHBiQmGhAWw"]))
                }
                
                Section {
                    PlainToggle(
                        text: "完全隐藏灵动岛",
                        icon: "capsule",
                        isOn: nuggetbinding(
                            "SBSuppressDynamicIslandCompletely",
                            path: fileloc.springboard.rawValue
                        )
                    )

                    PlainToggle(
                        text: "认证调试信息",
                        icon: "faceid",
                        isOn: nuggetbinding(
                            "SBShowAuthenticationEngineeringUI",
                            path: fileloc.springboard.rawValue
                        )
                    )

                    PlainToggle(
                        text: "显示构建版本",
                        icon: "number",
                        isOn: nuggetbinding(
                            "UIStatusBarShowBuildVersion",
                            path: fileloc.globalprefs.rawValue
                        )
                    )

                    PlainToggle(
                        text: "强制 RTL 布局",
                        icon: "arrow.left",
                        isOn: nuggetbinding(
                            "NSForceRightToLeftWritingDirection",
                            path: fileloc.globalprefs.rawValue
                        )
                    )

                    PlainToggle(
                        text: "键盘字符飞散特效",
                        icon: "keyboard",
                        isOn: nuggetbinding(
                            "GesturesEnabled",
                            path: fileloc.globalprefs.rawValue
                        )
                    )

                    PlainToggle(
                        text: "关闭返回路径角标",
                        icon: "chevron.backward",
                        isOn: nuggetbinding(
                            "SBNeverBreadcrumb",
                            path: fileloc.springboard.rawValue
                        )
                    )
                } header: {
                    HeaderLabel(text: "界面调整", icon: "eye")
                }
                
                Section {
                    PlainToggle(
                        text: "注销后不自动锁屏",
                        icon: "lock.open",
                        isOn: nuggetbinding(
                            "SBDontLockAfterCrash",
                            path: fileloc.springboard.rawValue
                        )
                    )

                    PlainToggle(
                        text: "关闭低电量提醒",
                        icon: "battery.25",
                        isOn: nuggetbinding(
                            "SBHideLowPowerAlerts",
                            path: fileloc.springboard.rawValue
                        )
                    )

                    PlainToggle(
                        text: "截图中显示灵动岛",
                        icon: "camera",
                        isOn: nuggetbinding(
                            "SBAlwaysShowSystemApertureInSnapshots",
                            path: fileloc.springboard.rawValue
                        )
                    )

                    PlainToggle(
                        text: "粘贴时播放声音",
                        icon: "speaker.wave.2",
                        isOn: nuggetbinding(
                            "PlaySoundOnPaste",
                            path: fileloc.pasteboard.rawValue
                        )
                    )

                    PlainToggle(
                        text: "系统粘贴通知",
                        icon: "doc.on.clipboard",
                        isOn: nuggetbinding(
                            "AnnounceAllPastes",
                            path: fileloc.pasteboard.rawValue
                        )
                    )
                } header: {
                    HeaderLabel(text: "SpringBoard", icon: "gear")
                }

                Section {
                    PlainToggle(
                        text: "Metal HUD 调试",
                        icon: "cpu",
                        isOn: nuggetbinding(
                            "MetalForceHudEnabled",
                            path: fileloc.globalprefs.rawValue
                        )
                    )

                    PlainToggle(
                        text: "App Store 调试手势",
                        icon: "hand.tap",
                        isOn: nuggetbinding(
                            "debugGestureEnabled",
                            path: fileloc.appstore.rawValue
                        )
                    )

                    PlainToggle(
                        text: "备忘录调试模式",
                        icon: "note.text",
                        isOn: nuggetbinding(
                            "DebugModeEnabled",
                            path: fileloc.notes.rawValue
                        )
                    )

                    PlainToggle(
                        text: "显示触摸点",
                        icon: "hand.point.up.left",
                        isOn: nuggetbinding(
                            "BKDigitizerVisualizeTouches",
                            path: fileloc.backboardd.rawValue
                        )
                    )
                } header: {
                    HeaderLabel(text: "调试", icon: "ladybug")
                }
            }
            .navigationTitle("MobileGestalt")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        mgShowFileSheet.toggle()
                    }) {
                        Image(systemName: "doc")
                    }
                }
            }
            .onAppear {
                loadCurrentGestalt()
                loadnuggettweaks()
                
                if gestaltwarn {
                    showgestaltwarn = true
                }
            }
            .sheet(isPresented: $mgShowFileSheet) {
                GestaltFileView()
            }
            .alert("警告", isPresented: $showgestaltwarn) {
                Button("好吧。", role: .cancel) {
                    showgestaltwarn = false
                    gestaltwarn = false
                }
            } message: {
                Text("这些功能有风险！可能让设备暂时异常、崩溃，甚至无限重启。别说我没提醒你。")
            }
        }
    }
    
    private func loadCurrentGestalt() {
        do {
            mgCurrentDict = try loadMutablePlistDictionary(from: URL(fileURLWithPath: mgCurrentPath))
            print(mgCurrentDict.description)
            prepareGestaltData()
        } catch {
            Alertinator.shared.alert(title: "加载当前 MobileGestalt 失败！", body: "\(error)")
        }
    }
    
    private func prepareGestaltData() {
        let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let mgSavedURL = docsDir.appendingPathComponent("SavedGestalt.plist")
        let mgCurrentURL = URL(fileURLWithPath: mgCurrentPath)
        
        do {
            // check if MobileGestalt has ever been saved, and if it hasn't, save it.
            if !FileManager.default.fileExists(atPath: mgSavedURL.path) {
                try FileManager.default.copyItem(at: mgCurrentURL, to: mgSavedURL)
            }
            
            let mgSavedDict = try loadMutablePlistDictionary(from: mgSavedURL)
            let cacheExtra = mgSavedDict["CacheExtra"] as? NSMutableDictionary ?? NSMutableDictionary()
            let ArtworkDict = cacheExtra["oPeik/9e8lQWMszEjbPzng"] as? NSMutableDictionary ?? NSMutableDictionary()
            
            let currentCacheExtra = mgCurrentDict["CacheExtra"] as? NSMutableDictionary ?? NSMutableDictionary()
            let currentArtworkDict = currentCacheExtra["oPeik/9e8lQWMszEjbPzng"] as? NSMutableDictionary ?? NSMutableDictionary()
            let originalSubType = ArtworkDict["ArtworkDeviceSubType"] as? Int
                ?? currentArtworkDict["ArtworkDeviceSubType"] as? Int
                ?? 0
            mgOriginalSubtype = originalSubType
            mgSubtype = currentArtworkDict["ArtworkDeviceSubType"] as? Int ?? originalSubType

            if let productType = currentCacheExtra["h9jDsbgj7xIVeIQ8S3/X3Q"] as? String, !productType.isEmpty {
                mgProductType = productType
            } else {
                mgProductType = machineName()
            }
            
            let deviceName = ArtworkDict["ArtworkDeviceProductDescription"] as? String
                ?? currentArtworkDict["ArtworkDeviceProductDescription"] as? String
                ?? machineName()
            mgDeviceName = deviceName
            
            if mgDeviceName == "" {
                mgDeviceName = deviceName
            }
        } catch {
            Alertinator.shared.alert(title: "从 MobileGestalt 读取数据失败！", body: "请重启应用后重试。\n\n错误：\(error)")
        }
    }
    
    private func vaildateCacheExtra(_ dict: NSMutableDictionary) -> Bool {
        guard let cacheExtra = dict["CacheExtra"] as? NSMutableDictionary else { return false }
        return !cacheExtra.allKeys.isEmpty
    }
    
    private func applyGestalt() {
        do {
            // first, update the dictionary with some specific properties.
            let cacheExtra = mgCurrentDict["CacheExtra"] as? NSMutableDictionary ?? NSMutableDictionary()
            if !mgProductType.isEmpty {
                cacheExtra["h9jDsbgj7xIVeIQ8S3/X3Q"] = mgProductType
            }
            
            let ArtworkDict = cacheExtra["oPeik/9e8lQWMszEjbPzng"] as? NSMutableDictionary ?? NSMutableDictionary()
            ArtworkDict["ArtworkDeviceSubType"] = mgSubtype
            if mgEnableDeviceName {
                ArtworkDict["ArtworkDeviceProductDescription"] = mgDeviceName
            }
            
            // then, check to make sure it's actually valid
            if !vaildateCacheExtra(mgCurrentDict) { throw "MobileGestalt 无效！请重启应用。" }
            
            // bro please dont bootloop
            let mgData = try verifyPlist(mgCurrentDict, targetPath: mgCurrentPath)
            let result = mgr.lara_overwritefile(target: mgCurrentPath, data: mgData, fallback_vfs: false)
            
            if result.ok {
                Alertinator.shared.alert(title: "MobileGestalt 已应用！", body: "注销后查看效果", actionLabel: "Respring", action: { mgr.respring() })
            } else {
                throw "Overwrite failed: \(result.message)"
            }
        } catch {
            Alertinator.shared.alert(title: "覆盖 MobileGestalt 失败！", body: "\(error)")
        }
    }
    
    private func restoreGestalt() {
        do {
            let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let mgSavedURL = docsDir.appendingPathComponent("SavedGestalt.plist")
            
            if FileManager.default.fileExists(atPath: mgSavedURL.path) {
                let restored = try loadMutablePlistDictionary(from: mgSavedURL)
                _ = try verifyPlist(restored, targetPath: mgCurrentPath)
                mgCurrentDict = restored
            } else {
                throw "未找到 MobileGestalt 文件！"
            }
        } catch {
            Alertinator.shared.alert(title: "恢复 MobileGestalt 失败！", body: "\(error)")
        }
    }
    
    func isDeviceNotBroke() -> Bool {
        let supportedDevices: [String] = ["iPhone15,2", "iPhone15,3", "iPhone15,4", "iPhone15,5", "iPhone16,1", "iPhone16,2", "iPhone17,3", "iPhone17,4", "iPhone17,1", "iPhone17,2", "iPhone18,3", "iPhone18,1", "iPhone18,2", "iPhone17,5"]
        if supportedDevices.contains(machineName()) && doubleSystemVersion() < 19.0 {
            return true
        }
        return false
    }
    
    // https://stackoverflow.com/questions/26028918/how-to-determine-the-current-iphone-device-model
    // read device model from kernel
    func machineName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }

    // default = 0 (off in Gesalt Terms), enable = 1 (on)
    // "gesalt" lol (roooot, 12.05.2026)
    // return just returns a boolean
    private func mgKeyBinding<T: Equatable>(_ keys: [String], type: T.Type = Int.self, defaultValue: T? = 0, enableValue: T? = 1) -> Binding<Bool>  {
        // immediately return false if it can't find cacheextra, again why is this here? i think it's safety.
        guard let cacheExtra = mgCurrentDict["CacheExtra"] as? NSMutableDictionary else {
            return State(initialValue: false).projectedValue
        }
        
        // then return the binding
        return Binding(get: {
            // get the value in terms of the type and return it as a bool.
            if let value = cacheExtra[keys.first!] as? T?, let enableValue {
                return value == enableValue
            }
            return false
        }, set: { enabled in
            for key in keys {
                // if it exists inside of the plist, then update it. if not then pull the value completely. that also makes sense.
                if enabled {
                    cacheExtra[key] = enableValue
                } else {
                    cacheExtra.removeObject(forKey: key)
                }
            }
        })
    }
    
    private func mgTrollPadBinding() -> Binding<Bool> {
        guard let cacheData = mgCurrentDict["CacheData"] as? NSMutableData,
                let cacheExtra = mgCurrentDict["CacheExtra"] as? NSMutableDictionary else {
            return State(initialValue: false).projectedValue
        }
        let valueOffset = findcachedataoff("mtrAoWJ3gsq+I90ZnQ0vQw")
        let keys = [
            "uKc7FPnEO++lVhHWHFlGbQ", // ipad
            "mG0AnH/Vy1veoqoLRAIgTA", // MedusaFloatingLiveAppCapability
            "UCG5MkVahJxG1YULbbd5Bg", // MedusaOverlayAppCapability
            "ZYqko/XM5zD3XBfN5RmaXA", // MedusaPinnedAppCapability
            "nVh/gwNpy7Jv1NOk00CMrw", // MedusaPIPCapability,
            "qeaj75wk3HF4DwQ8qbIi7g", // DeviceSupportsEnhancedMultitasking
        ]
        
        return Binding(get: {
            if let value = cacheExtra[keys.first!] as? Int? {
                return value == 1
            }
            return false
        }, set: { enabled in
            if enabled {
                Alertinator.shared.alert(title: "警告！", body: "这个调整非常危险！如果你使用含字母的密码，请绝对不要使用它！也不要关闭\"在台前调度中显示 Dock\"，否则横屏时设备会无限重启！即便注意了这两点，仍可能出现整体不稳定，或应用数据无故丢失等严重问题。不过，多几个让设备依然不太好用的花哨多任务功能，大概也算酷吧？随便你，我并不是来教你怎么用你自己的设备的。")
            }
            cacheData.mutableBytes.storeBytes(of: enabled ? 3 : 1, toByteOffset: valueOffset, as: Int.self)
            for key in keys {
                if enabled {
                    cacheExtra[key] = 1
                } else {
                    cacheExtra.removeObject(forKey: key)
                }
            }
        })
    }
    
    func mgRegionRestrictionsBinding() -> Binding<Bool> {
        guard let cacheExtra = mgCurrentDict["CacheExtra"] as? NSMutableDictionary else {
            return State(initialValue: false).projectedValue
        }
        
        return Binding<Bool>(
            get: {
                return cacheExtra["h63QSdBCiT/z0WU6rdQv6Q"] as? String == "US" &&
                    cacheExtra["zHeENZu+wbg7PUprwNwBWg"] as? String == "LL/A"
            },
            set: { enabled in
                if enabled {
                    Alertinator.shared.alert(title: "警告！", body: "请勿使用本功能绕过等同于违反当地法律的地区限制（例如关闭相机快门声）。因启用任何违法行为而产生的后果，我们概不负责！")
                    cacheExtra["h63QSdBCiT/z0WU6rdQv6Q"] = "US"
                    cacheExtra["zHeENZu+wbg7PUprwNwBWg"] = "LL/A"
                } else {
                    cacheExtra.removeObject(forKey: "h63QSdBCiT/z0WU6rdQv6Q")
                    cacheExtra.removeObject(forKey: "zHeENZu+wbg7PUprwNwBWg")
                }
            }
        )
    }
    
    func mgInternalStuffBinding() -> Binding<Bool> {
        guard let cacheData = mgCurrentDict["CacheData"] as? NSMutableData else {
            return State(initialValue: false).projectedValue
        }
        
        let off_appleInternalInstall = findcachedataoff("EqrsVvjcYDdxHBiQmGhAWw")
        let off_HasInternalSettingsBundle = findcachedataoff("Oji6HRoPi7rH7HPdWVakuw")
        let off_InternalBuild = findcachedataoff("LBJfwOEzExRxzlAnSuI7eg")
        
        return Binding(
            get: {
                return cacheData.bytes.load(fromByteOffset: off_appleInternalInstall, as: Int.self) == 1
            },
            set: { enabled in
                cacheData.mutableBytes.storeBytes(of: enabled ? 1 : 0, toByteOffset: off_appleInternalInstall, as: Int.self)
                cacheData.mutableBytes.storeBytes(of: enabled ? 1 : 0, toByteOffset: off_HasInternalSettingsBundle, as: Int.self)
                cacheData.mutableBytes.storeBytes(of: enabled ? 1 : 0, toByteOffset: off_InternalBuild, as: Int.self)
            }
        )
    }
    
    private func loadnuggettweaks() {
        nuggetValues.removeAll()

        let tweaks: [(String, String)] = [
            ("SBSuppressDynamicIslandCompletely", fileloc.springboard.rawValue),
            ("SBShowAuthenticationEngineeringUI", fileloc.springboard.rawValue),
            ("UIStatusBarShowBuildVersion", fileloc.globalprefs.rawValue),
            ("NSForceRightToLeftWritingDirection", fileloc.globalprefs.rawValue),
            ("NSForceLeftToRightWritingDirection", fileloc.globalprefs.rawValue),
            ("GesturesEnabled", fileloc.globalprefs.rawValue),
            ("SBDisableClockIconSecondsHand", fileloc.globalprefs.rawValue),
            ("SBHardwareButtonHintDropletsAlwaysVisibleInSnapshots", fileloc.globalprefs.rawValue),
            ("BKHideAppleLogoOnLaunch", fileloc.backboardd.rawValue),
            ("SBNeverBreadcrumb", fileloc.springboard.rawValue),
            ("SBShowSupervisionTextOnLockScreen", fileloc.springboard.rawValue),

            ("OverrideTimeLimitEveryoneMode", fileloc.airdrop.rawValue),
            ("SBDontLockAfterCrash", fileloc.springboard.rawValue),
            ("SBDontDimOrLockOnAC", fileloc.springboard.rawValue),
            ("SBHideLowPowerAlerts", fileloc.springboard.rawValue),
            ("SBHideACPower", fileloc.springboard.rawValue),
            ("SBAlwaysShowSystemApertureInSnapshots", fileloc.springboard.rawValue),
            ("SBExtendedDisplayOverrideSupportForAirPlayAndDontFileRadars", fileloc.springboard.rawValue),
            ("SBIconVisibility", fileloc.globalprefs.rawValue),
            ("SBSearchDisabledDomains", fileloc.globalprefs.rawValue),
            ("EnableWakeGestureHaptic", fileloc.coremotion.rawValue),
            ("PlaySoundOnPaste", fileloc.pasteboard.rawValue),
            ("AnnounceAllPastes", fileloc.pasteboard.rawValue),

            ("MetalForceHudEnabled", fileloc.globalprefs.rawValue),
            ("iMessageDiagnosticsEnabled", fileloc.globalprefs.rawValue),
            ("IDSDiagnosticsEnabled", fileloc.globalprefs.rawValue),
            ("VCDiagnosticsEnabled", fileloc.globalprefs.rawValue),
            ("AccessoryDeveloperEnabled", fileloc.globalprefs.rawValue),
            ("debugGestureEnabled", fileloc.appstore.rawValue),
            ("DebugModeEnabled", fileloc.notes.rawValue),
            ("BKDigitizerVisualizeTouches", fileloc.backboardd.rawValue)
        ]

        for (key, path) in tweaks {
            let result = mgr.getplistvalue(path: path, key: key)

            if result.ok, let value = result.value as? Bool {
                nuggetValues[key] = value
            } else {
                nuggetValues[key] = false
            }
        }
    }

    private func nuggetbinding(
        _ key: String,
        path: String
    ) -> Binding<Bool> {
        Binding(
            get: {
                nuggetValues[key] ?? false
            },
            set: { enabled in
                nuggetValues[key] = enabled

                let result = mgr.setplistvalue(
                    path: path,
                    key: (key, enabled ? true : nil),
                    force: true
                )

                if !result.ok {
                    Alertinator.shared.alert(
                        title: "应用调整失败",
                        body: result.message
                    )
                }
            }
        )
    }

    private func resetnugget() {
        let tweaks: [(String, String)] = [
            ("SBSuppressDynamicIslandCompletely", fileloc.springboard.rawValue),
            ("SBShowAuthenticationEngineeringUI", fileloc.springboard.rawValue),
            ("UIStatusBarShowBuildVersion", fileloc.globalprefs.rawValue),
            ("NSForceRightToLeftWritingDirection", fileloc.globalprefs.rawValue),
            ("NSForceLeftToRightWritingDirection", fileloc.globalprefs.rawValue),
            ("GesturesEnabled", fileloc.globalprefs.rawValue),
            ("SBDisableClockIconSecondsHand", fileloc.globalprefs.rawValue),
            ("SBHardwareButtonHintDropletsAlwaysVisibleInSnapshots", fileloc.globalprefs.rawValue),
            ("BKHideAppleLogoOnLaunch", fileloc.backboardd.rawValue),
            ("SBNeverBreadcrumb", fileloc.springboard.rawValue),
            ("SBShowSupervisionTextOnLockScreen", fileloc.springboard.rawValue),

            ("OverrideTimeLimitEveryoneMode", fileloc.airdrop.rawValue),
            ("SBDontLockAfterCrash", fileloc.springboard.rawValue),
            ("SBDontDimOrLockOnAC", fileloc.springboard.rawValue),
            ("SBHideLowPowerAlerts", fileloc.springboard.rawValue),
            ("SBHideACPower", fileloc.springboard.rawValue),
            ("SBAlwaysShowSystemApertureInSnapshots", fileloc.springboard.rawValue),
            ("SBExtendedDisplayOverrideSupportForAirPlayAndDontFileRadars", fileloc.springboard.rawValue),
            ("SBIconVisibility", fileloc.globalprefs.rawValue),
            ("SBSearchDisabledDomains", fileloc.globalprefs.rawValue),
            ("EnableWakeGestureHaptic", fileloc.coremotion.rawValue),
            ("PlaySoundOnPaste", fileloc.pasteboard.rawValue),
            ("AnnounceAllPastes", fileloc.pasteboard.rawValue),

            ("MetalForceHudEnabled", fileloc.globalprefs.rawValue),
            ("iMessageDiagnosticsEnabled", fileloc.globalprefs.rawValue),
            ("IDSDiagnosticsEnabled", fileloc.globalprefs.rawValue),
            ("VCDiagnosticsEnabled", fileloc.globalprefs.rawValue),
            ("AccessoryDeveloperEnabled", fileloc.globalprefs.rawValue),
            ("debugGestureEnabled", fileloc.appstore.rawValue),
            ("DebugModeEnabled", fileloc.notes.rawValue),
            ("BKDigitizerVisualizeTouches", fileloc.backboardd.rawValue)
        ]

        for (key, path) in tweaks {
            _ = mgr.setplistvalue(
                path: path,
                key: (key, nil),
                force: true
            )
        }

        loadnuggettweaks()
    }
}

#Preview {
    GestaltView(mgr: laramgr.shared)
}

func loadMutablePlistDictionary(from url: URL) throws -> NSMutableDictionary {
    let data = try Data(contentsOf: url)
    var format = PropertyListSerialization.PropertyListFormat.binary
    let plist = try PropertyListSerialization.propertyList(
        from: data,
        options: [.mutableContainersAndLeaves],
        format: &format
    )
    guard let dict = plist as? NSMutableDictionary else {
        throw "属性列表根节点不是字典。"
    }
    return dict
}

func verifyPlist(_ plist: Any, targetPath: String) throws -> Data {
    let fm = FileManager.default
    
    if fm.fileExists(atPath: targetPath) {
        let attrs = try fm.attributesOfItem(atPath: targetPath)
        if let current = attrs[.size] as? NSNumber,
           current.intValue == 0 {
            Alertinator.shared.alert(
                title: "检测到危险的 plist 状态",
                body: "当前 plist 文件已是 0 字节，为避免损坏已中止覆盖。"
            )
            throw "当前 MobileGestalt 文件为 0 字节。"
        }
    }
    
    guard PropertyListSerialization.propertyList(plist, isValidFor: .binary) else {
        Alertinator.shared.alert(
            title: "无效的属性列表",
            body: "plist 无效，无法安全写入。"
        )
        throw "plist 结构无效。"
    }
    
    let data = try PropertyListSerialization.data(
        fromPropertyList: plist,
        format: .binary,
        options: 0
    )
    
    if data.isEmpty || data.count == 0 {
        Alertinator.shared.alert(
            title: "拒绝写入空 plist",
            body: "覆盖后 plist 将变为 0 字节，操作已取消。"
        )
        throw "序列化的 plist 数据为空。"
    }
    
    do {
        _ = try PropertyListSerialization.propertyList(
            from: data,
            options: [],
            format: nil
        )
    } catch {
        Alertinator.shared.alert(
            title: "无效的序列化属性列表",
            body: "生成的 plist 序列化后未通过校验。"
        )
        throw "序列化 plist 校验失败。"
    }
    
    return data
}
