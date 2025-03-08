import SwiftUI
@preconcurrency import WebKit
import UIKit

/// `WKWebView`를 감싼 CustomWebView
struct CustomWebView: UIViewRepresentable {
    let url: URL
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {}

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CustomWebView
        var pickerCompletionHandler: ((URL?) -> Void)?
        
        init(_ parent: CustomWebView) {
            self.parent = parent
        }
        
        /// 웹에서 `<input type="file">` 실행 시 호출됨 (iOS 15 호환)
        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
            if message == "camera_request" {
                showImagePicker()
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
        
        /// 사진 촬영 또는 갤러리에서 선택 UI 표시
        private func showImagePicker() {
            guard let rootVC = getRootViewController() else {
                return
            }
            
            let alert = UIAlertController(title: "사진 업로드", message: "선택할 방식을 고르세요.", preferredStyle: .actionSheet)
            
            let cameraAction = UIAlertAction(title: "카메라 촬영", style: .default) { _ in
                self.openCamera()
            }
            
            let galleryAction = UIAlertAction(title: "갤러리에서 선택", style: .default) { _ in
                self.openPhotoLibrary()
            }
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)

            alert.addAction(cameraAction)
            alert.addAction(galleryAction)
            alert.addAction(cancelAction)
            
            rootVC.present(alert, animated: true)
        }
        
        /// 카메라 실행
        private func openCamera() {
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            picker.allowsEditing = false
            
            getRootViewController()?.present(picker, animated: true)
        }
        
        /// 갤러리 실행
        private func openPhotoLibrary() {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.allowsEditing = false
            
            getRootViewController()?.present(picker, animated: true)
        }
        
        /// 사용자가 사진을 선택했을 때
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            guard let image = info[.originalImage] as? UIImage,
                  let data = image.jpegData(compressionQuality: 0.8) else {
                picker.dismiss(animated: true)
                return
            }
            
            let tempDirectory = FileManager.default.temporaryDirectory
            let fileURL = tempDirectory.appendingPathComponent("\(UUID().uuidString).jpg")
            
            do {
                try data.write(to: fileURL)
                pickerCompletionHandler?(fileURL)
            } catch {
                print("파일 저장 실패: \(error)")
                pickerCompletionHandler?(nil)
            }
            
            picker.dismiss(animated: true)
        }
        
        /// 사용자가 취소했을 때
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            pickerCompletionHandler?(nil)
        }
        
        /// 최상위 뷰 컨트롤러 가져오기 (iOS 15 이상 대응)
        private func getRootViewController() -> UIViewController? {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootVC = window.rootViewController else {
                return nil
            }
            return rootVC
        }
    }
}

struct ContentView: View {
    var body: some View {
        ZStack {
            Color(uiColor: .white)
                .edgesIgnoringSafeArea(.all)
            VStack {
                CustomWebView(url: URL(string: "https://urdego.vercel.app")!)
            }
        }
    }
}

#Preview {
    ContentView()
}
