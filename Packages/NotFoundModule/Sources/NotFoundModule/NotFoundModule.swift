import UIKit
import AppModuleFacade
import AppRouting

@MainActor
public final class NotFoundModule: AppModuleProviding {
    public init() {}

    public var moduleName: String { AppModuleName.notFound.rawValue }

    public func registerRouteHandlers(name: String, into resolver: AppModuleBootstrap) {
        resolver.append(moduleName: moduleName) { route, _ in
            guard let notFoundRoute = route as? UnresolvedRoute else { return nil }
            let originalRouteType: String
            switch notFoundRoute {
            case .notFound(let routeType):
                originalRouteType = routeType
            }
            return NotFoundViewController(originalRouteType: originalRouteType)
        }
    }
}

final class NotFoundViewController: UIViewController {
    private let originalRouteType: String

    init(originalRouteType: String) {
        self.originalRouteType = originalRouteType
        super.init(nibName: nil, bundle: nil)
        title = "404"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let titleLabel = UILabel()
        titleLabel.text = "页面不存在"
        titleLabel.font = .preferredFont(forTextStyle: .title2)
        titleLabel.textAlignment = .center

        let detailLabel = UILabel()
        detailLabel.text = "路由未匹配：\(originalRouteType)"
        detailLabel.font = .preferredFont(forTextStyle: .footnote)
        detailLabel.textColor = .secondaryLabel
        detailLabel.numberOfLines = 0
        detailLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [titleLabel, detailLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
