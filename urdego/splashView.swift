import SwiftUI
import Lottie

struct SplashView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            ContentView() // 메인 화면으로 전환
        } else {
            VStack {
                LottieView(animation: .named("splash"))
                    .playbackMode(.playing(.toProgress(1, loopMode: .loop)))
                    .frame(width: 300, height: 300) // Lottie 애니메이션 크기
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // 전체 화면 차지
            .background(Color.white) // 배경을 흰색으로 설정
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}
