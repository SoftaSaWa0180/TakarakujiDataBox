//
//  Persistence.swift
//
//  Created by Satoshi Wakita on 2023/12/13.
//

import CoreData

//NSPersistentContainerの初期化について記述されているファイル
//
// LOTO種別
let TAKARAKUJI_LOTO_TYPE_UNKWON:Int32 = 0
let TAKARAKUJI_LOTO_TYPE_NUMBERS3:Int32 = 1
let TAKARAKUJI_LOTO_TYPE_NUMBERS4:Int32 = 2
let TAKARAKUJI_LOTO_TYPE_MINI:Int32 = 3
let TAKARAKUJI_LOTO_TYPE_LOTO6:Int32 = 4
let TAKARAKUJI_LOTO_TYPE_LOTO7:Int32 = 5


struct PersistenceController {
    // 永続コンテナコントローラーをインスタンス化
    static let shared = PersistenceController()

    // PersistenceController.previewではプレビュー用のDB初期値が設定
    static var preview: PersistenceController = {
        // 仮装DBへの反映のみ
        let result = PersistenceController(inMemory: true)
        // ビューコンテキスト取得
        let viewContext = result.container.viewContext
        
        let newNumbers = Numbers(context: viewContext)
        newNumbers.type = TAKARAKUJI_LOTO_TYPE_UNKWON
        newNumbers.timestamp = Date()
        newNumbers.numberOfTime = 0
        newNumbers.winingNumber = 0

        let newLoto = Loto(context: viewContext)
        newLoto.bonusNumber1 = 0
        newLoto.bonusNumber2 = 0
        newLoto.number1 = 0
        newLoto.number2 = 0
        newLoto.number3 = 0
        newLoto.number4 = 0
        newLoto.number5 = 0
        newLoto.number6 = 0
        newLoto.number7 = 0
        newLoto.numberOfTime = 0
        newLoto.timestamp = Date()        

        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    // コンテナがデータをメモリ内に保存しない
    init(inMemory: Bool = false) {
        //　TakarakujiDataBoxアプリからのイベント通知受ける
        container = NSPersistentCloudKitContainer(name: "TakarakujiDataBox")
        if inMemory {
            //　保存先URL
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        // 永続コンテナが初期化されたら、永続ストアをロード「してコアデータスタックの作成を完了を受ける
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
