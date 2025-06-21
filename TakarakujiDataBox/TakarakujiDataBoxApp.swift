//
//  TakarakujiDataBoxApp.swift
//  TakarakujiDataBox
//
//  Created by Satoshi Wakita on 2023/08/14.
//

import SwiftUI

@main
struct TakarakujiDataBoxApp: App {
    // PersistenceController の共有インスタンスを初期化
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        // ビュー階層のコンテナ
        WindowGroup {
            ContentView()
                //　コンテンツビューがデータベースにアクセスできるように環境変数を設定する
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
