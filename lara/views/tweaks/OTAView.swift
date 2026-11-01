import SwiftUI

struct OTAView: View {
    @ObservedObject var mgr: laramgr
    @AppStorage("lara.ota.disabled") private var otaDisabled: Bool = false
    @State private var isWorking: Bool = false
    @State private var lastResult: String? = nil

    var body: some View {
        List {
            Section(header: HeaderLabel(text: "状态", icon: "antenna.radiowaves.left.and.right")) {
                HStack {
                    Text("OTA 更新")
                    Spacer()
                    Text(otaDisabled ? "已关闭" : "已开启")
                        .foregroundColor(otaDisabled ? .red : .green)
                        .monospaced()
                }
            }

            Section(
                header: HeaderLabel(text: "操作", icon: "wrench.and.screwdriver"),
                footer: Text("通过远程调用修改 launchd 的 disabled.plist，阻止 OTA 更新相关守护进程运行。需要重启设备后生效。")
            ) {
                Button {
                    apply(disabled: true)
                } label: {
                    if isWorking && !otaDisabled {
                        HStack {
                            Text("正在关闭…")
                            Spacer()
                            ProgressView()
                        }
                    } else {
                        Text("关闭 OTA 更新")
                    }
                }
                .disabled(isWorking || otaDisabled)

                Button {
                    apply(disabled: false)
                } label: {
                    if isWorking && otaDisabled {
                        HStack {
                            Text("正在开启…")
                            Spacer()
                            ProgressView()
                        }
                    } else {
                        Text("开启 OTA 更新")
                    }
                }
                .disabled(isWorking || !otaDisabled)
            }
        }
        .navigationTitle("OTA 更新")
        .onAppear {
            if !otaDisabled {
                syncStateFromPlist()
            }
        }
        .alert("结果", isPresented: .constant(lastResult != nil)) {
            Button("好的") { lastResult = nil }
        } message: {
            Text(lastResult ?? "")
        }
    }

    private func syncStateFromPlist() {
        DispatchQueue.global(qos: .userInitiated).async {
            let plistPath = "/private/var/db/com.apple.xpc.launchd/disabled.plist"
            let daemonLabels = [
                "com.apple.mobile.softwareupdated",
                "com.apple.OTATaskingAgent",
                "com.apple.softwareupdateservicesd",
                "com.apple.mobile.NRDUpdated",
            ]
            guard let data = NSData(contentsOfFile: plistPath) as Data?,
                  let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
                return
            }
            let allDisabled = daemonLabels.allSatisfy { (plist[$0] as? Bool) == true }
            if allDisabled {
                DispatchQueue.main.async {
                    otaDisabled = true
                }
            }
        }
    }

    private func apply(disabled: Bool) {
        isWorking = true
        DispatchQueue.global(qos: .userInitiated).async {
            let ok = ota_set_disabled(disabled)
            DispatchQueue.main.async {
                isWorking = false
                if ok {
                    otaDisabled = disabled
                    lastResult = disabled
                        ? "已关闭 OTA 更新，重启后生效。"
                        : "已开启 OTA 更新，重启后生效。"
                } else {
                    lastResult = "Operation failed. Check logs for details."
                }
            }
        }
    }
}
