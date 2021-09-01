// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxDataSources
import RxRelay
import RxSwift
import ToolKit

/// A view controller that displays the dashboard
public final class DashboardViewController: BaseScreenViewController {

    // MARK: - Private Types

    private typealias RxDataSource = RxTableViewSectionedAnimatedDataSource<DashboardViewModel>

    // MARK: - Private Properties

    private let disposeBag = DisposeBag()
    private let fiatBalanceCellProvider: FiatBalanceCellProviding
    private let presenter: DashboardScreenPresenter
    private let tableView = UITableView()

    // MARK: - Setup

    init(
        fiatBalanceCellProvider: FiatBalanceCellProviding,
        presenter: DashboardScreenPresenter
    ) {
        self.fiatBalanceCellProvider = fiatBalanceCellProvider
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        unimplemented()
    }

    // MARK: - Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupTableView()
        presenter.setup()
        tableView.reloadData()
        presenter.refreshRelay.accept(())
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = false
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        set(
            barStyle: .lightContent(),
            leadingButtonStyle: .drawer,
            trailingButtonStyle: .none
        )
        titleViewStyle = .text(value: LocalizationConstants.DashboardScreen.title)
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.layoutToSuperview(axis: .horizontal, usesSafeAreaLayoutGuide: true)
        tableView.layoutToSuperview(axis: .vertical, usesSafeAreaLayoutGuide: true)
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(AnnouncementTableViewCell.self)
        fiatBalanceCellProvider.registerFiatBalanceCell(for: tableView)
        tableView.register(NoticeTableViewCell.self)
        tableView.registerNibCell(TotalBalanceTableViewCell.self, in: .module)
        tableView.registerNibCell(HistoricalBalanceTableViewCell.self, in: .module)
        tableView.separatorColor = .clear

        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.rx
            .controlEvent(.valueChanged)
            .bind(to: presenter.refreshRelay)
            .disposed(by: disposeBag)
        refreshControl.rx
            .controlEvent(.valueChanged)
            .map { false }
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)

        let dataSource = RxDataSource(
            animationConfiguration: .init(insertAnimation: .fade, reloadAnimation: .fade, deleteAnimation: .fade),
            configureCell: { [weak self] _, _, indexPath, item in
                guard let self = self else { return UITableViewCell() }
                let cell: UITableViewCell

                switch item {
                case .announcement(let model):
                    cell = self.announcementCell(for: indexPath, model: model)
                case .fiatCustodialBalances(let presenter):
                    cell = self.fiatCustodialBalancesCell(for: indexPath, presenter: presenter)
                case .totalBalance(let presenter):
                    cell = self.balanceCell(for: indexPath, presenter: presenter)
                case .crypto(let presenter):
                    cell = self.assetCell(for: indexPath, presenter: presenter)
                case .cryptoSkeleton:
                    cell = self.assetCell(for: indexPath, presenter: nil)
                case .notice(let model):
                    cell = self.noticeCell(for: indexPath, model: model)
                }
                cell.selectionStyle = .none
                return cell
            }
        )

        tableView.rx.modelSelected(DashboardCellType.self)
            .bindAndCatch(weak: self) { (self, model) in
                switch model {
                case .announcement,
                     .notice,
                     .totalBalance,
                     .cryptoSkeleton,
                     .fiatCustodialBalances:
                    break
                case .crypto(let presenter):
                    self.presenter.router.showDetailsScreen(for: presenter.cryptoCurrency)
                }
            }
            .disposed(by: disposeBag)

        presenter.sections
            .observeOn(MainScheduler.asyncInstance)
            .bindAndCatch(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    // MARK: - Navigation

    override public func navigationBarLeadingButtonPressed() {
        presenter.navigationBarLeadingButtonPressed()
    }

    // MARK: - Cells

    private func fiatCustodialBalancesCell(
        for indexPath: IndexPath,
        presenter: CurrencyViewPresenter
    ) -> UITableViewCell {
        fiatBalanceCellProvider.dequeueReusableFiatBalanceCell(
            for: tableView,
            indexPath: indexPath,
            presenter: presenter
        )
    }

    private func announcementCell(for indexPath: IndexPath, model: AnnouncementCardViewModel) -> UITableViewCell {
        let cell = tableView.dequeue(AnnouncementTableViewCell.self, for: indexPath)
        cell.viewModel = model
        return cell
    }

    private func balanceCell(for indexPath: IndexPath, presenter: TotalBalanceViewPresenter) -> UITableViewCell {
        let cell = tableView.dequeue(TotalBalanceTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func assetCell(for indexPath: IndexPath, presenter: HistoricalBalanceCellPresenter?) -> UITableViewCell {
        let cell = tableView.dequeue(HistoricalBalanceTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func noticeCell(for indexPath: IndexPath, model: NoticeViewModel) -> UITableViewCell {
        let cell = tableView.dequeue(NoticeTableViewCell.self, for: indexPath)
        cell.viewModel = model
        return cell
    }
}