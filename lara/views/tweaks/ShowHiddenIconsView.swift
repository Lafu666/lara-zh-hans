//
//  ShowHiddenIconsView.swift
//  lara
//

import SwiftUI

struct ShowHiddenIconsView: View {
    @ObservedObject var mgr: laramgr

    private let key = "SBIconVisibility"
    private let path = fileloc.globalprefs.rawValue

    @State private var isEnabled = false
    @State private var isLoading = false
    @State private var status: String?
    @State private var confirmRebuildDB = false

    var body: some View {
        List {
            Section(
                header: HeaderLabel(text: "主屏幕", icon: "app.badge"),
                footer: Text("灵感来自 Nugget 的\"在主屏幕显示隐藏图标\"插件。该功能会把 SBIconVisibility 写入 GlobalPreferences。在 SpringBoard 的应用状态数据库重建之前，可能不会生效。")
            ) {
                Toggle("显示隐藏图标", isOn: Binding(
                    get: { isEnabled },
                    set: { setEnabled($0) }
                ))
                .disabled(isLoading || !canWrite)

                HStack {
                    Text("偏好设置")
                    Spacer()
                    Text(isEnabled ? "已开启" : "已关闭")
                        .foregroundColor(isEnabled ? .green : .secondary)
                        .monospaced()
                }
            }

            Section(
                header: HeaderLabel(text: "操作", icon: "wrench.and.screwdriver"),
                footer: Text("刷新只会重新读取 GlobalPreferences 中当前的 SBIconVisibility 值，不会重建 SpringBoard 缓存。")
            ) {
                Button {
                    loadState()
                } label: {
                    if isLoading {
                        HStack {
                            Text("正在刷新…")
                            Spacer()
                            ProgressView()
                        }
                    } else {
                        Text("刷新偏好状态")
                    }
                }
                .disabled(isLoading || !canWrite)

                HStack {
                    Button(role: .destructive) {
                        reset()
                    } label: {
                        Text("移除偏好设置")
                    }
                    .disabled(isLoading || !canWrite)

                    Spacer()

                    Button {
                        Alertinator.shared.alert(
                            title: "移除偏好设置",
                            body: "从 GlobalPreferences 中删除 SBIconVisibility 键（而非写入 false），以恢复默认为值。若 SpringBoard 已缓存旧状态，仍需重建应用状态数据库并重启设备。"
                        )
                    } label: {
                        Image(systemName: "info.circle")
                            .frame(width: 24, height: 22)
                    }
                    .buttonStyle(.plain)
                }

                HStack {
                    Button(role: .destructive) {
                        confirmRebuildDB = true
                    } label: {
                        Text("重建应用状态数据库")
                    }
                    .disabled(isLoading || !canWrite)

                    Spacer()

                    Button {
                        Alertinator.shared.alert(
                            title: "重建应用状态数据库",
                            body: "清空 SpringBoard 的 applicationState.db、applicationState.db-wal 与 applicationState.db-shm，让 SpringBoard 重新生成。应用后请重启设备。注销可能让 SpringBoard 停留在黑屏，部分小组件配置也可能丢失。"
                        )
                    } label: {
                        Image(systemName: "info.circle")
                            .frame(width: 24, height: 22)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("显示隐藏图标")
        .onAppear {
            loadState()
        }
        .alert("显示隐藏图标", isPresented: .constant(status != nil)) {
            Button("好的") { status = nil }
        } message: {
            Text(status ?? "")
        }
        .alert("重建应用状态数据库？", isPresented: $confirmRebuildDB) {
            Button("取消", role: .cancel) {}
            Button("重建", role: .destructive) {
                rebuildApplicationStateDB()
            }
        } message: {
            Text("对应 Nugget 的\"重建 SpringBoard 应用状态数据库\"选项。它会把 SpringBoard 的 applicationState.db 替换为空文件，让 SpringBoard 自行重建。应用后建议重启设备；注销可能导致 SpringBoard 停留在黑屏。重建该数据库还可能重置部分应用与小组件状态（包括小组件配置）。确认接受该风险后再继续。")
        }
    }

    private var canWrite: Bool {
        mgr.sbxready || mgr.vfsready
    }

    private func loadState() {
        guard canWrite else {
            status = "沙箱逃逸或 VFS 未就绪。"
            return
        }

        isLoading = true
        defer { isLoading = false }

        let result = mgr.getplistvalue(path: path, key: key)
        if result.ok, let value = result.value as? Bool {
            isEnabled = value
        } else {
            isEnabled = false
        }
    }

    private func setEnabled(_ enabled: Bool) {
        guard canWrite else {
            status = "沙箱逃逸或 VFS 未就绪。"
            return
        }

        isLoading = true
        defer { isLoading = false }

        let result = mgr.setplistvalue(
            path: path,
            key: (key, enabled ? true : nil),
            force: true
        )

        if result.ok {
            isEnabled = enabled
            status = enabled
                ? "已启用 SBIconVisibility。若看不到效果，可能需要重建 SpringBoard 的应用状态数据库，然后重启设备。"
                : "已移除 SBIconVisibility 偏好设置。若看不到效果，请重建 SpringBoard 的应用状态数据库，然后重启设备。"
        } else {
            status = result.message
            loadState()
        }
    }

    private func reset() {
        setEnabled(false)
    }

    private func rebuildApplicationStateDB() {
        guard canWrite else {
            status = "沙箱逃逸或 VFS 未就绪。"
            return
        }

        isLoading = true
        defer { isLoading = false }

        let dbPaths = [
            "/var/mobile/Library/FrontBoard/applicationState.db",
            "/var/mobile/Library/FrontBoard/applicationState.db-wal",
            "/var/mobile/Library/FrontBoard/applicationState.db-shm",
        ]

        var failures: [String] = []
        for dbPath in dbPaths {
            let result = mgr.lara_overwritefile(target: dbPath, data: Data())
            if !result.ok {
                failures.append("\(dbPath): \(result.message)")
            }
        }

        if failures.isEmpty {
            status = "已清除应用状态数据库，请立即重启设备。不要依赖注销，它可能让 SpringBoard 停留在黑屏，部分小组件配置也可能丢失。"
        } else {
            status = failures.joined(separator: "\n")
        }
    }
}

#Preview {
    NavigationStack {
        ShowHiddenIconsView(mgr: laramgr.shared)
    }
}
