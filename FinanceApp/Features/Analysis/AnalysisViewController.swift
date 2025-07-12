//
//  AnalysisViewController.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 08.07.2025.
//

import UIKit
import Combine
import SwiftUI  // для DateTimePickerPopup, потому что он уже был реализоан

final class AnalysisViewController: UIViewController {
    // MARK: Public
    var direction: Direction = .outcome

    // MARK: UI
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let overlayView = UIView()
    private var pickerHost: UIHostingController<DateTimePickerPopup>?

    // MARK: State
    private let viewModel = AnalysisViewModel()
    private var cancellables = Set<AnyCancellable>()

    private var showStartPicker = false
    private var showEndPicker   = false

    private var startDate: Date = Date().monthAgo
    private var endDate:   Date = Date()
    private var sortOption: AnalysisViewModel.SortOption = .date
    
    private var currentTransactions: [Transaction] {
            if !viewModel.sortedTransactions.isEmpty {
                return viewModel.sortedTransactions
            }
            return placeholderTransactions.sorted { lhs, rhs in
                switch sortOption {
                case .date:
                    return lhs.transactionDate > rhs.transactionDate
                case .amount:
                    return lhs.amount > rhs.amount
                }
            }
        }

    // Заглушки для операций, пока реальных нет
    private let placeholderTransactions: [Transaction] = [
        Transaction(
            id: -1, accountId: 0, categoryId: 1,
            amount: Decimal(1000),
            comment: "Платёж два дня назад",
            transactionDate: Calendar.current
                .date(byAdding: .day, value: -2, to: Date())!,
            createdAt: Date(), updatedAt: Date()
        ),
        Transaction(
            id: -2, accountId: 0, categoryId: 2,
            amount: Decimal(2500),
            comment: "Платёж сегодня",
            transactionDate: Date(),
            createdAt: Date(), updatedAt: Date()
        ),
        Transaction(
            id: -3, accountId: 0, categoryId: 3,
            amount: Decimal(5000),
            comment: "Крупный платёж 10 дней назад",
            transactionDate: Calendar.current
                .date(byAdding: .day, value: -10, to: Date())!,
            createdAt: Date(), updatedAt: Date()
        )
    ]


    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        viewModel.applySort(option: sortOption)

        // Навигационная панель
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = .systemBackground

        // Параметры маленького заголовка
        navBarAppearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
            .foregroundColor: UIColor.label
        ]
        // Параметры большого заголовка
        navBarAppearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 34, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationController?.navigationBar.compactAppearance = navBarAppearance

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        navigationItem.title = "Анализ"

        // Кастомная кнопка «Назад», которая в итоге не работает :)
        /// Я правда пыталась, но мне, как пользователю, указание на конкретный экран удобнее
        navigationItem.hidesBackButton = true
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        backButton.setTitle("Назад", for: .normal)
        backButton.semanticContentAttribute = .forceLeftToRight
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.sizeToFit()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)

        setupTableHeader()
        setupTableView()
        setupOverlay()
        setupBindings()
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: — Table Header
    private func setupTableHeader() {
        let headerView = UIView()
        headerView.backgroundColor = .clear

        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        lbl.textColor = .label
        lbl.text = "Анализ"
        lbl.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(lbl)
        NSLayoutConstraint.activate([
            lbl.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            lbl.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),
            lbl.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16)
        ])

        tableView.tableHeaderView = headerView
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let header = tableView.tableHeaderView else { return }
        let targetSize = CGSize(
            width: tableView.bounds.width,
            height: UIView.layoutFittingCompressedSize.height
        )
        let fittingSize = header.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        var frame = header.frame
        frame.size.height = fittingSize.height
        header.frame = frame
        tableView.tableHeaderView = header
    }

    // MARK: Setup Views
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(
            AnalysisTransactionCell.self,
            forCellReuseIdentifier: AnalysisTransactionCell.reuseID
        )
        tableView.dataSource = self
        tableView.delegate   = self
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupOverlay() {
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.isHidden = true
        view.addSubview(overlayView)

        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(hidePickerPopup)
        )
        overlayView.addGestureRecognizer(tap)
    }

    private func setupBindings() {
        viewModel.$sortedTransactions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                self.tableView.reloadRows(
                    at: [IndexPath(row: 2, section: 0)],
                    with: .none
                )
            }
            .store(in: &cancellables)
    }

    // MARK: Data
    private func loadData() {
        viewModel.load(
            direction: direction,
            start:     startDate,
            end:       endDate,
            sort:      sortOption
        )
    }
}

// MARK: — UITableViewDataSource
extension AnalysisViewController: UITableViewDataSource {
    // Транзакции, которые показываем: либо реальные, либо placeholder’ы, сразу отсортированные
    private var displayedTransactions: [Transaction] {
        if !viewModel.sortedTransactions.isEmpty {
            return viewModel.sortedTransactions
        }
        return placeholderTransactions.sorted { lhs, rhs in
            switch sortOption {
            case .date:
                return lhs.transactionDate > rhs.transactionDate
            case .amount:
                return lhs.amount > rhs.amount
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "Операции" : nil
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4  // Начало, Конец, Сумма, Сортировка
        case 1:
            return displayedTransactions.count
        default:
            return 0
        }
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                return dateCell(title: "Начало", date: startDate)
            case 1:
                return dateCell(title: "Конец", date: endDate)
            case 2:
                return totalCell()
            case 3:
                return sortCell()
            default:
                fatalError("Unexpected row in section 0")
            }
        } else {
            // Секция «Операции»
            let cell = tableView.dequeueReusableCell(
                withIdentifier: AnalysisTransactionCell.reuseID,
                for: indexPath
            ) as! AnalysisTransactionCell

            // берём транзакцию
            let tx = displayedTransactions[indexPath.row]

            // считаем процент
            let pct: Int
            if viewModel.total > 0 {
                let ratio = (tx.amount as NSDecimalNumber).doubleValue
                          / (viewModel.total as NSDecimalNumber).doubleValue
                pct = Int((ratio * 100).rounded())
            } else {
                pct = 0
            }

            // передаём оба аргумента в cell.configure
            cell.configure(with: tx, percentage: pct)
            return cell
        }
    }

    // MARK: — Static-cell helpers
    private func dateCell(title: String, date: Date) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.selectionStyle = .none

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 17)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let dateLabel = PaddingLabel()
        dateLabel.text = Self.dateFormatter.string(from: date)
        dateLabel.font = .systemFont(ofSize: 17)
        dateLabel.textColor = .label
        dateLabel.backgroundColor = UIColor.accent.withAlphaComponent(0.2)
        dateLabel.layer.cornerRadius = 8
        dateLabel.clipsToBounds = true
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        cell.contentView.addSubview(titleLabel)
        cell.contentView.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            dateLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            dateLabel.heightAnchor.constraint(equalToConstant: 28)
        ])

        return cell
    }

    private func totalCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.selectionStyle = .none
        cell.textLabel?.text = "Сумма"
        cell.detailTextLabel?.text = viewModel.totalFormatted
        cell.detailTextLabel?.textColor = .label
        return cell
    }

    private func sortCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.selectionStyle = .none

        let items = AnalysisViewModel.SortOption.allCases.map { $0.title }
        let segmented = UISegmentedControl(items: items)
        segmented.selectedSegmentIndex = sortOption.rawValue
        segmented.addTarget(self, action: #selector(sortChanged(_:)), for: .valueChanged)

        cell.contentView.addSubview(segmented)
        segmented.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmented.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            segmented.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            segmented.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
            segmented.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8)
        ])

        return cell
    }
}

// MARK: — UITableViewDelegate
extension AnalysisViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        guard indexPath.section == 0 else { return }
        switch indexPath.row {
        case 0: presentPicker(kind: .start)
        case 1: presentPicker(kind: .end)
        default: break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private enum PickerKind { case start, end }

    private func presentPicker(kind: PickerKind) {
        showStartPicker = (kind == .start)
        showEndPicker   = (kind == .end)
        overlayView.isHidden = false

        // начало ≤ конец, конец ≥ начало
        let dateBinding = Binding<Date>(
            get: { kind == .start ? self.startDate : self.endDate },
            set: { newDate in
                if kind == .start {
                    self.startDate = newDate
                    if newDate > self.endDate { self.endDate = newDate }
                } else {
                    self.endDate = newDate
                    if newDate < self.startDate { self.startDate = newDate }
                }
                self.loadData()
                self.tableView.reloadData()
            }
        )

        let isPresentedBinding = Binding<Bool>(
            get: { self.showStartPicker || self.showEndPicker },
            set: { dismissed in
                if !dismissed { self.hidePickerPopup() }
            }
        )

        let popup = DateTimePickerPopup(
            date:        dateBinding,
            isPresented: isPresentedBinding
        )
        let host = UIHostingController(rootView: popup)
        pickerHost = host

        host.view.backgroundColor = .systemBackground
        host.view.layer.cornerRadius = 12
        host.view.clipsToBounds = true

        addChild(host)
        view.addSubview(host.view)
        host.didMove(toParent: self)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            host.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            host.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            host.view.widthAnchor.constraint(equalToConstant: DatePickerConstants.popupSize.width),
            host.view.heightAnchor.constraint(equalToConstant: DatePickerConstants.popupSize.height)
        ])

        host.view.alpha = 0
        host.view.transform = CGAffineTransform(translationX: 0, y: -20)
        UIView.animate(withDuration: 0.3) {
            host.view.alpha = 1
            host.view.transform = .identity
        }
    }

    @objc private func hidePickerPopup() {
        overlayView.isHidden = true
        guard let host = pickerHost else { return }
        host.willMove(toParent: nil)
        UIView.animate(
            withDuration: 0.2,
            animations: {
                host.view.alpha = 0
                host.view.transform = CGAffineTransform(translationX: 0, y: -20)
            },
            completion: { _ in
                host.view.removeFromSuperview()
                host.removeFromParent()
                self.pickerHost = nil
                self.showStartPicker = false
                self.showEndPicker   = false
            }
        )
    }

    @objc private func sortChanged(_ sender: UISegmentedControl) {
        let opt = AnalysisViewModel.SortOption(rawValue: sender.selectedSegmentIndex)!
        sortOption = opt
        viewModel.applySort(option: opt)
    }

}

// MARK: — Utilities
private extension AnalysisViewController {
    static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale    = Locale(identifier: "ru_RU")
        f.dateFormat = "d MMMM yyyy, HH:mm"
        return f
    }()
}

// Подкласс UILabel с внутренними отступами
final class PaddingLabel: UILabel {
    var insets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + insets.left + insets.right,
            height: size.height + insets.top + insets.bottom
        )
    }
}
