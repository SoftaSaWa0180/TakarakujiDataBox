import SwiftUI
import CoreData

// Loto7 メニュー（Loto6 と同様のレイアウトでリスト表示）
struct Loto7Page: View {
    @Environment(\.managedObjectContext) private var viewContext
    // Loto7 のみを回数降順で取得
    @FetchRequest(
        entity: Loto.entity(),
        sortDescriptors: [NSSortDescriptor(key: "numberOfTime", ascending: false)],
        predicate: NSPredicate(format: "type == %d", TAKARAKUJI_LOTO_TYPE_LOTO7),
        animation: .default
    ) private var fetchedLoto7List: FetchedResults<Loto>

    @State private var selectedItem: Loto?
    @State private var showAddSheet = false
    @State private var showDeleteAllAlert = false

    // 表示内容
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("Loto 7")
                .font(.title)
                .padding(.top, 8)
                .padding(.bottom, 8)

            List(fetchedLoto7List) { item in
                VStack(alignment: .leading) {
                    // 日付データありの場合
                    if let date = item.timestamp {
                        Text("抽選日: \(date.formatted(date: .numeric, time: .omitted))")
                    }
                    Text("回数: \(item.numberOfTime)")
                    // 当選数字: 7個 + ボーナス2個
                    let n1 = Int(item.number1)
                    let n2 = Int(item.number2)
                    let n3 = Int(item.number3)
                    let n4 = Int(item.number4)
                    let n5 = Int(item.number5)
                    let n6 = Int(item.number6)
                    let n7 = Int(item.number7)
                    let b1 = Int(item.bonusNumber1)
                    let b2 = Int(item.bonusNumber2)
                    Text("当選数字: \(n1), \(n2), \(n3), \(n4), \(n5), \(n6), \(n7)  ボーナス: \(b1), \(b2)")
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
                Loto7DetailView(item: target)
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showAddSheet) {
                Loto7CreateView()
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
                Text("Loto 7 の全レコードを削除します。この操作は取り消せません。")
            }

            NavigationLink(destination: Loto7DistributionMap()) {
                Text("Loto 7 Distribution Map")
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
        for item in fetchedLoto7List { viewContext.delete(item) }
        do { try viewContext.save() } catch { print("Failed to delete all: \(error)") }
    }
}

// 既存レコードの変更画面（Loto7）
struct Loto7DetailView: View {
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
    @State private var number7Text: String = ""
    @State private var bonusNumber1Text: String = ""
    @State private var bonusNumber2Text: String = ""

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
                    Text("1から37までの数字を1つずつ入力してください")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    HStack(spacing: 8) {
                        Group {
                            TextField("1", text: $number1Text)
                            TextField("2", text: $number2Text)
                            TextField("3", text: $number3Text)
                            TextField("4", text: $number4Text)
                            TextField("5", text: $number5Text)
                            TextField("6", text: $number6Text)
                            TextField("7", text: $number7Text)
                        }
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(width: 44)
                        .padding(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                        )
                    }
                }

                Section(header: Text("ボーナス数字")) {
                    HStack(spacing: 8) {
                        TextField("ボーナス1", text: $bonusNumber1Text)
                        TextField("ボーナス2", text: $bonusNumber2Text)
                    }
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
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
                number7Text = String(Int(item.number7))
                bonusNumber1Text = String(Int(item.bonusNumber1))
                bonusNumber2Text = String(Int(item.bonusNumber2))
            }
        }
    }

    private func save() {
        item.timestamp = date
        let numberOfTime = Int(numberOfTimeText) ?? 0
        item.numberOfTime = Int32(numberOfTime)
        item.number1 = Int16(Int(number1Text) ?? 0)
        item.number2 = Int16(Int(number2Text) ?? 0)
        item.number3 = Int16(Int(number3Text) ?? 0)
        item.number4 = Int16(Int(number4Text) ?? 0)
        item.number5 = Int16(Int(number5Text) ?? 0)
        item.number6 = Int16(Int(number6Text) ?? 0)
        item.number7 = Int16(Int(number7Text) ?? 0)
        item.bonusNumber1 = Int16(Int(bonusNumber1Text) ?? 0)
        item.bonusNumber2 = Int16(Int(bonusNumber2Text) ?? 0)
        do { try viewContext.save(); dismiss() } catch { print("Failed to save: \(error)") }
    }
}

// 新規レコード追加（Loto7）
struct Loto7CreateView: View {
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
    @State private var number7Text: String = ""
    @State private var bonusNumber1Text: String = ""
    @State private var bonusNumber2Text: String = ""

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("抽選日", selection: $date, displayedComponents: .date)
                TextField("回数", text: $numberOfTimeText)
                    .keyboardType(.numberPad)

                Section(header: Text("当選数字入力")) {
                    Text("1から37までの数字を1つずつ入力してください")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    HStack(spacing: 8) {
                        Group {
                            TextField("1", text: $number1Text)
                            TextField("2", text: $number2Text)
                            TextField("3", text: $number3Text)
                        }
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(width: 40)
                        .padding(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                        )
                    }
                    HStack(spacing: 8) {
                        Group {
                            TextField("4", text: $number4Text)
                            TextField("5", text: $number5Text)
                            TextField("6", text: $number6Text)
                            TextField("7", text: $number7Text)
                        }
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(width: 40)
                        .padding(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                        )
                    }

                    HStack(spacing: 8) {
                        TextField("ボーナス1", text: $bonusNumber1Text)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 120)
                            .padding(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                            )
                        TextField("ボーナス2", text: $bonusNumber2Text)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 120)
                            .padding(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                            )
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
        loto.type = Int32(TAKARAKUJI_LOTO_TYPE_LOTO7)
        loto.timestamp = date
        let numberOfTime = Int(numberOfTimeText) ?? 0
        loto.numberOfTime = Int32(numberOfTime)
        loto.number1 = Int16(Int(number1Text) ?? 0)
        loto.number2 = Int16(Int(number2Text) ?? 0)
        loto.number3 = Int16(Int(number3Text) ?? 0)
        loto.number4 = Int16(Int(number4Text) ?? 0)
        loto.number5 = Int16(Int(number5Text) ?? 0)
        loto.number6 = Int16(Int(number6Text) ?? 0)
        loto.number7 = Int16(Int(number7Text) ?? 0)
        loto.bonusNumber1 = Int16(Int(bonusNumber1Text) ?? 0)
        loto.bonusNumber2 = Int16(Int(bonusNumber2Text) ?? 0)
        do { try viewContext.save(); dismiss() } catch { print("Failed to save: \(error)") }
    }
}

// Loto7 分布表
struct Loto7DistributionMap: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Loto.entity(),
        sortDescriptors: [NSSortDescriptor(key: "numberOfTime", ascending: false)],
        predicate: NSPredicate(format: "type == %d", TAKARAKUJI_LOTO_TYPE_LOTO7),
        animation: .default
    ) private var fetchedLoto7List: FetchedResults<Loto>

    var body: some View {
        // 左端: 回数 (固定幅 55)、1..37 を 37 列 (固定幅 35)
        let columns: [GridItem] = [GridItem(.fixed(55))] + Array(repeating: GridItem(.fixed(35)), count: 37)
        ScrollView(.horizontal) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Loto 7 LazyVGrid")
                LazyVGrid(columns: columns, spacing: 0) {
                    Text("回数")
                        .frame(width: 55, height: 25)
                        .background(Color.black)
                        .font(.system(size: 15, weight: .black))
                        .foregroundColor(.white)
                        .overlay(Rectangle().stroke(Color.gray.opacity(0.6), lineWidth: 1))
                    ForEach(1...37, id: \.self) { value in
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
                        ForEach(fetchedLoto7List) { item in
                            Text("\(item.numberOfTime)")
                                .frame(width: 55, height: 25)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.primary)
                                .background(Color(white: 0.95))
                                .overlay(Rectangle().stroke(Color.gray.opacity(0.6), lineWidth: 1))

                            let numbers: Set<Int> = [
                                Int(item.number1), Int(item.number2), Int(item.number3), Int(item.number4), Int(item.number5), Int(item.number6), Int(item.number7)
                            ]
                            let bonus1: Int = Int(item.bonusNumber1)
                            let bonus2: Int = Int(item.bonusNumber2)

                            ForEach(1...37, id: \.self) { value in
                                let isMain = numbers.contains(value)
                                let isBonus = (bonus1 == value) || (bonus2 == value)
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
    Loto7Page()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

