//
//  RxImagePickerDelegateProxy.swift
//  RxImagePicker
//
//  Created by CPMac on 2022/5/11.
//

import Foundation

#if os(iOS)

import UIKit
import RxSwift
import RxCocoa

/// UIImagePickerControllerDelagate 需要注册该代理
open class RxImagePickerDelegateProxy
    : RxNavigationControllerDelegateProxy, UIImagePickerControllerDelegate {

    public init(imagePicker: UIImagePickerController) {
        super.init(navigationController: imagePicker)
    }

}

#endif
