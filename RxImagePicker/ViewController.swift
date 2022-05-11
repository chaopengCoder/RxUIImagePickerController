//
//  ViewController.swift
//  RxImagePicker
//
//  Created by CPMac on 2022/5/11.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class ViewController: UIViewController {
    fileprivate let disposeBag = DisposeBag()
    
    // 图片展示
    fileprivate lazy var iPreviewIv: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    // 相机按钮
    fileprivate lazy var iCameraBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("相机", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        btn.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        return btn
    }()
    
    // 相册按钮
    fileprivate lazy var iPhotosBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("相册", for: .normal)
        btn.setTitleColor(.red, for: .normal)
        return btn
    }()
    
    // 裁剪按钮
    fileprivate lazy var iCropBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("裁剪", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 注册UIImagePickerControllerDelegate
        RxImagePickerDelegateProxy.register { RxImagePickerDelegateProxy(imagePicker: $0) }
        
        setupSubviews()
        bindViews()
    }
    
    fileprivate func bindViews() {
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
    }
    
    /// 设置子视图
    fileprivate func setupSubviews() {
        view.addSubview(iPreviewIv)
        iPreviewIv.snp.makeConstraints { (make) in
            make.top.equalTo(64)
            make.height.equalTo(300)
            make.left.right.equalToSuperview()
        }
        view.addSubview(iCameraBtn)
        iCameraBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(iPreviewIv.snp.bottom).offset(30)
        }
        
        view.addSubview(iPhotosBtn)
        iPhotosBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(iCameraBtn.snp.bottom).offset(20)
        }
        
        view.addSubview(iCropBtn)
        iCropBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(iPhotosBtn.snp.bottom).offset(20)
        }
    }
}
