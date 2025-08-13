import UIKit

class DeckPreviewViewController: UIViewController {
    
    private let headerView = UIView()
    private let deckNameLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let cardContainerView = UIView()
    private let saveButton = GradientButton()
    private let infoContainer = UIStackView()
    private let infoIcon = UIImageView(image: UIImage(systemName: "info.circle"))
    private let infoLabel = UILabel()
    
    private let databaseService = DatabaseService.shared
    
    // Data passed in from AI generation
    private var deckTitle: String = ""
    private var deckDescription: String = ""
    private var previewCards: [(question: String, answer: String)] = []
    
    private var currentIndex: Int = 0
    private var currentFlashcardView: FlashcardView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCurrentCard()
    }
    
    func configure(deckTitle: String, deckDescription: String, cards: [(String, String)]) {
        self.deckTitle = deckTitle
        self.deckDescription = deckDescription
        self.previewCards = cards
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 254/255, green: 248/255, blue: 255/255, alpha: 1.0)
        setupHeader()
        setupCardContainer()
        setupSaveButton()
        setupInfo()
        setupConstraints()
    }
    
    private func setupHeader() {
        headerView.backgroundColor = .white
        headerView.layer.shadowColor = UIColor.black.cgColor
        headerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        headerView.layer.shadowOpacity = 0.1
        headerView.layer.shadowRadius = 2
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        deckNameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        deckNameLabel.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        deckNameLabel.translatesAutoresizingMaskIntoConstraints = false
        deckNameLabel.text = deckTitle
        
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
        closeButton.backgroundColor = UIColor(red: 254/255, green: 248/255, blue: 255/255, alpha: 1.0)
        closeButton.layer.cornerRadius = 20
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        headerView.addSubview(deckNameLabel)
        headerView.addSubview(closeButton)
        view.addSubview(headerView)
    }
    
    private func setupCardContainer() {
        cardContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardContainerView)
    }
    
    private func setupSaveButton() {
        saveButton.setTitle("Save Deck", for: .normal)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveDeckTapped), for: .touchUpInside)
        view.addSubview(saveButton)
    }
    
    private func setupInfo() {
        infoContainer.axis = .horizontal
        infoContainer.alignment = .top
        infoContainer.distribution = .fill
        infoContainer.spacing = 8
        infoContainer.translatesAutoresizingMaskIntoConstraints = false
        
        infoIcon.tintColor = UIColor(white: 0.6, alpha: 1.0)
        infoIcon.translatesAutoresizingMaskIntoConstraints = false
        
        infoLabel.text = "The AI will generate a deck based on your prompt. The generated deck will contain a maximum of {cardCount} cards. Please note that language models may not always produce accurate or relevant results, so review the generated cards before using them."
        infoLabel.font = UIFont.systemFont(ofSize: 12)
        infoLabel.textColor = UIColor(white: 0.4, alpha: 1.0)
        infoLabel.numberOfLines = 0
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        infoContainer.addArrangedSubview(infoIcon)
        infoContainer.addArrangedSubview(infoLabel)
        view.addSubview(infoContainer)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            deckNameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            deckNameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            deckNameLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -20),
            
            closeButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Card container
            cardContainerView.topAnchor.constraint(equalTo: deckNameLabel.bottomAnchor, constant: 20),
            cardContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Save button
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            // Info row
            infoContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            infoContainer.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -12),
            infoIcon.widthAnchor.constraint(equalToConstant: 20)
        ])
        
        // Set bottom of card container
        cardContainerView.bottomAnchor.constraint(equalTo: infoContainer.topAnchor, constant: -20).isActive = true
    }
    
    private func setupCurrentCard() {
        guard currentIndex < previewCards.count else { return }
        
        currentFlashcardView?.removeFromSuperview()
        let viewCard = FlashcardView()
        let q = previewCards[currentIndex].question
        let a = previewCards[currentIndex].answer
        // Temporary flashcard just for display
        let temp = Flashcard(id: nil, deckId: -1, question: q, answer: a)
        viewCard.configure(with: temp)
        viewCard.delegate = self
        viewCard.translatesAutoresizingMaskIntoConstraints = false
        
        cardContainerView.addSubview(viewCard)
        NSLayoutConstraint.activate([
            viewCard.centerXAnchor.constraint(equalTo: cardContainerView.centerXAnchor),
            viewCard.centerYAnchor.constraint(equalTo: cardContainerView.centerYAnchor),
            viewCard.widthAnchor.constraint(equalTo: cardContainerView.widthAnchor, multiplier: 0.92),
            viewCard.heightAnchor.constraint(equalTo: cardContainerView.heightAnchor, multiplier: 0.75)
        ])
        currentFlashcardView = viewCard
    }
    
    private func moveToNextCard() {
        currentIndex = min(currentIndex + 1, max(0, previewCards.count - 1))
        setupCurrentCard()
    }
    
    @objc private func closeTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func saveDeckTapped() {
        guard !deckTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showAlert(title: "Error", message: "Invalid deck title")
            return
        }
        
        let cards = previewCards
        Task {
            let deckId = await databaseService.createDeck(name: deckTitle, description: deckDescription)
            if deckId > 0 {
                let flashcards = cards.map { pair in
                    Flashcard(id: nil, deckId: deckId, question: pair.question, answer: pair.answer)
                }
                await databaseService.createFlashcards(flashcards)
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Failed to save deck")
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension DeckPreviewViewController: FlashcardViewDelegate {
    func flashcardDidSwipeLeft(_ flashcardView: FlashcardView) {
        moveToNextCard()
    }
    
    func flashcardDidSwipeRight(_ flashcardView: FlashcardView) {
        moveToNextCard()
    }
}


