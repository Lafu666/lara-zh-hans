//
//  LGView.swift
//  lara
//
//  Created by jurre111 on 24.04.26.
//

// Credits to leminlimez and Duy Tran for most of the code
// thank you lunginspector for the rewrite

import SwiftUI

let gpCurrentPath = "/var/Managed Preferences/mobile/.GlobalPreferences.plist"

struct LiquidGlassView: View {
    @EnvironmentObject private var mgr: laramgr
    
    @State private var gpCurrentDict: NSMutableDictionary = NSMutableDictionary()
    @State private var trueBool: Bool = true
    
    @State private var dumbassToggleThatMakesTheViewUpdate: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: HeaderLabel(text: "正在应用", icon: "checkmark")) {
                    Button("应用调整", action: { applyLiquidGlass() })
                    Button("重置调整", action: { restoreLiquidGlass() })
                }
                
                Section(header: HeaderLabel(text: "预览", icon: "eye")) {
                    LiquidGlassPreview(lgDisabled: gpKeyBinding("com.apple.SwiftUI.DisableSolarium"), lgFallback: gpKeyBinding("SolariumForceFallback"))
                        .listRowInsets(EdgeInsets())
                }
                
                Section(header: HeaderLabel(text: "用户界面", icon: "iphone"), footer: Text("Solarium 降级 — 让所有液态玻璃元素使用灰色背景。\n\n关闭液态玻璃 — 真正关闭液态玻璃，界面回退到 iOS 18 样式，但会出现较严重的显示问题（尤其是控制中心）。")) {
                    Toggle("启用 Solarium 降级", isOn: gpKeyBinding("SolariumForceFallback"))
                    Toggle("关闭液态玻璃", isOn: gpKeyBinding("com.apple.SwiftUI.DisableSolarium"))
                }
                
                Section(header: HeaderLabel(text: "液态玻璃", icon: "square.on.square.intersection.dashed")) {
                    Toggle("关闭高光动效", isOn: gpKeyBinding("SBDisableSpecularEverywhereUsingLSSAssertion"))
                    Toggle("关闭外缘折射", isOn: gpKeyBinding("SolariumDisableOuterRefraction"))
                    Toggle("关闭 Solarium HDR", isOn: gpKeyBinding("SolariumAllowHDR", default: true, enable: false))
                }
                
                Section(header: HeaderLabel(text: "可见性", icon: "loupe")) {
                    Toggle("忽略液态玻璃应用构建检查", isOn: gpKeyBinding("com.apple.SwiftUI.IgnoreSolariumLinkedOnCheck"))
                    Toggle("关闭锁屏时钟的液态玻璃", isOn: gpKeyBinding("SBDisallowGlassTime"))
                    Toggle("关闭 Dock 的液态玻璃", isOn: gpKeyBinding("SBDisableGlassDock"))
                }
            }
            .navigationTitle("液态玻璃")
            .onAppear {
                loadGPData()
            }
        }
    }
    
    // MARK: file loading functions. root you said that making my comments uppercase sounds like i'm vibecoding so this will all be lowercase from now on.
    private func loadGPData() {
        let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let gpSavedURL = docsDir.appendingPathComponent("SavedGlobalPrefs.plist")
        let gpCurrentURL = URL(fileURLWithPath: gpCurrentPath)
        
        do {
            if !FileManager.default.fileExists(atPath: gpSavedURL.path) {
                try FileManager.default.copyItem(at: gpCurrentURL, to: gpSavedURL)
            }
            chmod(gpSavedURL.path, 0o644)
            
            gpCurrentDict = try NSMutableDictionary(contentsOf: URL(fileURLWithPath: gpCurrentPath), error: ())
        } catch {
            Alertinator.shared.alert(title: "加载全局偏好设置数据失败！", body: "请重启应用后重试。")
        }
    }
    
    // MARK: applying/reloading functions
    func applyLiquidGlass() {
        do {
            let gpData = try verifyPlist(gpCurrentDict, targetPath: gpCurrentPath)
            let result = mgr.lara_overwritefile(target: gpCurrentPath, data: gpData)
            
            if result.ok {
                Alertinator.shared.alert(title: "液态玻璃调整已应用！", body: "重启设备后生效")
            } else {
                throw "Overwrite failed: \(result.message)"
            }
        } catch {
            Alertinator.shared.alert(title: "启用液态玻璃调整失败！", body: "\(error)")
        }
    }
    
    func restoreLiquidGlass() {
        do {
            let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let gpSavedURL = docsDir.appendingPathComponent("SavedGlobalPrefs.plist")
            
            if FileManager.default.fileExists(atPath: gpSavedURL.path) {
                let restored = try NSMutableDictionary(contentsOf: gpSavedURL, error: ())
                _ = try verifyPlist(restored, targetPath: mgCurrentPath)
                gpCurrentDict = restored
            } else {
                throw "未找到全局偏好设置文件！"
            }
        } catch {
            Alertinator.shared.alert(title: "恢复液态玻璃失败！", body: "\(error)")
        }
    }
    
    // MARK: bindings
    private func gpKeyBinding<T: Equatable>(_ key: String, type: T.Type = Bool.self, default: T? = false, enable: T? = true) -> Binding<Bool> {
        return Binding(get: {
            _ = dumbassToggleThatMakesTheViewUpdate
            if let value = gpCurrentDict[key] as? T?, let enable {
                return value == enable
            }
            return false
        }, set: { enabled in
            if enabled {
                dumbassToggleThatMakesTheViewUpdate.toggle()
                gpCurrentDict[key] = enable
            } else {
                dumbassToggleThatMakesTheViewUpdate.toggle()
                gpCurrentDict.removeObject(forKey: key)
            }
        })
    }
}

#Preview {
    LiquidGlassView()
}
