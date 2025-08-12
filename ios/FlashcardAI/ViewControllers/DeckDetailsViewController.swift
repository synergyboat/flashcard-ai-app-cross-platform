import UIKit

class DeckDetailsViewController: UIViewController {
    
    private let headerView = UIView()
    private let deckNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let cardContainerView = UIView()
    private let closeButton = UIButton(type: .system)
    
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
        setupCardStack()
        setupConstraints()
    }
    
    private func setupHeaderView() {
        headerView.backgroundColor = .white
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        deckNameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        deckNameLabel.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        deckNameLabel.numberOfLines = 0
        deckNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1.0)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(deckNameLabel)
        headerView.addSubview(descriptionLabel)
        
        view.addSubview(headerView)
    }
    
    private func setupCardStack() {
        cardContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardContainerView)
        
        // Add close button (acts like a back/close)
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1.0)
        closeButton.layer.cornerRadius = 12
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        
        // Top card
        if let first = flashcards.first {
            let flashcardView = FlashcardView()
            flashcardView.configure(with: first)
            flashcardView.translatesAutoresizingMaskIntoConstraints = false
            cardContainerView.addSubview(flashcardView)
            NSLayoutConstraint.activate([
                flashcardView.centerXAnchor.constraint(equalTo: cardContainerView.centerXAnchor),
                flashcardView.centerYAnchor.constraint(equalTo: cardContainerView.centerYAnchor),
                flashcardView.widthAnchor.constraint(equalTo: cardContainerView.widthAnchor, multiplier: 0.92),
                flashcardView.heightAnchor.constraint(equalTo: cardContainerView.heightAnchor, multiplier: 0.75)
            ])
        }
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
            
            descriptionLabel.topAnchor.constraint(equalTo: deckNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            descriptionLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20),
            
            // Card stack container
            cardContainerView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            cardContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cardContainerView.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -20),
            
            // Close button at bottom
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            closeButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    func configure(with deck: Deck) {
        self.deck = deck
        updateHeaderContent()
    }
    
    private func updateHeaderContent() {
        guard let deck = deck else { return }
        
        deckNameLabel.text = deck.name
        if !deck.description.isEmpty {
            descriptionLabel.text = deck.description
            descriptionLabel.isHidden = false
        } else {
            descriptionLabel.isHidden = true
        }
    }
    
    private func loadFlashcards() {
        guard let deck = deck, let deckId = deck.id else { return }
        
        Task {
            flashcards = await databaseService.getFlashcards(deckId: deckId)
            
            DispatchQueue.main.async {
                self.updateHeaderContent()
                // Rebuild top card in stack
                self.cardContainerView.subviews.forEach { $0.removeFromSuperview() }
                if let first = self.flashcards.first {
                    let flashcardView = FlashcardView()
                    flashcardView.configure(with: first)
                    flashcardView.translatesAutoresizingMaskIntoConstraints = false
                    self.cardContainerView.addSubview(flashcardView)
                    NSLayoutConstraint.activate([
                        flashcardView.centerXAnchor.constraint(equalTo: self.cardContainerView.centerXAnchor),
                        flashcardView.centerYAnchor.constraint(equalTo: self.cardContainerView.centerYAnchor),
                        flashcardView.widthAnchor.constraint(equalTo: self.cardContainerView.widthAnchor, multiplier: 0.92),
                        flashcardView.heightAnchor.constraint(equalTo: self.cardContainerView.heightAnchor, multiplier: 0.75)
                    ])
                }
            }
        }
    }
    
    @objc private func closeTapped() {
        navigationController?.popViewController(animated: true)
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
 