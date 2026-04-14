//
//  ContentView.swift
//  TakarakujiDataBox
//
//  Created by Satoshi Wakita on 2023/08/14.
//

import SwiftUI
import CoreData

// Viewプロパティに準拠した構造体
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // 画面内容の記述開始
    var body: some View {
        NavigationView {
            NavigationLink(destination: TakarakujiMenuView()) {
                VStack{
                    // ロト画像表示
                    LotoImageDisplay()
                    Text("宝くじデータボックス")
                        .font(.system(size:30))
                    // ナンバーズ画像表示
                    NumbersImageDisplay()
                }
            }
        }
    }
}

// ロト画像表示処理
struct LotoImageDisplay: View {
    var body: some View {
        HStack{
            Image(decorative: "MiniLoto")
                .resizable()                     // 画像サイズをフレームに合わせる
                .clipShape(Rectangle())          // 矩形表示
                .scaledToFit()                   // 枠内からハミ出さないように拡大縮小
                .frame(width: 140, height: 100)  // フレームサイズ指定
                .rotationEffect(.radians(150))   // 角度設定
                .shadow(radius: 20)

            Image(decorative: "Loto6")
                .resizable()                     // 画像サイズをフレームに合わせる
                .clipShape(Rectangle())          // 矩形表示
                .scaledToFit()                   // 枠内からハミ出さないように拡大縮小
                .frame(width: 140, height: 100)  // フレームサイズ指定
                .rotationEffect(.radians(50))    // 角度設定
                .shadow(radius: 20)
        }

        Image(decorative: "Loto7")
            .resizable()                     // 画像サイズをフレームに合わせる
            .clipShape(Rectangle())          // 矩形表示
            .scaledToFit()                   // 枠内からハミ出さないように拡大縮小
            .frame(width: 140, height: 100)  // フレームサイズ指定
            .rotationEffect(.radians(170))   // 角度設定
            .shadow(radius: 20)
    }
}

// ナンバーズ画像表示処理
struct NumbersImageDisplay: View {
    var body: some View {
        Image(decorative: "Numbers3")
            .resizable()                     // 画像サイズをフレームに合わせる
            .clipShape(Rectangle())          // 矩形表示
            .scaledToFit()                   // 枠内からハミ出さないように拡大縮小
            .frame(width: 140, height: 100)  // フレームサイズ指定
            .rotationEffect(.radians(56))    // 角度設定
            .shadow(radius: 20)

        Image(decorative: "Numbers4")
            .resizable()                     // 画像サイズをフレームに合わせる
            .clipShape(Rectangle())          // 矩形表示
            .scaledToFit()                   // 枠内からハミ出さないように拡大縮小
            .frame(width: 140, height: 100)  // フレームサイズ指定
            .rotationEffect(.radians(214))   // 角度設定
            .shadow(radius: 20) //影
    }
}

// 宝くじメニュータブ表示
struct TakarakujiMenuView: View {
  // タブの選択項目を保持する
  @State var selection = 1
    var body: some View {
        
        TabView{
            Numbers3Page()
                .tabItem {
                    Text("Numbers3")
                }
            Numbers4Page() //2枚目の子ビュー
                .tabItem {
                    Text("Numbers4")
                }
            MiniLotoPage() //2枚目の子ビュー
                .tabItem {
                    Text("Mini Loto")
                }
            Loto6Page() //2枚目の子ビュー
                .tabItem {
                    Text("Loto6")
                }
            Loto7Page() //2枚目の子ビュー
                .tabItem {
                    Text("Loto7")
                }
        }
    }
}

struct Loto7Page: View {
    var body: some View {
        Text("2枚目")
            .font(.title)
            .foregroundColor(.red)
    }
}

struct Loto6Page: View {
    var body: some View {
        Text("2枚目")
            .font(.title)
            .foregroundColor(.red)
    }
}

// プレビュー画面 レイアウトを確認
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // PersistenceController.previewではプレビュー用のDB初期値が設定
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
