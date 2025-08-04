import UIKit

class DeckDetailsViewController: UIViewController {
    
    private let tableView = UITableView()
    private let headerView = UIView()
    private let deckNameLabel = UILabel()
    private let cardCountLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let startStudyButton = GradientButton()
    private let deleteButton = UIButton(type: .system)
    
    private var deck: Deck?
    private var flashcards: [Flashcard] = []
    private let databaseService = DatabaseService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadFlashcards()
    }
    
    private func setupUI() {
        title = AppConfig.ScreenTitles.deckDetails
        view.backgroundColor = UIColor(red: 254/255, green: 248/255, blue: 255/255, alpha: 1.0)
        
        setupHeaderView()
        setupTableView()
        setupButtons()
        setupConstraints()
    }
    
    private func setupHeaderView() {
        headerView.backgroundColor = .white
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        deckNameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        deckNameLabel.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        deckNameLabel.numberOfLines = 0
        deckNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cardCountLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cardCountLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
        cardCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1.0)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(deckNameLabel)
        headerView.addSubview(cardCountLabel)
        headerView.addSubview(descriptionLabel)
        
        view.addSubview(headerView)
    }
    
    private func setupTableView() {
        tableView.backgroundColor = UIColor(red: 254/255, green: 248/255, blue: 255/255, alpha: 1.0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FlashcardTableViewCell.self, forCellReuseIdentifier: FlashcardTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 120, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
    }
    
    private func setupButtons() {
        startStudyButton.setTitle("Start Study Session", for: .normal)
        startStudyButton.translatesAutoresizingMaskIntoConstraints = false
        startStudyButton.addTarget(self, action: #selector(startStudyTapped), for: .touchUpInside)
        
        deleteButton.setTitle("Delete Deck", for: .normal)
        deleteButton.setTitleColor(UIColor(red: 255/255, green: 68/255, blue: 68/255, alpha: 1.0), for: .normal)
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = UIColor(red: 255/255, green: 68/255, blue: 68/255, alpha: 1.0)
        deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        view.addSubview(startStudyButton)
        view.addSubview(deleteButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header view
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            deckNameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            deckNameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            deckNameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            cardCountLabel.topAnchor.constraint(equalTo: deckNameLabel.bottomAnchor, constant: 8),
            cardCountLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            cardCountLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: cardCountLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            descriptionLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20),
            
            // Table view
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Buttons
            startStudyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startStudyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            startStudyButton.bottomAnchor.constraint(equalTo: deleteButton.topAnchor, constant: -20),
            
            deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    func configure(with deck: Deck) {
        self.deck = deck
        updateHeaderContent()
    }
    
    private func updateHeaderContent() {
        guard let deck = deck else { return }
        
        deckNameLabel.text = deck.name
        cardCountLabel.text = "\(flashcards.count) card\(flashcards.count != 1 ? "s" : "")"
        
        if let description = deck.description, !description.isEmpty {
            descriptionLabel.text = description
            descriptionLabel.isHidden = false
        } else {
            descriptionLabel.isHidden = true
        }
        
        startStudyButton.isEnabled = !flashcards.isEmpty
    }
    
    private func loadFlashcards() {
        guard let deck = deck, let deckId = deck.id else { return }
        
        Task {
            flashcards = await databaseService.getFlashcards(deckId: deckId)
            
            DispatchQueue.main.async {
                self.updateHeaderContent()
                self.tableView.reloadData()
            }
        }
    }
    
    @objc private func startStudyTapped() {
        guard let deck = deck, !flashcards.isEmpty else {
            showAlert(title: "No Cards", message: "This deck has no flashcards to study.")
            return
        }
        
        let studyVC = StudyViewController()
        studyVC.configure(with: deck, flashcards: flashcards)
        navigationController?.pushViewController(studyVC, animated: true)
    }
    
    @objc private func deleteButtonTapped() {
        let alert = UIAlertController(
            title: "Delete Deck",
            message: "Are you sure you want to delete this deck? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteDeck()
        })
        
        present(alert, animated: true)
    }
    
    private func deleteDeck() {
        guard let deck = deck, let deckId = deck.id else { return }
        
        Task {
            await databaseService.deleteDeck(id: deckId)
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension DeckDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flashcards.isEmpty ? 1 : flashcards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if flashcards.isEmpty {
            let cell = UITableViewCell()
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            let emptyView = UIView()
            emptyView.translatesAutoresizingMaskIntoConstraints = false
            
            let imageView = UIImageView(image: UIImage(systemName: "doc.text"))
            imageView.tintColor = UIColor(white: 0.8, alpha: 1.0)
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            let label = UILabel()
            label.text = "No flashcards in this deck"
            label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            label.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1.0)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            
            emptyView.addSubview(imageView)
            emptyView.addSubview(label)
            cell.contentView.addSubview(emptyView)
            
            NSLayoutConstraint.activate([
                emptyView.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                emptyView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                
                imageView.topAnchor.constraint(equalTo: emptyView.topAnchor),
                imageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 48),
                imageView.heightAnchor.constraint(equalToConstant: 48),
                
                label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
                label.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor),
                label.bottomAnchor.constraint(equalTo: emptyView.bottomAnchor)
            ])
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: FlashcardTableViewCell.identifier, for: indexPath) as! FlashcardTableViewCell
        cell.configure(with: flashcards[indexPath.row], number: indexPath.row + 1)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension DeckDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return flashcards.isEmpty ? 200 : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - FlashcardTableViewCell
class FlashcardTableViewCell: UITableViewCell {
    static let identifier = "FlashcardTableViewCell"
    
    private let containerView = UIView()
    private let numberView = UIView()
    private let numberLabel = UILabel()
    private let questionLabel = UILabel()
    private let answerLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .clear
        selectionStyle = .none
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowRadius = 2
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        numberView.backgroundColor = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1.0)
        numberView.layer.cornerRadius = 16
        numberView.translatesAutoresizingMaskIntoConstraints = false
        
        numberLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        numberLabel.textColor = .white
        numberLabel.textAlignment = .center
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        questionLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        questionLabel.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        questionLabel.numberOfLines = 2
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        answerLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        answerLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
        answerLabel.numberOfLines = 1
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(containerView)
        containerView.addSubview(numberView)
        numberView.addSubview(numberLabel)
        containerView.addSubview(questionLabel)
        containerView.addSubview(answerLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            numberView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            numberView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            numberView.widthAnchor.constraint(equalToConstant: 32),
            numberView.heightAnchor.constraint(equalToConstant: 32),
            
            numberLabel.centerXAnchor.constraint(equalTo: numberView.centerXAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: numberView.centerYAnchor),
            
            questionLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            questionLabel.leadingAnchor.constraint(equalTo: numberView.trailingAnchor, constant: 16),
            questionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            answerLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 4),
            answerLabel.leadingAnchor.constraint(equalTo: numberView.trailingAnchor, constant: 16),
            answerLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            answerLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with flashcard: Flashcard, number: Int) {
        numberLabel.text = "\(number)"
        questionLabel.text = flashcard.question
        answerLabel.text = flashcard.answer
    }
} 