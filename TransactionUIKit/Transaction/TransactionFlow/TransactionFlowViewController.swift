//
//  TransactionFlowViewController.swift
//  TransactionUIKit
//
//  Created by Paulo on 25/11/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RIBs
import RxSwift
import UIKit

protocol TransactionFlowPresentableListener: AnyObject {
}

protocol TransactionFlowPresentable: Presentable {
    var listener: TransactionFlowPresentableListener? { get set }
}

final class TransactionFlowViewController: UINavigationController, TransactionFlowPresentable, TransactionFlowViewControllable {

    weak var listener: TransactionFlowPresentableListener?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

    func replaceRoot(viewController: ViewControllable?) {
        guard let viewController = viewController else {
            return
        }
        setViewControllers([viewController.uiviewController], animated: true)
    }

    func push(viewController: ViewControllable?) {
        guard let viewController = viewController else {
            return
        }
        pushViewController(viewController.uiviewController, animated: true)
    }

    func pop() {
        popViewController(animated: true)
    }

    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}