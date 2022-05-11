#### RxSwift 官方代码实践 UIImagePickerController
#### 注意: demo 需要执行 pod install
##### 1. 扩展UIImagePickerController 初始化为Observable<UIImagePickerController>
```swift
/// 扩展UIImagePickerController 初始化
extension Reactive where Base: UIImagePickerController {
    
    static func createWithParent(_ parent: UIViewController?, animated: Bool = true, configureImagePicker: @escaping (UIImagePickerController) throws -> Void = { x in }) -> Observable<UIImagePickerController> {
        return Observable.create { [weak parent] observer in
            let imagePicker = UIImagePickerController()
            let dismissDisposable = imagePicker.rx
                .didCancel
                .subscribe(onNext: { [weak imagePicker] _ in
                    guard let imagePicker = imagePicker else { return }
                    dismissViewController(imagePicker, animated: animated)
                })
            
            do {
                try configureImagePicker(imagePicker)
            } catch let error {
                observer.on(.error(error))
                return Disposables.create()
            }
            
            guard let parent = parent else {
                observer.on(.completed)
                return Disposables.create()
            }
            imagePicker.modalPresentationStyle = .overFullScreen
            parent.present(imagePicker, animated: animated, completion: nil)
            observer.on(.next(imagePicker))
            
            return Disposables.create(dismissDisposable, Disposables.create {
                dismissViewController(imagePicker, animated: animated)
            })
        }
    }
}
```

##### 2. 代理方法
创建 RxImagePickerDelegateProxy, 然后仅注册一次, 我这里写在ViewDidLoad中, 官方代码写在 AppDelagate中
```swift
override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 注册UIImagePickerControllerDelegate
        RxImagePickerDelegateProxy.register { RxImagePickerDelegateProxy(imagePicker: $0) }
      
    }
```

#### 相机相册裁剪事件, 把结果显示到UIImageView
```swift
/// 相机按钮事件
        iCameraBtn.rx.tap
            .flatMapLatest { [weak self] _ in
                return UIImagePickerController.rx.createWithParent(self) { (picker) in
                    picker.sourceType = .camera
                    picker.allowsEditing = false
                }
                .flatMap { $0.rx.didFinishPickingMediaWithInfo }
                .take(1)
            }
            .map{ info in
                return info[.originalImage] as? UIImage
            }
            .bind(to: iPreviewIv.rx.image)
            .disposed(by: disposeBag)
        
        // 相册按钮事件
        iPhotosBtn.rx.tap
            .flatMapLatest { [weak self] _ in
                return UIImagePickerController.rx.createWithParent(self) { picker in
                    picker.allowsEditing = false
                    picker.sourceType = .photoLibrary
                }
                .flatMap {
                    $0.rx.didFinishPickingMediaWithInfo
                }
                .take(1)
            }
            .map { info in
                return info[.originalImage] as? UIImage
            }
            .bind(to: iPreviewIv.rx.image)
            .disposed(by: disposeBag)
        
        // 裁剪按钮事件
        iCropBtn.rx.tap
            .flatMapLatest { [weak self] _ in
                return UIImagePickerController.rx.createWithParent(self) { (picker) in
                    picker.allowsEditing = true
                    picker.sourceType = .photoLibrary
                }
                .flatMap { $0.rx.didFinishPickingMediaWithInfo }
                .take(1)
            }
            .map{ info in
                return info[.editedImage] as? UIImage
            }
            .bind(to: iPreviewIv.rx.image)
            .disposed(by: disposeBag)
```




