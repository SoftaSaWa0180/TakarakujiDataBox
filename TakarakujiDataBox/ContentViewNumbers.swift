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
            entity: Numbers.entity(),
            sortDescriptors: [NSSortDescriptor(key: "numberOfTime", ascending: false)],
            // ソート対象をデータタイプ（宝くじ種別）でNumbers3のみとする
            predicate: NSPredicate(format: "type == %d", TAKARAKUJI_LOTO_TYPE_NUMBERS3),
            animation: .default
        ) var fetchedMemoList: FetchedResults<Numbers>
    
    @State private var selectedItem: Numbers?
    @State private var showAddSheet = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("Numbers3")
                .font(.title)
                .padding(.top, 8)
                .padding(.bottom, 8)
            //登録されているナンバーズデータ（@FetchRequest）からリスト表示する
            List(fetchedMemoList) { item in
                VStack(alignment: .leading) {
                    Text("回数: \(item.numberOfTime)")
                    Text("当選数字: \(item.winingNumber)")
                    if let date = item.timestamp {
                        Text("抽選日: \(date.formatted(date: .numeric, time: .omitted))")
                    }
                }
                // リストの各行を長押し/押下でポップアップメニューを出す
                // Listの各行にcontextMenuを配置
                // リストは長押しする。
                .contextMenu {
                    Button {
                        selectedItem = item
                    } label: {
                        Label("変更", systemImage: "info.circle")
                    }
                    Button(role: .destructive) {
                        delete(item)
                    } label: {
                        Label("削除", systemImage: "trash")
                    }
                }
            }
            .frame(height: 500)
            .sheet(item: $selectedItem) { target in
                NumbersDetailView(item: target)
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showAddSheet) {
                NumbersCreateView()
                    .environment(\.managedObjectContext, viewContext)
            }
            
            HStack{
                // ボタン押下
                Button(action: {
                    showAddSheet = true
                }){
                    Text("追加")
                        .bold()
                        .padding()
                        .frame(width: 100, height: 50)
                        .foregroundColor(Color.white)
                        .background(Color.blue)
                        .padding()
                }
            }.padding()


            NavigationLink(destination: Number3DsitributionMap()) {
                Text("Numbers3 Distribution Map")
                    .font(.system(size:15))
            }.padding()
        }
    }
    
    private func delete(_ item: Numbers) {
        viewContext.delete(item)
        do {
            try viewContext.save()
        } catch {
            print("Failed to delete: \(error)")
        }
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

struct NumbersDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var item: Numbers

    @State private var date: Date = Date()
    @State private var numberOfTimeText: String = ""
    @State private var winNumberText: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("詳細")) {
                    HStack {
                        Text("回数")
                        Spacer()
                        Text("\(Int(item.numberOfTime))")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("当選数字")
                        Spacer()
                        Text(String(format: "%03d", Int(item.winingNumber)))
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("抽選日")
                        Spacer()
                        Text((item.timestamp ?? Date()).formatted(date: .numeric, time: .omitted))
                            .foregroundStyle(.secondary)
                    }
                }
                DatePicker("抽選日", selection: $date, displayedComponents: .date)
                TextField("回数", text: $numberOfTimeText)
                    .keyboardType(.numberPad)
                TextField("当選数字(3桁)", text: $winNumberText)
                    .keyboardType(.numberPad)
            }
            .navigationTitle("変更")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                }
            }
            .onAppear {
                date = item.timestamp ?? Date()
                numberOfTimeText = String(Int(item.numberOfTime))
                winNumberText = String(Int(item.winingNumber))
            }
        }
    }

    private func save() {
        item.timestamp = date
        let numberOfTime = Int(numberOfTimeText) ?? 0
        let winNumber = Int(winNumberText) ?? 0
        item.numberOfTime = Int32(numberOfTime)
        item.winingNumber = Int16(winNumber)
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Failed to save: \(error)")
        }
    }
}

struct NumbersCreateView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var date: Date = Date()
    @State private var numberOfTimeText: String = ""
    @State private var winNumberText: String = ""

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("抽選日", selection: $date, displayedComponents: .date)
                TextField("回数", text: $numberOfTimeText)
                    .keyboardType(.numberPad)
                TextField("当選数字", text: $winNumberText)
                    .keyboardType(.numberPad)
            }
            .navigationTitle("追加")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                }
            }
        }
    }

    private func save() {
        let num3 = Numbers(context: viewContext)
        num3.type = Int32(TAKARAKUJI_LOTO_TYPE_NUMBERS3)
        num3.timestamp = date
        let numberOfTime = Int(numberOfTimeText) ?? 0
        let winNumber = Int(winNumberText) ?? 0
        num3.numberOfTime = Int32(numberOfTime)
        num3.winingNumber = Int16(winNumber)
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Failed to save: \(error)")
        }
    }
}

