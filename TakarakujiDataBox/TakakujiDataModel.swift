//
//  TakakujiDataModel.swift
//  TakarakujiDataBox
//
//  Created by Satoshi Wakita on 2024/01/19.
//
//　CoreDataへの保存・編集の処理

import Foundation
import SwiftUI
import CoreData

// 宝くじ種別
public let TAKARAKUJI_TYPE_UNKWON:Int32 = 0
public let TAKARAKUJI_TYPE_NUMBERS3:Int32 = 1
public let TAKARAKUJI_TYPE_NUMBERS4:Int32 = 2
public let TAKARAKUJI_TYPE_MINI:Int32 = 3
public let TAKARAKUJI_TYPE_LOTO6:Int32 = 4
public let TAKARAKUJI_TYPE_LOTO7:Int32 = 5

// Numbersデータ構造体
struct ST_NUMBERS_DATA {
    var numberOftime : Int32
    var timeStamp : Data
    var type : Int32
    var winingNumber : Int16
}

// SwiftUIでデータを監視可能にするためにはObservableObjectプロトコルに準拠したオブジェクト
class TakarakujiDataModel : ObservableObject{
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isTakarakujiType : Int32 = TAKARAKUJI_TYPE_UNKWON
    private let numbers_data :ST_NUMBERS_DATA
    //@PublishedはObservableObjectプロトコルに準拠したクラス内のプロパティを監視
    @Published var updateItem : Numbers!

    // イニシャライザ
    init(Type:Int32) {
        isTakarakujiType = Type
        numbers_data = ST_NUMBERS_DATA
    }
    
    //
    func writeNumbersData(context :NSManagedObjectContext){
        // データが
        if updateItem != nil {
        }
    }
}
