//
//  ContentViewMiniLoto.swift
//  TakarakujiDataBox
//
//  Created by Satoshi Wakita on 2026/04/12.
//

import SwiftUI
import CoreData
// Mini Loto メニュー（Numbers3 と同様のレイアウトでリスト表示）
struct MiniLotoPage: View {
    // Core Data のコンテキスト
    @Environment(\.managedObjectContext) private var viewContext

    // Mini Loto のみを回数降順で取得
    @FetchRequest(
        entity: Loto.entity(),
        sortDescriptors: [NSSortDescriptor(key: "numberOfTime", ascending: false)],
        predicate: NSPredicate(format: "type == %d", TAKARAKUJI_LOTO_TYPE_MINI),
        animation: .default
    ) private var fetchedMiniLotoList: FetchedResults<Loto>

    // 選択・モーダル制御
    @State private var selectedItem: Loto?
    @State private var showAddSheet = false
    @State private var showDeleteAllAlert = false

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("Mini Loto")
                .font(.title)
                .padding(.top, 8)
                .padding(.bottom, 8)

            // 登録されているミニロトデータをリスト表示
            List(fetchedMiniLotoList) { item in
                VStack(alignment: .leading) {
                    if let date = item.timestamp {
                        Text("抽選日: \(date.formatted(date: .numeric, time: .omitted))")
                    }
                    Text("回数: \(item.numberOfTime)")
                    // 当選数字: 5個 + ボーナス
                    let n1 = Int(item.number1)
                    let n2 = Int(item.number2)
                    let n3 = Int(item.number3)
                    let n4 = Int(item.number4)
                    let n5 = Int(item.number5)
                    let b1 = Int(item.bonusNumber1)
                    Text("当選数字: \(n1), \(n2), \(n3), \(n4), \(n5)  ボーナス: \(b1)")
                }
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
            // 既存レコード編集（雛形）
            .sheet(item: $selectedItem) { target in
                MiniLotoDetailView(item: target)
                    .environment(\.managedObjectContext, viewContext)
            }
            // 新規追加（雛形）
            .sheet(isPresented: $showAddSheet) {
                MiniLotoCreateView()
                    .environment(\.managedObjectContext, viewContext)
            }

            HStack {
                Button(action: { showAddSheet = true }) {
                    Text("追加")
                        .bold()
                        .padding()
                        .frame(width: 100, height: 50)
                        .foregroundColor(Color.white)
                        .background(Color.blue)
                        .padding()
                }
                Button(action: { confirmDeleteAll() }) {
                    Text("全削除")
                        .bold()
                        .padding()
                        .frame(width: 100, height: 50)
                        .foregroundColor(Color.white)
                        .background(Color.blue)
                        .padding()
                }
            }
            .padding()
            .alert("全て削除しますか？", isPresented: $showDeleteAllAlert) {
                Button("キャンセル", role: .cancel) {}
                Button("削除", role: .destructive) { deleteAll() }
            } message: {
                Text("Mini Loto の全レコードを削除します。この操作は取り消せません。")
            }
            // Mini Loto 分布表画面へ遷移
            NavigationLink(destination: MiniLotoDistributionMap()) {
                Text("Mini Loto Distribution Map")
                    .font(.system(size:15))
            }.padding()
        }
    }

    // 単一削除
    private func delete(_ item: Loto) {
        viewContext.delete(item)
        do { try viewContext.save() } catch { print("Failed to delete: \(error)") }
    }

    // 全削除確認
    private func confirmDeleteAll() { showDeleteAllAlert = true }

    // 全削除（Mini Loto のみ）
    private func deleteAll() {
        for item in fetchedMiniLotoList { viewContext.delete(item) }
        do { try viewContext.save() } catch { print("Failed to delete all: \(error)") }
    }
}

// 既存レコードの変更画面（最小実装の雛形）
struct MiniLotoDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var item: Loto

    @State private var date: Date = Date()
    @State private var numberOfTimeText: String = ""
    @State private var number1Text: String = ""
    @State private var number2Text: String = ""
    @State private var number3Text: String = ""
    @State private var number4Text: String = ""
    @State private var number5Text: String = ""
    @State private var bonusNumber1Text: String = ""

    // 表示内容
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
                }
                // 日付カレンダー表示、選択ツール
                DatePicker("抽選日", selection: $date, displayedComponents: .date)
                TextField("回数", text: $numberOfTimeText)
                    .keyboardType(.numberPad)

                // 画面フォーム上のセクション名
                Section(header: Text("当選番号（本数字）")) {
                    Text("1から31までの数字を1つずつ入力してください")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    // 本数字の入力箇所を横並びのIFにする
                    HStack(spacing: 8) {
                        TextField("1", text: $number1Text)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 44)
                            .padding(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                            )
                            // 値が変更された時に処理を実行するためのモディファイア
                            .onChange(of: number1Text) { newValue in
                                // 0-9の数字のみ有効
                                let digits = newValue.filter { $0.isNumber }
                                // 桁数は２桁制限
                                let trimmed = digits.count > 2 ? String(digits.prefix(2)) : digits
                                // 1-31の値域チェック
                                if let val = Int(trimmed), val > 31 {
                                    number1Text = "31"
                                // 当選番号が空入力の場合は、オール１
                                } else if let val = Int(trimmed), val < 1 && !trimmed.isEmpty {
                                    number1Text = "1"
                                } else if trimmed != newValue {
                                    number1Text = trimmed
                                }
                            }
                        TextField("2", text: $number2Text)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 44)
                            .padding(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                            )
                            .onChange(of: number2Text) { newValue in
                                let digits = newValue.filter { $0.isNumber }
                                let trimmed = digits.count > 2 ? String(digits.prefix(2)) : digits
                                if let val = Int(trimmed), val > 31 {
                                    number2Text = "31"
                                } else if let val = Int(trimmed), val < 1 && !trimmed.isEmpty {
                                    number2Text = "1"
                                } else if trimmed != newValue {
                                    number2Text = trimmed
                                }
                            }
                        TextField("3", text: $number3Text)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 44)
                            .padding(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                            )
                            .onChange(of: number3Text) { newValue in
                                let digits = newValue.filter { $0.isNumber }
                                let trimmed = digits.count > 2 ? String(digits.prefix(2)) : digits
                                if let val = Int(trimmed), val > 31 {
                                    number3Text = "31"
                                } else if let val = Int(trimmed), val < 1 && !trimmed.isEmpty {
                                    number3Text = "1"
                                } else if trimmed != newValue {
                                    number3Text = trimmed
                                }
                            }
                        TextField("4", text: $number4Text)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 44)
                            .padding(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                            )
                            .onChange(of: number4Text) { newValue in
                                let digits = newValue.filter { $0.isNumber }
                                let trimmed = digits.count > 2 ? String(digits.prefix(2)) : digits
                                if let val = Int(trimmed), val > 31 {
                                    number4Text = "31"
                                } else if let val = Int(trimmed), val < 1 && !trimmed.isEmpty {
                                    number4Text = "1"
                                } else if trimmed != newValue {
                                    number4Text = trimmed
                                }
                            }
                        TextField("5", text: $number5Text)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 44)
                            .padding(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                            )
                            .onChange(of: number5Text) { newValue in
                                let digits = newValue.filter { $0.isNumber }
                                let trimmed = digits.count > 2 ? String(digits.prefix(2)) : digits
                                if let val = Int(trimmed), val > 31 {
                                    number5Text = "31"
                                } else if let val = Int(trimmed), val < 1 && !trimmed.isEmpty {
                                    number5Text = "1"
                                } else if trimmed != newValue {
                                    number5Text = trimmed
                                }
                            }
                    }
                }
                // ボーナス数字だけ別セクションにする
                Section(header: Text("ボーナス数字")) {
                    TextField("ボーナス", text: $bonusNumber1Text)
                        .keyboardType(.numberPad)
                        .onChange(of: bonusNumber1Text) { newValue in
                            let digits = newValue.filter { $0.isNumber }
                            let trimmed = digits.count > 2 ? String(digits.prefix(2)) : digits
                            if let val = Int(trimmed), val > 31 {
                                bonusNumber1Text = "31"
                            } else if let val = Int(trimmed), val < 1 && !trimmed.isEmpty {
                                bonusNumber1Text = "1"
                            } else if trimmed != newValue {
                                bonusNumber1Text = trimmed
                            }
                        }
                }
            }
            .navigationTitle("変更")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("キャンセル") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("保存") { save() } }
            }
            // View表示されるタイミングで実行するアクション定義
            // データベースから該当データを取得する
            .onAppear {
                date = item.timestamp ?? Date()
                numberOfTimeText = String(Int(item.numberOfTime))
                number1Text = String(Int(item.number1))
                number2Text = String(Int(item.number2))
                number3Text = String(Int(item.number3))
                number4Text = String(Int(item.number4))
                number5Text = String(Int(item.number5))
                bonusNumber1Text = String(Int(item.bonusNumber1))
            }
        }
    }

    private func save() {
        item.timestamp = date
        let numberOfTime = Int(numberOfTimeText) ?? 0
        item.numberOfTime = Int32(numberOfTime)
        func to1to31(_ s: String) -> Int16 {
            let n = Int(s) ?? 0
            if n <= 0 { return 1 }
            if n > 31 { return 31 }
            return Int16(n)
        }
        item.number1 = to1to31(number1Text)
        item.number2 = to1to31(number2Text)
        item.number3 = to1to31(number3Text)
        item.number4 = to1to31(number4Text)
        item.number5 = to1to31(number5Text)
        item.bonusNumber1 = to1to31(bonusNumber1Text)
        do { try viewContext.save(); dismiss() } catch { print("Failed to save: \(error)") }
    }
}

// 新規レコード追加（最小実装の雛形）
struct MiniLotoCreateView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var date: Date = Date()
    @State private var numberOfTimeText: String = ""
    @State private var number1Text: String = ""
    @State private var number2Text: String = ""
    @State private var number3Text: String = ""
    @State private var number4Text: String = ""
    @State private var number5Text: String = ""
    @State private var bonusNumber1Text: String = ""

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("抽選日", selection: $date, displayedComponents: .date)
                TextField("回数", text: $numberOfTimeText)
                    .keyboardType(.numberPad)

                Section(header: Text("当選数字入力")) {
                    Text("1から31までの数字を1つずつ入力してください")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    // 本数字 5 個を横一列に、各フィールドに枠線を付与
                    HStack(spacing: 8) {
                        TextField("1", text: $number1Text)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 44)
                            .padding(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                            )
                            .onChange(of: number1Text) { newValue in
                                let digits = newValue.filter { $0.isNumber }
                                let trimmed = digits.count > 2 ? String(digits.prefix(2)) : digits
                                if let val = Int(trimmed), val > 31 {
                                    number1Text = "31"
                                } else if let val = Int(trimmed), val < 1 && !trimmed.isEmpty {
                                    number1Text = "1"
                                } else if trimmed != newValue {
                                    number1Text = trimmed
                                }
                            }
                        TextField("2", text: $number2Text)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 44)
                            .padding(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                            )
                            .onChange(of: number2Text) { newValue in
                                let digits = newValue.filter { $0.isNumber }
                                let trimmed = digits.count > 2 ? String(digits.prefix(2)) : digits
                                if let val = Int(trimmed), val > 31 {
                                    number2Text = "31"
                                } else if let val = Int(trimmed), val < 1 && !trimmed.isEmpty {
                                    number2Text = "1"
                                } else if trimmed != newValue {
                                    number2Text = trimmed
                                }
                            }
                        TextField("3", text: $number3Text)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 44)
                            .padding(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                            )
                            .onChange(of: number3Text) { newValue in
                                let digits = newValue.filter { $0.isNumber }
                                let trimmed = digits.count > 2 ? String(digits.prefix(2)) : digits
                                if let val = Int(trimmed), val > 31 {
                                    number3Text = "31"
                                } else if let val = Int(trimmed), val < 1 && !trimmed.isEmpty {
                                    number3Text = "1"
                                } else if trimmed != newValue {
                                    number3Text = trimmed
                                }
                            }
                        TextField("4", text: $number4Text)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 44)
                            .padding(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                            )
                            .onChange(of: number4Text) { newValue in
                                let digits = newValue.filter { $0.isNumber }
                                let trimmed = digits.count > 2 ? String(digits.prefix(2)) : digits
                                if let val = Int(trimmed), val > 31 {
                                    number4Text = "31"
                                } else if let val = Int(trimmed), val < 1 && !trimmed.isEmpty {
                                    number4Text = "1"
                                } else if trimmed != newValue {
                                    number4Text = trimmed
                                }
                            }
                        TextField("5", text: $number5Text)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 44)
                            .padding(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                            )
                            .onChange(of: number5Text) { newValue in
                                let digits = newValue.filter { $0.isNumber }
                                let trimmed = digits.count > 2 ? String(digits.prefix(2)) : digits
                                if let val = Int(trimmed), val > 31 {
                                    number5Text = "31"
                                } else if let val = Int(trimmed), val < 1 && !trimmed.isEmpty {
                                    number5Text = "1"
                                } else if trimmed != newValue {
                                    number5Text = trimmed
                                }
                            }
                    }
                    // ボーナスは別行に枠付きで
                    TextField("ボーナス", text: $bonusNumber1Text)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 120)
                        .padding(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                        )
                        .onChange(of: bonusNumber1Text) { newValue in
                            let digits = newValue.filter { $0.isNumber }
                            let trimmed = digits.count > 2 ? String(digits.prefix(2)) : digits
                            if let val = Int(trimmed), val > 31 {
                                bonusNumber1Text = "31"
                            } else if let val = Int(trimmed), val < 1 && !trimmed.isEmpty {
                                bonusNumber1Text = "1"
                            } else if trimmed != newValue {
                                bonusNumber1Text = trimmed
                            }
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
        let mini = Loto(context: viewContext)
        mini.type = Int32(TAKARAKUJI_LOTO_TYPE_MINI)
        mini.timestamp = date
        let numberOfTime = Int(numberOfTimeText) ?? 0
        mini.numberOfTime = Int32(numberOfTime)
        func to1to31(_ s: String) -> Int16 {
            let n = Int(s) ?? 0
            if n <= 0 { return 1 }
            if n > 31 { return 31 }
            return Int16(n)
        }
        mini.number1 = to1to31(number1Text)
        mini.number2 = to1to31(number2Text)
        mini.number3 = to1to31(number3Text)
        mini.number4 = to1to31(number4Text)
        mini.number5 = to1to31(number5Text)
        mini.bonusNumber1 = to1to31(bonusNumber1Text)
        mini.bonusNumber2 = 0
        do { try viewContext.save(); dismiss() } catch { print("Failed to save: \(error)") }
    }
}

// Mini Loto 分布表の表示画面
struct MiniLotoDistributionMap: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Loto.entity(),
        sortDescriptors: [NSSortDescriptor(key: "numberOfTime", ascending: false)],
        predicate: NSPredicate(format: "type == %d", TAKARAKUJI_LOTO_TYPE_MINI),
        animation: .default
    ) private var fetchedMiniLotoList: FetchedResults<Loto>

    var body: some View {
        // 左端: 回数 (固定幅 55)、1..31 を 31 列 (固定幅 35)
        let columns: [GridItem] = [GridItem(.fixed(55))] + Array(repeating: GridItem(.fixed(35)), count: 31)
        ScrollView(.horizontal) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Mini Loto LazyVGrid")
                // Header
                LazyVGrid(columns: columns, spacing: 0) {
                    Text("回数")
                        .frame(width: 55, height: 25)
                        .background(Color.black)
                        .font(.system(size: 15, weight: .black))
                        .foregroundColor(.white)
                        .overlay(Rectangle().stroke(Color.gray.opacity(0.6), lineWidth: 1))
                    ForEach(1...31, id: \.self) { value in
                        Text("\(value)")
                            .frame(width: 35, height: 25)
                            .background(Color.black)
                            .font(.system(size: 15, weight: .black))
                            .foregroundColor(.white)
                            .overlay(Rectangle().stroke(Color.gray.opacity(0.6), lineWidth: 1))
                    }
                }
                // Rows
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(fetchedMiniLotoList) { item in
                            // 左端: 回数
                            Text("\(item.numberOfTime)")
                                .frame(width: 55, height: 25)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.primary)
                                .background(Color(white: 0.95))
                                .overlay(Rectangle().stroke(Color.gray.opacity(0.6), lineWidth: 1))

                            // 本数字 5 個 + ボーナス 1 個 をセットに
                            let numbers: Set<Int> = [
                                Int(item.number1), Int(item.number2), Int(item.number3), Int(item.number4), Int(item.number5)
                            ]
                            let bonus: Int = Int(item.bonusNumber1)

                            ForEach(1...31, id: \.self) { value in
                                // 本数字は青丸、ボーナス一致は赤丸、両方に該当は赤を優先
                                let isMain = numbers.contains(value)
                                let isBonus = (bonus == value)
                                let symbol = (isMain || isBonus) ? "●" : ""
                                let color: Color = isBonus ? .red : (isMain ? .blue : .clear)
                                Text(symbol)
                                    .frame(width: 35, height: 25)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(color)
                                    .background(Color(white: 1.0))
                                    .overlay(Rectangle().stroke(Color.gray.opacity(0.6), lineWidth: 1))
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    MiniLotoPage()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

