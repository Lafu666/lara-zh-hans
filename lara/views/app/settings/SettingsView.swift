//
//  SettingsView.swift
//  lara
//
//  Created by ruter on 29.03.26.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

enum method: String, CaseIterable {
    case vfs = "VFS"
    case sbx = "SBX"
    case hybrid = "Hybrid"
    
    var displayName: String {
        switch self {
            case .hybrid: return "混合模式"
            default: return rawValue
        }
    }
}

enum fmAppsDisplayMode: String, CaseIterable {
    case UUID = "UUID"
    case bundleID = "Bundle ID"
    case appName = "App Name"
    
    var displayName: String {
        switch self {
            case .appName: return "应用名称"
            default: return rawValue
        }
    }
}

enum logsdisplaymode: String, CaseIterable {
    case tabs = "In Tabs"
    case toolbar = "In Toolbar"
    case content = "Directly in ContentView"
    
    var displayName: String {
        switch self {
            case .tabs: return "标签页"
            case .toolbar: return "工具栏"
            case .content: return "直接在主页显示"
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var mgr: laramgr
    
    @AppStorage("selectedMethod") private var selectedMethod: method = .hybrid
    @AppStorage("keepAlive") private var keepAlive: Bool = false
    @AppStorage("stashKRW") private var stashKRW: Bool = false
    @AppStorage("keepSpringBoardRemoteCallAliveIOS16") private var keepSpringBoardRemoteCallAliveIOS16: Bool = false
    
    @State private var dlingkcache: Bool = false
    @State private var showkcacheimport: Bool = false
    @State private var importingkcache: Bool = false
    @State private var showkcachetips: Bool = false
    @State private var stashingKRWNow: Bool = false
    
    @AppStorage("logsdisplaymode") private var selectedlogdisplaymode: logsdisplaymode = .toolbar
    @AppStorage("loggerNoBS") private var loggerNoBS: Bool = true
    
    @AppStorage("showFMInTabs") private var showFMInTabs: Bool = true
    @AppStorage("selectedFMAppsDisplayMode") private var selectedFMAppsDisplayMode: fmAppsDisplayMode = .appName
    @AppStorage("fmRecursiveSearch") private var fmRecursiveSearch: Bool = false
    
    @AppStorage("rcDockUnlimited") private var rcDockUnlimited: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: HeaderLabel(text: "关于", icon: "info.circle")) {
                    AppInfoCell()
                    NavigationLink("鸣谢", destination: CreditsView())
                }
                
                Section(header: HeaderLabel(text: "漏洞利用", icon: "ant")) {
                    Picker("", selection: $selectedMethod) {
                        ForEach(method.allCases, id: \.self) { method in
                            Text(method.displayName).tag(method)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    NavigationLink("修改偏移量", destination: OffsetManagementView())
                }
                
                // kernelcache
                Section {
                    if !mgr.hasOffsets {
                        // this does not need to be here any longer, but i'll keep it here anyways.
                        Button {
                            guard !dlingkcache else { return }
                            dlingkcache = true

                            DispatchQueue.global(qos: .userInitiated).async {
                                let fetched = fetchkcache()

                                if fetched {
                                    let dlkc = dlkcache()
                                    DispatchQueue.main.async {
                                        mgr.hasOffsets = dlkc
                                        dlingkcache = false
                                    }
                                    return
                                }

                                DispatchQueue.main.async {
                                    mgr.hasOffsets = false
                                    dlingkcache = false
                                }
                            }
                        } label: {
                            if dlingkcache {
                                HStack {
                                    Text("正在获取内核缓存…")
                                    Spacer()
                                    ProgressView()
                                }
                            } else {
                                Text("获取内核缓存")
                            }
                        }
                        .disabled(dlingkcache || !mgr.dsready)
                               
                        LabeledContent(content: {
                            Button(action: {
                                showkcachetips.toggle()
                            }) {
                                Image(systemName: "info.circle")
                            }
                        }) {
                            Button("导入内核缓存", action: {
                                guard !importingkcache else { return }
                                showkcacheimport = true
                            })
                            .disabled(dlingkcache || importingkcache)
                        }
                    } else {
                        Button("移除内核缓存", action: {
                            Alertinator.shared.alert(title: "清空内核缓存数据？", body: "这会删除全部内核缓存数据并清除已保存的偏移量。之后需要重新获取数据才能继续使用 lara。", actionLabel: "确认", action: {
                                clearKcacheData()
                            })
                        })
                        .foregroundColor(.red)
                    }
                } header: {
                    HeaderLabel(text: "内核缓存", icon: "cpu")
                } footer: {
                    if (!mgr.hasOffsets && (!mgr.dsready || (!mgr.vfsready && !mgr.sbxready))) {
                        Text("注意：需要先点击\"运行漏洞利用\"，才能获取内核缓存。\n\n删除并重新获取内核缓存可能解决部分问题。在提交 GitHub issue 或到我们的 [Discord](https://discord.gg/gw8PcRF3Jr) 寻求帮助之前，建议先试一次。")
                    } else {
                        Text("删除并重新获取内核缓存可能解决部分问题。在提交 GitHub issue 或到我们的 [Discord](https://discord.gg/gw8PcRF3Jr) 寻求帮助之前，建议先试一次。")
                    }
                }
                
                // tips
                if showkcachetips {
                    Section {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("如何获取内核缓存（macOS）")
                                .font(.footnote.weight(.semibold))
                                .foregroundColor(.primary)
                            
                            Text("1. 下载适用于你设备的 IPSW 工具。")
                            Link("https://github.com/blacktop/ipsw/releases",
                                 destination: URL(string: "https://github.com/blacktop/ipsw/releases")!)
                            
                            Text("2. 解压下载的压缩包。")
                            Text("3. 打开“终端”。")
                            Text("4. 进入解压后的目录：")
                            Text("cd /path/to/ipsw_3.1.671_something_something/")
                                .font(.system(.caption2, design: .monospaced))
                                .textSelection(.enabled)
                                .foregroundColor(.primary)
                            
                            Text("5. 提取内核：")
                            Text("./ipsw extract --kernel [drag your ipsw here]")
                                .font(.system(.caption2, design: .monospaced))
                                .textSelection(.enabled)
                                .foregroundColor(.primary)
                            
                            Text("6. 得到 kernelcache 文件。")
                            Text("7. 将 kernelcache 传到 iCloud 或 iPhone 上。")
                            Text("8. 点击上方按钮并选择该 kernelcache，例如 kernelcache.release.iPhone14,3。")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                    }
                }
                
                Section(header: HeaderLabel(text: "应用", icon: "gearshape"), footer: Text("开启“保持运行”后，即使应用被切到后台，也会继续运行。")) {
                    Toggle("保持运行", isOn: $keepAlive)
                        .onChange(of: keepAlive) { _ in
                            if keepAlive {
                                if !kaenabled { toggleka() }
                            } else {
                                if kaenabled { toggleka() }
                            }
                        }
                    Toggle("关闭日志分隔线", isOn: $loggerNoBS)
                    Picker("日志显示", selection: $selectedlogdisplaymode) {
                        ForEach(logsdisplaymode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: HeaderLabel(text: "文件管理器", icon: "folder"), footer: Text("“显示模式”用于调整文件管理器中应用文件夹的呈现方式。")) {
                    Picker("显示模式", selection: $selectedFMAppsDisplayMode) {
                        ForEach(fmAppsDisplayMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(.menu)
                    Toggle("在文件管理器中递归搜索", isOn: $fmRecursiveSearch)
                    Toggle("以标签页形式显示文件管理器", isOn: $showFMInTabs)
                }
                
                #if !DISABLE_REMOTECALL
                Section(header: HeaderLabel(text: "远程调用", icon: "syringe")) {
                    Toggle("暂存内核读写原语", isOn: $stashKRW)
                        .onChange(of: stashKRW) { enabled in
                            if enabled && isIOS16() {
                                Alertinator.shared.alert(
                                    title: "iOS 16 提示",
                                    body: "iOS 16 上保存内核读写目前不稳定，若失败请多手动暂存几次。"
                                )
                            }
                        }
                    if isIOS16() {
                        Toggle("在后台保持 SpringBoard 远程调用", isOn: $keepSpringBoardRemoteCallAliveIOS16)
                        Text("警告：远程调用处于活动状态时若退出 lara，SpringBoard 可能会注销。")
                            .font(.footnote.weight(.semibold))
                            .foregroundColor(.red)

                        Button {
                            guard !stashingKRWNow else { return }
                            stashingKRWNow = true
                            mgr.stashKRWToLaunchd { success in
                                stashingKRWNow = false
                                if success {
                                    Alertinator.shared.alert(
                                        title: "内核读写已暂存",
                                        body: "内核读写原语已成功暂存到 launchd。"
                                    )
                                } else {
                                    let error = mgr.rcLastError ?? "请再手动暂存几次内核读写。"
                                    Alertinator.shared.alert(
                                        title: "暂存内核读写失败",
                                        body: error
                                    )
                                }
                            }
                        } label: {
                            if stashingKRWNow {
                                HStack {
                                    Text("正在将内核读写暂存到 launchd…")
                                    Spacer()
                                    ProgressView()
                                }
                            } else {
                                Text("立即暂存到 launchd")
                            }
                        }
                        .disabled(!mgr.dsready || mgr.rcrunning || stashingKRWNow)
                    }
                    Toggle("允许 Dock 超过 10 个图标", isOn: $rcDockUnlimited)
                }
                #endif
            }
            .navigationTitle("设置")
            .fileImporter(isPresented: $showkcacheimport, allowedContentTypes: [.data], allowsMultipleSelection: false) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    importingkcache = true
                    DispatchQueue.global(qos: .userInitiated).async {
                        var ok = false
                        let shouldStopAccess = url.startAccessingSecurityScopedResource()
                        defer {
                            if shouldStopAccess {
                                url.stopAccessingSecurityScopedResource()
                            }
                        }
                        let fm = FileManager.default
                        if let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first {
                            let dest = docs.appendingPathComponent("kernelcache")
                            do {
                                if fm.fileExists(atPath: dest.path) {
                                    try fm.removeItem(at: dest)
                                }
                                try fm.copyItem(at: url, to: dest)
                                ok = dlkcache()
                            } catch {
                                print("failed to import kernelcache: \(error)")
                                ok = false
                            }
                        }
                        DispatchQueue.main.async {
                            mgr.hasOffsets = ok
                            importingkcache = false
                        }
                    }
                case .failure:
                    break
                }
            }
        }
    }
    
    private func clearKcacheData() {
        let fm = FileManager.default
        
        UserDefaults.standard.removeObject(forKey: "lara.kernelcache_path")
        UserDefaults.standard.removeObject(forKey: "lara.kernelcache_size")
        
        let docsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let kernelcacheDocPath = docsPath.appendingPathComponent("kernelcache")
        
        do {
            if fm.fileExists(atPath: kernelcacheDocPath.path) {
                try fm.removeItem(at: kernelcacheDocPath)
                mgr.logmsg("Deleted kernelcache from Documents")
            }
        } catch {
            mgr.logmsg("Failed to delete kernelcache: \(error.localizedDescription)")
        }
        
        let tempPath = NSTemporaryDirectory()
        let tempFiles = ["kernelcache.release.ipad", "kernelcache.release.iphone", "kernelcache.release.ipad3", "kernelcache.release.iphone14,3"]
        
        for file in tempFiles {
            let path = tempPath + file
            do {
                if fm.fileExists(atPath: path) {
                    try fm.removeItem(atPath: path)
                    mgr.logmsg("Deleted temp kernelcache: \(file)")
                }
            } catch {
                mgr.logmsg("Failed to delete \(file): \(error.localizedDescription)")
            }
        }
        
        mgr.logmsg("Kernelcache data cleared")
        mgr.hasOffsets = false
    }
}
