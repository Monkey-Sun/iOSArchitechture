//
//  LoginViewController.swift
//  iOSArchitecture
//
//  Created by 孙俊祥 on 2026/4/8.
//

import UIKit
import AppRouting
import AppModuleFacade

@MainActor
final class LoginViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
    var routing: AppRoutable
    private var didFinishThroughPop = false
    
    
    
    init(routing: AppRoutable) {
        self.routing = routing
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Login"

        let button = UIButton(type: .system)
        button.setTitle("Mock Login Success", for: .normal)
        button.addTarget(self, action: #selector(onTapLogin), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        let tipLabel = UILabel()
        tipLabel.text = "Triggered by auth-guard protected routes"
        tipLabel.textColor = .secondaryLabel
        tipLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(button)
        view.addSubview(tipLabel)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            tipLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tipLabel.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -12)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        attachAdaptivePresentationDelegate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 包在 `UINavigationController` 里 present 时，子 VC 的 `presentationController` 常为 nil；`viewDidAppear` 时再绑一次可确保导航容器已就绪。
        attachAdaptivePresentationDelegate()
    }

    /// 表单页实际被 present 的是外层 `UINavigationController`，滑动取消回调挂在它的 `presentationController` 上才会触发。
    private func attachAdaptivePresentationDelegate() {
        let sheetPresentation = navigationController?.presentationController ?? presentationController
        sheetPresentation?.delegate = self
    }

    @objc
    private func onTapLogin() {
        didFinishThroughPop = true
        routing.pop(from: self, animated: true)
        AppService.resolve(ILoginService.self)?.loginEventBus.post(LoginAuthStateEvent(isLoggedIn: true))
        AppService.resolve(ILoginService.self)?.loginEventBus.post(RefreshEvent())
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        guard !didFinishThroughPop else { return }
        routing.pop(from: self, animated: true)
    }
}
