//
//  AnalysisViewController.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 08.07.2025.
//

import UIKit
import Combine
import SwiftUI  // для DateTimePickerPopup, потому что он уже был реализоан
import PieChart

final class AnalysisViewController: UIViewController {
    // MARK: Public
    var direction: Direction = .outcome
    var accountId: Int = 0
    
    // MARK: Pie-chart
    private let chart = PieChartView()
    
    // MARK: UI
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let overlayView = UIView()
    private var pickerHost: UIHostingController<DateTimePickerPopup>?
    
    // MARK: State
    private let viewModel = AnalysisViewModel()
    private var cancellables = Set<AnyCancellable>()
    private let uiEvents = UIEvents()
    
    private var showStartPicker = false
    private var showEndPicker   = false
    
    private var startDate: Date = Date().monthAgo
    private var endDate:   Date = Date()
    private var sortOption: SortOption = .date
    
    private let spinner = UIActivityIndicatorView(style: .large)
    
    private var currentTransactions: [Transaction] {
        return viewModel.sortedTransactions
    }

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

        view.addSubview(tableView)
        tableView.delegate   = self
        tableView.dataSource = self

        setupTableView()
        setupTableHeader()
        setupTableView()
        setupOverlay()
        setupSpinner()
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
        additionalSafeAreaInsets.bottom = UIApplication.shared.bottomSafeAreaInset
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
    
    private func setupSpinner() {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func showLoading() {
        DispatchQueue.main.async {
            self.spinner.startAnimating()
        }
    }
    
    private func hideLoading() {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
        }
    }
    
    private func presentError(_ error: Error) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }

    private func setupBindings() {
        viewModel.$sortedTransactions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.tableView.reloadData()

                // Получаем текущие транзакции
                let transactions = self.currentTransactions

                // Считаем общую сумму
                let totalSumDecimal: Decimal = transactions.reduce(.zero) { $0 + $1.amount }

                // Если нет транзакций — обнуляем график и выходим
                guard totalSumDecimal != .zero else {
                    self.chart.entities = []
                    print("No transactions → entities = []")
                    return
                }

                // Группируем по категориям и считаем сумму по каждой категории
                let sumsByCategory: [Int: Decimal] = Dictionary(
                    grouping: transactions,
                    by: { $0.categoryId }
                ).mapValues { txs in
                    txs.reduce(.zero) { $0 + $1.amount }
                }

                let viewModel = self.viewModel
                
                // Формируем массив PieChartEntity с процентами
                let entities: [PieChartEntity] = sumsByCategory
                    .map { categoryId, categorySum in
                        // percent = (sum / totalSum) * 100
                        let percentDecimal = (categorySum / totalSumDecimal) * Decimal(100)
                        let percentDouble  = NSDecimalNumber(decimal: percentDecimal).doubleValue
                        
                        return PieChartEntity(
                            value: Decimal(percentDouble),
                            label: viewModel.categoryName(for: categoryId)
                        )
                    }
                    // Сортируем по убыванию доли
                    .sorted { $0.value > $1.value }

                // Передаём во вью
                self.chart.entities = entities

                // И обновляем диаграмму
                self.chart.setEntities(entities, animated: true)
            }
            .store(in: &cancellables)
    }

    // MARK: Data
    private func loadData() {
        Task {
            showLoading()
            do {
                try await viewModel.reload(
                    direction: direction,
                    start:     startDate,
                    end:       endDate,
                    sort:      sortOption,
                    accountId: accountId
                )
            } catch {
                presentError(error)
            }
            hideLoading()
        }
        
    }
}

// MARK: — UITableViewDataSource
extension AnalysisViewController: UITableViewDataSource {
    private var displayedTransactions: [Transaction] {
        return viewModel.sortedTransactions
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
            let totalMag = (viewModel.total as NSDecimalNumber).doubleValue.magnitude
            if totalMag != 0 {
                let amtMag = (tx.amount as NSDecimalNumber).doubleValue.magnitude
                let ratio  = amtMag / totalMag
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

        let items = SortOption.allCases.map { $0.title }
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
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.section {
        case 0:
            // Секция "Дата начала/конца"
            switch indexPath.row {
            case 0:
                presentPicker(kind: .start)
            case 1:
                presentPicker(kind: .end)
            default:
                break
            }

        case 1:
            let tx = displayedTransactions[indexPath.row]
            let form = TransactionFormView(mode: .edit(tx), direction: direction)
                .onDisappear {
                    self.loadData()
                }
            let host = UIHostingController(
                rootView: form
                    .environmentObject(self.uiEvents)
            )
            host.modalPresentationStyle = .automatic
            present(host, animated: true)

        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
            switch section {
            case 0:
                return tableView.bounds.width * 0.5
            default:
                return 0.1
            }
        }

        // Визуальный футер (в него встанет chart)
        func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
            guard section == 0 else { return nil }

            let container = UIView()
            container.backgroundColor = .clear

            container.addSubview(chart)
            chart.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                chart.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
                chart.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                chart.widthAnchor.constraint(equalToConstant: 180),
                chart.heightAnchor.constraint(equalToConstant: 180),
            ])

            return container
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
        let opt = SortOption(rawValue: sender.selectedSegmentIndex)!
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
