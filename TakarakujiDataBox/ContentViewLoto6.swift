//
//  ContentViewLoto6_7.swift
//  TakarakujiDataBox
//
//  Created by Satoshi Wakita on 2026/04/12.
//

import SwiftUI
import CoreData

// Loto6 メニュー（Mini Loto と同様のレイアウトでリスト表示）
struct Loto6Page: View {
    @Environment(\.managedObjectContext) private var viewContext

    // Loto6 のみを回数降順で取得
    @FetchRequest(
        entity: Loto.entity(),
        sortDescriptors: [NSSortDescriptor(key: "numberOfTime", ascending: false)],
        predicate: NSPredicate(format: "type == %d", TAKARAKUJI_LOTO_TYPE_LOTO6),
        animation: .default
    ) private var fetchedLoto6List: FetchedResults<Loto>

    @State private var selectedItem: Loto?
    @State private var showAddSheet = false
    @State private var showDeleteAllAlert = false

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("Loto 6")
                .font(.title)
                .padding(.top, 8)
                .padding(.bottom, 8)

            List(fetchedLoto6List) { item in
                VStack(alignment: .leading) {
                    if let date = item.timestamp {
                        Text("抽選日: \(date.formatted(date: .numeric, time: .omitted))")
                    }
                    Text("回数: \(item.numberOfTime)")
                    // 当選数字: 6個 + ボーナス
                    let n1 = Int(item.number1)
                    let n2 = Int(item.number2)
                    let n3 = Int(item.number3)
                    let n4 = Int(item.number4)
                    let n5 = Int(item.number5)
                    let n6 = Int(item.number6)
                    let b1 = Int(item.bonusNumber1)
                    Text("当選数字: \(n1), \(n2), \(n3), \(n4), \(n5), \(n6)  ボーナス: \(b1)")
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
            .sheet(item: $selectedItem) { target in
                Loto6DetailView(item: target)
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showAddSheet) {
                Loto6CreateView()
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
                Text("Loto 6 の全レコードを削除します。この操作は取り消せません。")
            }

            NavigationLink(destination: Loto6DistributionMap()) {
                Text("Loto 6 Distribution Map")
                    .font(.system(size:15))
            }.padding()
        }
    }

    private func delete(_ item: Loto) {
        viewContext.delete(item)
        do { try viewContext.save() } catch { print("Failed to delete: \(error)") }
    }

    private func confirmDeleteAll() { showDeleteAllAlert = true }

    private func deleteAll() {
        for item in fetchedLoto6List { viewContext.delete(item) }
        do { try viewContext.save() } catch { print("Failed to delete all: \(error)") }
    }
}

// 既存レコードの変更画面
struct Loto6DetailView: View {
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
    @State private var number6Text: String = ""
    @State private var bonusNumber1Text: String = ""

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

                DatePicker("抽選日", selection: $date, displayedComponents: .date)
                TextField("回数", text: $numberOfTimeText)
                    .keyboardType(.numberPad)

                Section(header: Text("当選番号（本数字）")) {
                    Text("1から43までの数字を1つずつ入力してください")
                        .font(.footnote)
                        .foregroundColor(.secondary)
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
                            // 入力内容の変化あり時の処理
                            .onChange(of: number1Text) { newValue in
                                // 数字のフィルタリング
                                let digits = newValue.filter { $0.isNumber }
                                // 2桁まで入力制限
                                let trimmed = digits.count > 2 ? String(digits.prefix(2)) : digits
                                // 44以降の入力は43に丸める
                                if let val = Int(trimmed), val > 43 {
                                    number1Text = "43"
                                // 空入力はオール１にする
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
                                if let val = Int(trimmed), val > 43 {
                                    number2Text = "43"
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
                                if let val = Int(trimmed), val > 43 {
                                    number3Text = "43"
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
                                if let val = Int(trimmed), val > 43 {
                                    number4Text = "43"
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
                                if let val = Int(trimmed), val > 43 {
                                    number5Text = "43"
                                } else if let val = Int(trimmed), val < 1 && !trimmed.isEmpty {
                                    number5Text = "1"
                                } else if trimmed != newValue {
                                    number5Text = trimmed
                                }
                            }
                        TextField("6", text: $number6Text)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 44)
                            .padding(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                            )
                            .onChange(of: number6Text) { newValue in
                                let digits = newValue.filter { $0.isNumber }
                                let trimmed = digits.count > 2 ? String(digits.prefix(2)) : digits
                                if let val = Int(trimmed), val > 43 {
                                    number6Text = "43"
                                } else if let val = Int(trimmed), val < 1 && !trimmed.isEmpty {
                                    number6Text = "1"
                                } else if trimmed != newValue {
                                    number6Text = trimmed
                                }
                            }
                    }
                }

                Section(header: Text("ボーナス数字")) {
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
                            if let val = Int(trimmed), val > 43 {
                                bonusNumber1Text = "43"
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
            .onAppear {
                date = item.timestamp ?? Date()
                numberOfTimeText = String(Int(item.numberOfTime))
                number1Text = String(Int(item.number1))
                number2Text = String(Int(item.number2))
                number3Text = String(Int(item.number3))
                number4Text = String(Int(item.number4))
                number5Text = String(Int(item.number5))
                number6Text = String(Int(item.number6))
                bonusNumber1Text = String(Int(item.bonusNumber1))
            }
        }
    }

    private func save() {
        item.timestamp = date
        let numberOfTime = Int(numberOfTimeText) ?? 0
        item.numberOfTime = Int32(numberOfTime)
        func to1to43(_ s: String) -> Int16 {
            let n = Int(s) ?? 0
            if n <= 0 { return 1 }
            if n > 43 { return 43 }
            return Int16(n)
        }
        item.number1 = to1to43(number1Text)
        item.number2 = to1to43(number2Text)
        item.number3 = to1to43(number3Text)
        item.number4 = to1to43(number4Text)
        item.number5 = to1to43(number5Text)
        item.number6 = to1to43(number6Text)
        item.bonusNumber1 = to1to43(bonusNumber1Text)
        do { try viewContext.save(); dismiss() } catch { print("Failed to save: \(error)") }
    }
}

// 新規レコード追加
struct Loto6CreateView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var date: Date = Date()
    @State private var numberOfTimeText: String = ""
    @State private var number1Text: String = ""
    @State private var number2Text: String = ""
    @State private var number3Text: String = ""
    @State private var number4Text: String = ""
    @State private var number5Text: String = ""
    @State private var number6Text: String = ""
    @State private var bonusNumber1Text: String = ""

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("抽選日", selection: $date, displayedComponents: .date)
                TextField("回数", text: $numberOfTimeText)
                    .keyboardType(.numberPad)

                Section(header: Text("当選数字入力")) {
                    Text("1から43までの数字を1つずつ入力してください")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    HStack(spacing: 8) {
                        TextField("1", text: $number1Text)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 40)
                            .padding(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                            )
                            .onChange(of: number1Text) { newValue in
                                let digits = newValue.filter { $0.isNumber }
                                let trimmed = digits.count > 2 ? String(digits.prefix(2)) : digits
                                if let val = Int(trimmed), val > 43 {
                                    number1Text = "43"
                                } else if let val = Int(trimmed), val < 1 && !trimmed.isEmpty {
                                    number1Text = "1"
                                } else if trimmed != newValue {
                                    number1Text = trimmed
                                }
                            }
                        TextField("2", text: $number2Text)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 40)
                            .padding(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                            )
                            .onChange(of: number2Text) { newValue in
                                let digits = newValue.filter { $0.isNumber }
                                let trimmed = digits.count > 2 ? String(digits.prefix(2)) : digits
                                if let val = Int(trimmed), val > 43 {
                                    number2Text = "43"
                                } else if let val = Int(trimmed), val < 1 && !trimmed.isEmpty {
                                    number2Text = "1"
                                } else if trimmed != newValue {
                                    number2Text = trimmed
                                }
                            }
                        TextField("3", text: $number3Text)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 40)
                            .padding(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                            )
                            .onChange(of: number3Text) { newValue in
                                let digits = newValue.filter { $0.isNumber }
                                let trimmed = digits.count > 2 ? String(digits.prefix(2)) : digits
                                if let val = Int(trimmed), val > 43 {
                                    number3Text = "43"
                                } else if let val = Int(trimmed), val < 1 && !trimmed.isEmpty {
                                    number3Text = "1"
                                } else if trimmed != newValue {
                                    number3Text = trimmed
                                }
                            }
                        TextField("4", text: $number4Text)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 40)
                            .padding(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                            )
                            .onChange(of: number4Text) { newValue in
                                let digits = newValue.filter { $0.isNumber }
                                let trimmed = digits.count > 2 ? String(digits.prefix(2)) : digits
                                if let val = Int(trimmed), val > 43 {
                                    number4Text = "43"
                                } else if let val = Int(trimmed), val < 1 && !trimmed.isEmpty {
                                    number4Text = "1"
                                } else if trimmed != newValue {
                                    number4Text = trimmed
                                }
                            }
                        TextField("5", text: $number5Text)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 40)
                            .padding(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                            )
                            .onChange(of: number5Text) { newValue in
                                let digits = newValue.filter { $0.isNumber }
                                let trimmed = digits.count > 2 ? String(digits.prefix(2)) : digits
                                if let val = Int(trimmed), val > 43 {
                                    number5Text = "43"
                                } else if let val = Int(trimmed), val < 1 && !trimmed.isEmpty {
                                    number5Text = "1"
                                } else if trimmed != newValue {
                                    number5Text = trimmed
                                }
                            }
                        TextField("6", text: $number6Text)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 40)
                            .padding(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                            )
                            .onChange(of: number6Text) { newValue in
                                let digits = newValue.filter { $0.isNumber }
                                let trimmed = digits.count > 2 ? String(digits.prefix(2)) : digits
                                if let val = Int(trimmed), val > 43 {
                                    number6Text = "43"
                                } else if let val = Int(trimmed), val < 1 && !trimmed.isEmpty {
                                    number6Text = "1"
                                } else if trimmed != newValue {
                                    number6Text = trimmed
                                }
                            }
                    }
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
                            if let val = Int(trimmed), val > 43 {
                                bonusNumber1Text = "43"
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
        let loto = Loto(context: viewContext)
        loto.type = Int32(TAKARAKUJI_LOTO_TYPE_LOTO6)
        loto.timestamp = date
        let numberOfTime = Int(numberOfTimeText) ?? 0
        loto.numberOfTime = Int32(numberOfTime)
        func to1to43(_ s: String) -> Int16 {
            let n = Int(s) ?? 0
            if n <= 0 { return 1 }
            if n > 43 { return 43 }
            return Int16(n)
        }
        loto.number1 = to1to43(number1Text)
        loto.number2 = to1to43(number2Text)
        loto.number3 = to1to43(number3Text)
        loto.number4 = to1to43(number4Text)
        loto.number5 = to1to43(number5Text)
        loto.number6 = to1to43(number6Text)
        loto.bonusNumber1 = to1to43(bonusNumber1Text)
        loto.bonusNumber2 = 0
        do { try viewContext.save(); dismiss() } catch { print("Failed to save: \(error)") }
    }
}

// Loto6 分布表
struct Loto6DistributionMap: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Loto.entity(),
        sortDescriptors: [NSSortDescriptor(key: "numberOfTime", ascending: false)],
        predicate: NSPredicate(format: "type == %d", TAKARAKUJI_LOTO_TYPE_LOTO6),
        animation: .default
    ) private var fetchedLoto6List: FetchedResults<Loto>

    var body: some View {
        // 左端: 回数 (固定幅 55)、1..43 を 43 列 (固定幅 35)
        let columns: [GridItem] = [GridItem(.fixed(55))] + Array(repeating: GridItem(.fixed(35)), count: 43)
        ScrollView(.horizontal) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Loto 6 LazyVGrid")
                LazyVGrid(columns: columns, spacing: 0) {
                    Text("回数")
                        .frame(width: 55, height: 25)
                        .background(Color.black)
                        .font(.system(size: 15, weight: .black))
                        .foregroundColor(.white)
                        .overlay(Rectangle().stroke(Color.gray.opacity(0.6), lineWidth: 1))
                    ForEach(1...43, id: \.self) { value in
                        Text("\(value)")
                            .frame(width: 35, height: 25)
                            .background(Color.black)
                            .font(.system(size: 15, weight: .black))
                            .foregroundColor(.white)
                            .overlay(Rectangle().stroke(Color.gray.opacity(0.6), lineWidth: 1))
                    }
                }
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(fetchedLoto6List) { item in
                            Text("\(item.numberOfTime)")
                                .frame(width: 55, height: 25)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.primary)
                                .background(Color(white: 0.95))
                                .overlay(Rectangle().stroke(Color.gray.opacity(0.6), lineWidth: 1))

                            let numbers: Set<Int> = [
                                Int(item.number1), Int(item.number2), Int(item.number3), Int(item.number4), Int(item.number5), Int(item.number6)
                            ]
                            let bonus: Int = Int(item.bonusNumber1)

                            ForEach(1...43, id: \.self) { value in
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
    Loto6Page()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

