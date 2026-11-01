//
//  CCView.swift
//  lara
//
//  Created by ruter on 16.04.26.
//

import SwiftUI

struct CCView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                } header: {
                    Text("RespringCC")
                } footer: {
                    Text("使用 lara 的注销助手。")
                }
            }
            .navigationTitle("控制中心")
        }
    }
}
