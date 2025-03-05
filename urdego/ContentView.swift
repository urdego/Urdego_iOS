import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color(uiColor: .white) // 다크 모드에서도 항상 흰색 유지
                .edgesIgnoringSafeArea(.all) // 배경만 SafeArea 무시 (내용은 SafeArea 유지)
            VStack {
                WebView(url: URL(string: "https://urdego.vercel.app")!)
            }
        }
    }
}

#Preview {
    ContentView()
}
