//
//  HomeViewController.swift
//  iOSArchitecture
//
//  Created by 孙俊祥 on 2026/4/8.
//

import UIKit
import AppModuleFacade

@MainActor
final class HomeViewController: UIViewController {
    private let routing: AppRoutable

    init(routing: AppRoutable) {
        self.routing = routing
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Home Router Lab"
        navigationItem.largeTitleDisplayMode = .always

        let intro = makeLabel("Router framework manual test panel")
        let actions: [(String, Selector)] = [
            ("Push Detail (custom push animation)", #selector(onPushDetail)),
            ("Present Profile (auth + interactive dismiss)", #selector(onPresentProfile)),
            ("Present Settings (auth check)", #selector(onPresentSettings)),
            ("DeepLink: detail?id=42", #selector(onDeepLinkDetail)),
            ("DeepLink: settings", #selector(onDeepLinkSettings)),
            ("Pop to Home Root", #selector(onPopToHomeRoot)),
            ("Replace Root -> Home", #selector(onReplaceRootToHome))
        ]

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(intro)
        for action in actions {
            stack.addArrangedSubview(makeButton(title: action.0, action: action.1))
        }

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24)
        ])
    }

    @objc
    private func onPushDetail() {
        routing.route(
            HomeRoute.detail(id: UUID().uuidString.prefix(6).description),
            from: self
        )
    }

    @objc
    private func onPresentProfile() {
        routing.route(LoginRoute.login(), from: self)
    }

    @objc
    private func onPresentSettings() {
        routing.handleDeepLink(URL(string: "myapp://app/settingsa")!, from: self)
    }

    @objc
    private func onDeepLinkDetail() {
        routing.handleDeepLink(URL(string: "myapp://app/detail?id=42")!, from: self)
    }

    @objc
    private func onDeepLinkSettings() {
        routing.handleDeepLink(URL(string: "myapp://app/settings")!, from: self)
    }

    @objc
    private func onPopToHomeRoot() {
        routing.popToRoot(in: AppModuleName.home.tabIndex, animated: true)
    }

    @objc
    private func onReplaceRootToHome() {
        routing.replaceRoot(with: HomeRoute.home, embedInNavigation: true)
    }

    private func makeButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .medium
        button.configuration?.title = title
        button.contentHorizontalAlignment = .leading
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func makeLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
