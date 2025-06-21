//
//  ContentViewNumbers.swift
//  TakarakujiDataBox
//
//  Created by Satoshi Wakita on 2024/03/16.
//

import Foundation
import SwiftUI
import CoreData

struct Numbers3Page: View {
    @State var date = Date()
    @State var numOfTime: Int = 9999
    @State var winNumber: Int = 999
    @State var buttonText = "更新"
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
            entity: Loto.entity(),                                                       // エンティティ生成
            sortDescriptors: [NSSortDescriptor(key: "numberOfTime", ascending: false)],  // 回数でソート
            animation: .default
        ) var fetchedMemoList: FetchedResults<Loto>
    
    var body: some View {
        VStack{
            Spacer()
            Text("Numbers3")
                .padding()
                .font(.title)

            HStack{
                DatePicker(
                    "抽選日",
                    selection: $date,
                    displayedComponents: [.date]
                ).padding()
            }
            HStack{
                Text("回数")
                    .padding()
                TextField("NNNN", value: $numOfTime, format: .number)
                    .keyboardType(.numberPad)       // キーボードの入力設定
                    .textFieldStyle(.roundedBorder) // 枠線表示
                    .frame(width: 90.0)             // 入力枠の大きさ(幅)
                    .padding()

            }
            HStack{
                Text("当選数字")
                    .padding()
                TextField("NNNN", value: $winNumber, format: .number)
                    .textFieldStyle(.roundedBorder) // 枠線表示
                    .frame(width: 70.0)            // 入力枠の大きさ(幅)
            }
            HStack{
                // ボタン押下
                Button(action: {
                    updateNumbers3()
                }){
                    Text("更新")
                        .bold()
                        .padding()
                        .frame(width: 100, height: 50)
                        .foregroundColor(Color.white)
                        .background(Color.blue)
                        .padding()
                }

                Button(action: {

                }){
                    Text("削除")
                        .bold()
                        .padding()
                        .frame(width: 100, height: 50)
                        .foregroundColor(Color.white)
                        .background(Color.red)
                        .padding()
                }
            }.padding()

            NavigationLink(destination: Number3DsitributionMap()) {
                Text("Numbers3 Distribution Map")
                    .font(.system(size:15))
            }.padding()
        }
    }
    // Numbers3更新
    private func updateNumbers3(){
        let Num3 = Numbers(context: viewContext)
        Num3.type = Int32(TAKARAKUJI_LOTO_TYPE_NUMBERS3)
        Num3.timestamp = date
        Num3.numberOfTime = Int32(numOfTime)          // 回数設定
        Num3.winingNumber = Int16(winNumber)
        try? viewContext.save()
    }
    
}

struct Number3DsitributionMap:View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
            entity: Numbers.entity(),                                                    // エンティティ生成
            sortDescriptors: [NSSortDescriptor(key: "numberOfTime", ascending: false)],  // 回数でソート
            animation: .default
        ) var fetchedMemoList: FetchedResults<Numbers>

    // 列に関する設定
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 11)
    var body: some View {
        Text("Numbers3 LazyVGrid")
        // LazyGridのヘッダー部
        LazyVGrid(columns: columns) {
            ForEach(0...10, id: \.self) { value in
                if value > 0 {
                    Text(String(format: "%d", value))
                        .frame(width: 35, height: 25)
                        .background(Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 1.0))
                        .font(.system(size: 17, weight: .black, design: .default))
                        .foregroundColor(Color.white)
                        .padding()
                }else{
                    Text("回数")
                        .frame(width: 55, height: 25)
                        .background(Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 1.0))
                        .font(.system(size: 15, weight: .black, design: .default))
                        .foregroundColor(Color.white)
                        .padding()

                }
            }
        }.padding()
        
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(0...9, id: \.self) { value in
                                         Text(String(format: "%d", value))
                                             .frame(width: 40, height: 25)
                                             .background(Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 1.0))
                                             .font(.system(size: 17, weight: .black, design: .default))
                                             .foregroundColor(Color.white)
                                             .padding()
                      
                }
            }.padding()
        }
    }
}
