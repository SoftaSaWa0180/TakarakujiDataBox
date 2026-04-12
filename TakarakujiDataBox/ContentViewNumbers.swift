//
//  ContentViewNumbers.swift
//  TakarakujiDataBox
//
//  Created by Satoshi Wakita on 2024/03/16.
//

import Foundation
import SwiftUI
import CoreData

// Numbers3メニュー
struct Numbers3Page: View {
    @State var date = Date()
    @State var numOfTime: Int = 9999
    @State var winNumber: Int = 999
    @State var buttonText = "更新"
    // Core DataのNSManagedObjectContextにアクセスするための環境変数
    // ビュー内でデータの追加・削除・保存（保存）を行う際に必須のコンテキストを取得し、データベース操作を安全に行います。
    @Environment(\.managedObjectContext) private var viewContext
    // NumbersデータベースからNumbers3のみを日付で降順でピックアップする
    @FetchRequest(
            entity: Numbers.entity(),
            sortDescriptors: [NSSortDescriptor(key: "numberOfTime", ascending: false)],
            // ソート対象をデータタイプ（宝くじ種別）でNumbers3のみとする
            predicate: NSPredicate(format: "type == %d", TAKARAKUJI_LOTO_TYPE_NUMBERS3),
            animation: .default
        ) var fetchedMemoList: FetchedResults<Numbers>
    
    // 値なしもあり得るので？をつける
    @State private var selectedItem: Numbers?
    @State private var showAddSheet = false
    @State private var showDeleteAllAlert = false
    
    // Numbers3メニュー内容を表示
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("Numbers3")
                .font(.title)
                .padding(.top, 8)
                .padding(.bottom, 8)
            //　登録されているナンバーズデータ（@FetchRequest）からリスト表示する
            List(fetchedMemoList) { item in
                // 左端を基準に左寄せLeading）で整列
                VStack(alignment: .leading) {
                    // 日付データがNULLでない場合のみ
                    if let date = item.timestamp {
                        Text("抽選日: \(date.formatted(date: .numeric, time: .omitted))")
                    }
                    Text("回数: \(item.numberOfTime)")
                    Text("当選数字: \(item.winingNumber)")
                }
                // リストの各行を長押し/押下でポップアップメニューを出す
                // Listの各行にcontextMenuを配置
                // リストは長押しする。
                .contextMenu {
                    Button {
                        // 選択リストの該当のレコードを保持
                        selectedItem = item
                    } label: {
                        Label("変更", systemImage: "info.circle")
                    }
                    // 削除などの破壊アクションをするボタン(赤色表示)
                    Button(role: .destructive) {
                        // Data Coreから該当レコード削除
                        delete(item)
                    } label: {
                        Label("削除", systemImage: "trash")
                    }
                }
            }
            .frame(height: 500)
            // モーダル表示
            // 特定のデータが存在するときに画面を下からスワイプアップ表示する
            .sheet(item: $selectedItem) { target in
                NumbersDetailView(item: target)
                    .environment(\.managedObjectContext, viewContext)
            }
            // 追加ボタンによるモーダル表示
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

                // ボタン押下
                Button(action: {
                    // 全削除が押下フラグにON設定
                    confirmDeleteAll()
                }){
                    Text("全削除")
                        .bold()
                        .padding()
                        .frame(width: 100, height: 50)
                        .foregroundColor(Color.white)
                        .background(Color.blue)
                        .padding()
                }

            }.padding()
            // 全削除が押下フラグによって確認アラートを表示。アラートモデファイア実行
            .alert("全て削除しますか？", isPresented: $showDeleteAllAlert) {
                Button("キャンセル", role: .cancel) {}
                Button("削除", role: .destructive) { deleteAll() }
            } message: {
                Text("Numbers3 の全レコードを削除します。この操作は取り消せません。")
            }

            // Numbers3分布表画面へ遷移
            NavigationLink(destination: Number3DsitributionMap()) {
                Text("Numbers3 Distribution Map")
                    .font(.system(size:15))
            }.padding()
        }
    }
    
    // レコード削除
    private func delete(_ item: Numbers) {
        viewContext.delete(item)
        do {
            try viewContext.save()
        } catch {
            print("Failed to delete: \(error)")
        }
    }
    // 全削除が押下フラグにON設定
    private func confirmDeleteAll() {
        showDeleteAllAlert = true
    }

    // Numbers3 全レコード削除
    private func deleteAll() {
        // fetchedMemoList は Numbers3 のみを取得する FetchRequest
        for item in fetchedMemoList {
            viewContext.delete(item)
        }
        do {
            try viewContext.save()
        } catch {
            print("Failed to delete all: \(error)")
        }
    }
    
}

// Numbers4　メニュー画面表示
struct Numbers4Page: View {
    @State var date = Date()
    @State var numOfTime: Int = 9999
    @State var winNumber: Int = 9999
    @State var buttonText = "更新"
    // Core DataのNSManagedObjectContextにアクセスするための環境変数
    // ビュー内でデータの追加・削除・保存（保存）を行う際に必須のコンテキストを取得し、データベース操作を安全に行います。
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
            entity: Numbers.entity(),
            sortDescriptors: [NSSortDescriptor(key: "numberOfTime", ascending: false)],
            // ソート対象をデータタイプ（宝くじ種別）でNumbers4のみとする
            predicate: NSPredicate(format: "type == %d", TAKARAKUJI_LOTO_TYPE_NUMBERS4),
            animation: .default
        ) var fetchedMemoList: FetchedResults<Numbers>
    
    @State private var selectedItem: Numbers?
    @State private var showAddSheet = false
    @State private var showDeleteAllAlert = false

    // 表示内容を作成
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("Numbers4")
                .font(.title)
                .padding(.top, 8)
                .padding(.bottom, 8)
            // 登録されているナンバーズデータ（@FetchRequest）からリスト表示する
            List(fetchedMemoList) { item in
                VStack(alignment: .leading) {
                    // 日付データがある場合(NULLでない)
                    if let date = item.timestamp {
                        Text("抽選日: \(date.formatted(date: .numeric, time: .omitted))")
                    }
                    Text("回数: \(item.numberOfTime)")
                    Text("当選数字: \(String(format: "%04d", Int(item.winingNumber)))")
                }
                // リスト長押しで表示されるサブメニュー
                .contextMenu {
                    Button { selectedItem = item } label: {
                        Label("変更", systemImage: "info.circle")
                    }
                    Button(role: .destructive) { delete(item) } label: {
                        Label("削除", systemImage: "trash")
                    }
                }
            }
            .frame(height: 500)
            // モーダル表示
            // 特定のデータが存在するときに画面を下からスワイプアップ表示する
            .sheet(item: $selectedItem) { target in
                Numbers4DetailView(item: target)
                    .environment(\.managedObjectContext, viewContext)
            }
            // モーダル表示
            .sheet(isPresented: $showAddSheet) {
                Numbers4CreateView()
                    .environment(\.managedObjectContext, viewContext)
            }
            
            HStack{
                Button(action: { showAddSheet = true }){
                    Text("追加")
                        .bold()
                        .padding()
                        .frame(width: 100, height: 50)
                        .foregroundColor(Color.white)
                        .background(Color.blue)
                        .padding()
                }

                Button(action: { confirmDeleteAll() }){
                    Text("全削除")
                        .bold()
                        .padding()
                        .frame(width: 100, height: 50)
                        .foregroundColor(Color.white)
                        .background(Color.blue)
                        .padding()
                }

            }.padding()
            // 全削除が押下フラグによって確認アラートを表示。アラートモデファイア実行
            .alert("全て削除しますか？", isPresented: $showDeleteAllAlert) {
                Button("キャンセル", role: .cancel) {}
                Button("削除", role: .destructive) { deleteAll() }
            } message: {
                Text("Numbers4 の全レコードを削除します。この操作は取り消せません。")
            }
            
            // Numbers4分布表画面へ遷移
            NavigationLink(destination: Number4DistributionMap()) {
                Text("Numbers4 Distribution Map")
                    .font(.system(size:15))
            }.padding()
        }
    }

    private func delete(_ item: Numbers) {
        viewContext.delete(item)
        do { try viewContext.save() } catch { print("Failed to delete: \(error)") }
    }

    private func confirmDeleteAll() { showDeleteAllAlert = true }

    private func deleteAll() {
        for item in fetchedMemoList { viewContext.delete(item) }
        do { try viewContext.save() } catch { print("Failed to delete all: \(error)") }
    }
}

// Numbers3分布表の表示画面
struct Number3DsitributionMap: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
            entity: Numbers.entity(),                                                    // エンティティ生成
            sortDescriptors: [NSSortDescriptor(key: "numberOfTime", ascending: false)],  // 回数でソート
            // Numbers3 のみを対象にする
            predicate: NSPredicate(format: "type == %d", TAKARAKUJI_LOTO_TYPE_NUMBERS3),
            animation: .default
        ) var fetchedMemoList: FetchedResults<Numbers>

    var body: some View {
        let columns: [GridItem] = [GridItem(.fixed(55))] + Array(repeating: GridItem(.fixed(35)), count: 10)
        ScrollView(.horizontal) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Numbers3 LazyVGrid")
                // Header
                LazyVGrid(columns: columns, spacing: 0) {
                    Text("回数")
                        .frame(width: 55, height: 25)
                        .background(Color.black)
                        .font(.system(size: 15, weight: .black))
                        .foregroundColor(.white)
                        .overlay(
                            Rectangle()
                                .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                        )
                    ForEach(0..<10) { value in
                        Text("\(value)")
                            .frame(width: 35, height: 25)
                            .background(Color.black)
                            .font(.system(size: 15, weight: .black))
                            .foregroundColor(.white)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                            )
                    }
                }

                // Rows
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(fetchedMemoList) { item in
                            // 左端: 回数
                            Text("\(item.numberOfTime)")
                                .frame(width: 55, height: 25)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.primary)
                                .background(Color(white: 0.95))
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                                )

                            // 当選数字の3桁を抽出
                            let num = Int(item.winingNumber)
                            let d0 = (num / 100) % 10
                            let d1 = (num / 10) % 10
                            let d2 = num % 10
                            let digits: Set<Int> = [d0, d1, d2]

                            ForEach(0..<10) { value in
                                Text(digits.contains(value) ? "●" : "")
                                    .frame(width: 35, height: 25)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.blue)
                                    .background(Color(white: 1.0))
                                    .overlay(
                                        Rectangle()
                                            .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                                    )
                            }
                        }
                    }
                }
            }
        }
    }
}

// Numbers4分布表の表示画面
struct Number4DistributionMap: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
            entity: Numbers.entity(),                                                    // エンティティ生成
            sortDescriptors: [NSSortDescriptor(key: "numberOfTime", ascending: false)],  // 回数でソート
            // Numbers4 のみを対象にする
            predicate: NSPredicate(format: "type == %d", TAKARAKUJI_LOTO_TYPE_NUMBERS4),
            animation: .default
        ) var fetchedMemoList: FetchedResults<Numbers>

    var body: some View {
        let columns: [GridItem] = [GridItem(.fixed(55))] + Array(repeating: GridItem(.fixed(35)), count: 10)
        ScrollView(.horizontal) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Numbers4 LazyVGrid")
                // Header
                LazyVGrid(columns: columns, spacing: 0) {
                    Text("回数")
                        .frame(width: 55, height: 25)
                        .background(Color.black)
                        .font(.system(size: 15, weight: .black))
                        .foregroundColor(.white)
                    ForEach(0..<10) { value in
                        Text("\(value)")
                            .frame(width: 35, height: 25)
                            .background(Color.black)
                            .font(.system(size: 15, weight: .black))
                            .foregroundColor(.white)
                    }
                }

                // Rows
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(fetchedMemoList) { item in
                            // 左端: 回数
                            Text("\(item.numberOfTime)")
                                .frame(width: 55, height: 25)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.primary)
                                .background(Color(white: 0.95))

                            // 当選数字の4桁を抽出
                            let num = Int(item.winingNumber)
                            let d0 = (num / 1000) % 10
                            let d1 = (num / 100) % 10
                            let d2 = (num / 10) % 10
                            let d3 = num % 10
                            let digits: [Int] = [d0, d1, d2, d3]

                            ForEach(0..<10) { value in
                                Text(digits.contains(value) ? "●" : "")
                                    .frame(width: 35, height: 25)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.blue)
                                    .background(Color(white: 1.0))
                            }
                        }
                    }
                }
            }
        }
    }
}

// 既存レコードの変更画面表示
struct NumbersDetailView: View {
    // CoreDataを変更するためのコンテキストを取得
    @Environment(\.managedObjectContext) private var viewContext
    // 現在のプレゼンテーションを破棄するため、環境変数から現在のインスタンスを取得する
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var item: Numbers

    @State private var date: Date = Date()
    @State private var numberOfTimeText: String = ""
    @State private var winNumberText: String = ""

    // 内容表示
    var body: some View {
        NavigationStack {
            // Formを使用すると画面全体を覆うスクロールリストが生成される
            Form {
                // Section は List や From と組み合わせて使用することで、表示する項目（View）のグループ化
                Section(header: Text("詳細")) {
                    HStack {
                        Text("抽選日")
                        Spacer()
                        Text((item.timestamp ?? Date()).formatted(date: .numeric, time: .omitted))
                            .foregroundStyle(.secondary)
                    }
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
                }
                // カレンダーをボタン表示
                DatePicker("抽選日", selection: $date, displayedComponents: .date)
                TextField("回数", text: $numberOfTimeText)
                    .keyboardType(.numberPad)
                TextField("当選数字(3桁)", text: $winNumberText)
                    .keyboardType(.numberPad)
                    .onChange(of: winNumberText) { newValue in
                        // 数字以外を除去し、最大3桁に制限
                        let digits = newValue.filter { $0.isNumber }
                        if digits.count > 3 {
                            winNumberText = String(digits.prefix(3))
                        } else if digits != newValue {
                            winNumberText = digits
                        }
                    }
            }
            .navigationTitle("変更")
            // ツールバー表示
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
    // 変更レコードの保存
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

// 新規レコード追加処理
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
                TextField("当選数字(3桁)", text: $winNumberText)
                    .keyboardType(.numberPad)
                    .onChange(of: winNumberText) { newValue in
                        // 数字以外を除去し、最大3桁に制限
                        let digits = newValue.filter { $0.isNumber }
                        if digits.count > 3 {
                            winNumberText = String(digits.prefix(3))
                        } else if digits != newValue {
                            winNumberText = digits
                        }
                    }
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

// 既存レコードの変更画面表示
struct Numbers4DetailView: View {
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
                        Text("抽選日")
                        Spacer()
                        Text((item.timestamp ?? Date()).formatted(date: .numeric, time: .omitted))
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("回数")
                        Spacer()
                        Text("\(Int(item.numberOfTime))")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("当選数字")
                        Spacer()
                        Text(String(format: "%04d", Int(item.winingNumber)))
                            .foregroundStyle(.secondary)
                    }
                }
                DatePicker("抽選日", selection: $date, displayedComponents: .date)
                TextField("回数", text: $numberOfTimeText)
                    .keyboardType(.numberPad)
                TextField("当選数字(4桁)", text: $winNumberText)
                    .keyboardType(.numberPad)
            }
            .navigationTitle("変更")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("キャンセル") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("保存") { save() } }
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
        do { try viewContext.save(); dismiss() } catch { print("Failed to save: \(error)") }
    }
}

struct Numbers4CreateView: View {
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
                TextField("当選数字(4桁)", text: $winNumberText)
                    .keyboardType(.numberPad)
                    .onChange(of: winNumberText) { newValue in
                        // 数字以外を除去し、最大4桁に制限
                        let digits = newValue.filter { $0.isNumber }
                        if digits.count > 4 {
                            winNumberText = String(digits.prefix(4))
                        } else if digits != newValue {
                            winNumberText = digits
                        }
                    }
            }
            .navigationTitle("追加")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("キャンセル") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("保存") { save() } }
            }
        }
    }

    private func save() {
        let num4 = Numbers(context: viewContext)
        num4.type = Int32(TAKARAKUJI_LOTO_TYPE_NUMBERS4)
        num4.timestamp = date
        let numberOfTime = Int(numberOfTimeText) ?? 0
        let winNumber = Int(winNumberText) ?? 0
        num4.numberOfTime = Int32(numberOfTime)
        num4.winingNumber = Int16(winNumber)
        do { try viewContext.save(); dismiss() } catch { print("Failed to save: \(error)") }
    }
}

