//
//  AnalysisTransactionCell.swift
//  FinanceApp
//
//  Created by Эльвира Матвеенко on 08.07.2025.
//

import UIKit

final class AnalysisTransactionCell: UITableViewCell {

    static let reuseID = "AnalysisTransactionCell"

    // MARK: UI
    private let iconBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "AccentColor")?
            .withAlphaComponent(0.2)
        view.layer.cornerRadius = 11
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emojiLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 12)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 17)
        lbl.textColor = .label
        return lbl
    }()

    private let commentLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 13)
        lbl.textColor = .secondaryLabel
        return lbl
    }()

    private let percentageLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 17)
        lbl.textColor = .label
        lbl.textAlignment = .right
        return lbl
    }()

    private let amountLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 17)
        lbl.textColor = .label
        lbl.textAlignment = .right
        return lbl
    }()

    private let textStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 2
        return s
    }()

    private let valueStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 2
        s.alignment = .trailing
        return s
    }()

    private let hStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.alignment = .center
        s.spacing = 12
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    // MARK: Data
    private let catsService: CategoriesServiceProtocol = CategoriesService()
    private var currentCategoryId: Int?
    private var category: Category? {
        didSet {
            // Обновляем UI, когда категория загрузится
            emojiLabel.text = String(category?.emoji ?? "💸")
            titleLabel.text = category?.name ?? "Категория"
        }
    }

    // MARK: Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // сброс перед переиспользованием
        currentCategoryId = nil
        category = nil
        commentLabel.text = nil
        percentageLabel.text = nil
        amountLabel.text = nil
    }

    // MARK: Layout
    private func configureUI() {
        // Иконка в круге
        contentView.addSubview(iconBackgroundView)
        iconBackgroundView.addSubview(emojiLabel)
        NSLayoutConstraint.activate([
            iconBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconBackgroundView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconBackgroundView.widthAnchor.constraint(equalToConstant: 22),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: 22),

            emojiLabel.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor)
        ])

        // Левый текстовый стек
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(commentLabel)

        // Правый стек для % + суммы
        valueStack.addArrangedSubview(percentageLabel)
        valueStack.addArrangedSubview(amountLabel)
        percentageLabel.setContentHuggingPriority(.required, for: .vertical)
        amountLabel.setContentHuggingPriority(.required, for: .vertical)

        // Основной H-стек и отступы
        hStack.addArrangedSubview(textStack)
        hStack.addArrangedSubview(valueStack)
        contentView.addSubview(hStack)
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: iconBackgroundView.trailingAnchor, constant: 12),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            hStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            hStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
    }

    /// Передаём транзакцию и процент её от общей суммы
    func configure(with tx: Transaction, percentage: Int) {
        if currentCategoryId != tx.categoryId {
            currentCategoryId = tx.categoryId
            Task {
                do {
                    let cats = try await catsService.categories()
                    if let cat = cats.first(where: { $0.id == tx.categoryId }) {
                        DispatchQueue.main.async {
                            self.category = cat
                        }
                    }
                } catch {
                    emojiLabel.text = "💸"
                    titleLabel.text = "Категория #\(tx.categoryId)"
                }
            }
        }
        
        // комментарий
        commentLabel.text = tx.comment
        commentLabel.isHidden = (tx.comment ?? "").isEmpty

        // проценты и сумма
        percentageLabel.text = "\(percentage)%"
        amountLabel.text = tx.formattedAmount
    }
}
