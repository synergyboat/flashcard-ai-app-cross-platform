import UIKit

// Configuration struct (temporary inline until Xcode project includes them)
struct AppConfig {
    struct ScreenTitles {
        static let home = "Flashcard AI"
        static let deckDetails = "Deck Details"
        static let aiGenerate = "AI Generate Deck"
        static let study = "Study"
    }
    
    struct CardLimits {
        static let min = 1
        static let max = 20
        static let defaultValue = 5
    }
    
    struct Animations {
        static let flipTension: Float = 300
        static let flipFriction: Float = 10
        static let swipeDuration: TimeInterval = 0.3
        static let cardHeight: CGFloat = 400
        static let swipeThreshold: CGFloat = 150
    }
    
    struct UI {
        struct BorderRadius {
            static let small: CGFloat = 8
            static let medium: CGFloat = 12
            static let large: CGFloat = 16
        }
        
        struct Spacing {
            static let small: CGFloat = 8
            static let medium: CGFloat = 16
            static let large: CGFloat = 24
            static let containerPadding: CGFloat = 16
        }
        
        struct Dimensions {
            static let fabSize: CGFloat = 56
            static let buttonHeight: CGFloat = 48
        }
    }
}

class AIGenerateViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Provide a topic or concept below. The AI will generate a flashcard deck based on your input."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let topicTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 12
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor(red: 225/255, green: 229/255, blue: 233/255, alpha: 1.0).cgColor
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter a Topic for the Deck"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cardCountLabel: UILabel = {
        let label = UILabel()
        label.text = "Number of Cards"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cardCountPicker = UIPickerView()
    private let cardCountRow = UIStackView()
    private let cardCountContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 225/255, green: 229/255, blue: 233/255, alpha: 1.0).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let cardCountValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let dropdownIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.down"))
        imageView.tintColor = UIColor(white: 0.6, alpha: 1.0)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let generateButton = GradientButton()
    
    private let loadingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1.0)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "Creating your flashcards..."
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoRow = UIStackView()
    private let infoIcon = UIImageView(image: UIImage(systemName: "info.circle"))
    private let infoText = UILabel()
    
    private let aiService = AIService.shared
    private let databaseService = DatabaseService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTargets()
        updateAIStatus()
    }
    
    private func setupUI() {
        title = AppConfig.ScreenTitles.aiGenerate
        view.backgroundColor = UIColor(red: 254/255, green: 248/255, blue: 255/255, alpha: 1.0)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(topicTextView)
        contentView.addSubview(placeholderLabel)
        // Row for label (left) and dropdown container (right)
        cardCountRow.axis = .horizontal
        cardCountRow.alignment = .center
        cardCountRow.distribution = .fill
        cardCountRow.spacing = 24
        cardCountRow.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardCountRow)
        cardCountRow.addArrangedSubview(cardCountLabel)
        cardCountRow.addArrangedSubview(cardCountContainer)
        cardCountContainer.addSubview(cardCountValueLabel)
        cardCountContainer.addSubview(dropdownIcon)
        contentView.addSubview(generateButton)
        contentView.addSubview(loadingView)
        // infoRow is anchored to the bottom of the screen (outside scroll content)
        view.addSubview(infoRow)

        loadingView.addSubview(loadingIndicator)
        loadingView.addSubview(loadingLabel)
        
        infoRow.axis = .horizontal
        infoRow.alignment = .top
        infoRow.spacing = 8
        infoRow.translatesAutoresizingMaskIntoConstraints = false
        infoIcon.tintColor = UIColor(white: 0.6, alpha: 1.0)
        infoIcon.translatesAutoresizingMaskIntoConstraints = false
        infoText.font = UIFont.systemFont(ofSize: 12)
        infoText.textColor = UIColor(white: 0.4, alpha: 1.0)
        infoText.numberOfLines = 0
        infoText.text = "The AI will generate a deck based on your prompt. The generated deck will contain a maximum of {cardCount} cards. Please note that language models may not always produce accurate or relevant results, so review the generated cards before using them."
        infoText.translatesAutoresizingMaskIntoConstraints = false
        infoRow.addArrangedSubview(infoIcon)
        infoRow.addArrangedSubview(infoText)
        
        generateButton.setTitle("Generate Deck", for: .normal)
        generateButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Make button more rounded (pill-shaped) and add sparkle icon
        generateButton.layer.cornerRadius = 25  // More rounded
        generateButton.gradientLayer.cornerRadius = 25
        
        // Add colored drop shadow matching the button gradient
        generateButton.layer.shadowColor = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1.0).cgColor
        generateButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        generateButton.layer.shadowOpacity = 0.3
        generateButton.layer.shadowRadius = 8
        generateButton.layer.masksToBounds = false
        
        // Add sparkle icon
        if let sparkleImage = UIImage(systemName: "sparkles") {
            generateButton.setImage(sparkleImage, for: .normal)
            generateButton.imageView?.tintColor = .white
            // Use semanticContentAttribute instead of deprecated edge insets
            generateButton.semanticContentAttribute = .forceLeftToRight
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // Scroll above info row so it does not overlap bottom info text
            scrollView.bottomAnchor.constraint(equalTo: infoRow.topAnchor, constant: -12),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            topicTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            topicTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            topicTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            topicTextView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: topicTextView.topAnchor, constant: 16),
            placeholderLabel.leadingAnchor.constraint(equalTo: topicTextView.leadingAnchor, constant: 16),
            
            // Card count row (label + dropdown) on same line
            cardCountRow.topAnchor.constraint(equalTo: topicTextView.bottomAnchor, constant: 24),
            cardCountRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardCountRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            cardCountContainer.heightAnchor.constraint(equalToConstant: 44),
            // Prefer container to hug its content and stay to the right
            cardCountContainer.widthAnchor.constraint(greaterThanOrEqualToConstant: 90),
            
            cardCountValueLabel.leadingAnchor.constraint(equalTo: cardCountContainer.leadingAnchor, constant: 12),
            cardCountValueLabel.centerYAnchor.constraint(equalTo: cardCountContainer.centerYAnchor),
            
            dropdownIcon.leadingAnchor.constraint(equalTo: cardCountValueLabel.trailingAnchor, constant: 8),
            dropdownIcon.trailingAnchor.constraint(equalTo: cardCountContainer.trailingAnchor, constant: -12),
            dropdownIcon.centerYAnchor.constraint(equalTo: cardCountContainer.centerYAnchor),
            dropdownIcon.widthAnchor.constraint(equalToConstant: 14),
            dropdownIcon.heightAnchor.constraint(equalToConstant: 10),
            
            generateButton.topAnchor.constraint(equalTo: cardCountRow.bottomAnchor, constant: 24),
            generateButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            generateButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            generateButton.heightAnchor.constraint(equalToConstant: 50),
            
            loadingView.topAnchor.constraint(equalTo: generateButton.bottomAnchor, constant: 32),
            loadingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            loadingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            loadingIndicator.topAnchor.constraint(equalTo: loadingView.topAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            
            loadingLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 12),
            loadingLabel.leadingAnchor.constraint(equalTo: loadingView.leadingAnchor),
            loadingLabel.trailingAnchor.constraint(equalTo: loadingView.trailingAnchor),
            loadingLabel.bottomAnchor.constraint(equalTo: loadingView.bottomAnchor),
            loadingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // Bottom info row anchored to screen bottom
            infoRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            infoRow.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            infoIcon.widthAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setupTargets() {
        generateButton.addTarget(self, action: #selector(generateButtonTapped), for: .touchUpInside)
        
        topicTextView.delegate = self
        
        // Picker for card count
        cardCountPicker.dataSource = self
        cardCountPicker.delegate = self
        cardCountValueLabel.text = "\(AppConfig.CardLimits.defaultValue)"
        let tap = UITapGestureRecognizer(target: self, action: #selector(showCardCountPicker))
        cardCountContainer.addGestureRecognizer(tap)
        cardCountContainer.isUserInteractionEnabled = true
        // Make label hug left inside container, container stays right in row
        cardCountLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        cardCountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        cardCountContainer.setContentHuggingPriority(.required, for: .horizontal)
        cardCountContainer.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private func updateAIStatus() {
        // No longer showing explicit status section; keep for logic if needed in future
    }
    
    @objc private func generateButtonTapped() {
        guard let topic = topicTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !topic.isEmpty else {
            showAlert(title: "Error", message: "Please enter a topic")
            return
        }
        
        let cardCount = Int(cardCountValueLabel.text ?? "\(AppConfig.CardLimits.defaultValue)") ?? AppConfig.CardLimits.defaultValue
        guard cardCount >= AppConfig.CardLimits.min && cardCount <= AppConfig.CardLimits.max else {
            showAlert(title: "Error", message: "Please enter a valid number of cards (\(AppConfig.CardLimits.min)-\(AppConfig.CardLimits.max))")
            return
        }
        
        setLoading(true)
        
        let request = AIGenerationRequest(topic: topic, cardCount: cardCount)
        
        Task {
            do {
                let response = try await aiService.generateFlashcards(request: request)
                
                DispatchQueue.main.async {
                    self.setLoading(false)
                    // Navigate to preview screen with stack and save button
                    let previewVC = DeckPreviewViewController()
                    previewVC.configure(
                        deckTitle: response.deck.name,
                        deckDescription: response.deck.description,
                        cards: response.flashcards.map { ($0.question, $0.answer) }
                    )
                    self.navigationController?.pushViewController(previewVC, animated: true)
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.setLoading(false)
                    self.showAlert(title: "Error", message: "Failed to generate flashcards: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func setLoading(_ loading: Bool) {
        loadingView.isHidden = !loading
        generateButton.isEnabled = !loading
        generateButton.setTitle(loading ? "Generating..." : "Generate Deck", for: .normal)
        
        if loading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }
    
    private func resetForm() {
        topicTextView.text = ""
        cardCountValueLabel.text = "\(AppConfig.CardLimits.defaultValue)"
        placeholderLabel.isHidden = false
    }
    
    private func navigateToDeckDetails(deckId: Int, deckName: String) {
        Task {
            if let deck = await databaseService.getDeck(id: deckId) {
                DispatchQueue.main.async {
                    let deckDetailsVC = DeckDetailsViewController()
                    deckDetailsVC.configure(with: deck)
                    self.navigationController?.pushViewController(deckDetailsVC, animated: true)
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func showCardCountPicker() {
        dismissKeyboard()
        let alert = UIAlertController(title: "Select number of cards", message: "", preferredStyle: .actionSheet)
        let options = [5, 10, 15, 20]
        for option in options {
            alert.addAction(UIAlertAction(title: "\(option)", style: .default, handler: { _ in
                self.cardCountValueLabel.text = "\(option)"
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UITextViewDelegate
extension AIGenerateViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
} 

// MARK: - UIPickerViewDataSource & Delegate
extension AIGenerateViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { 4 }
}

// MARK: - Inline DeckPreviewViewController (kept here to ensure it's part of target build)
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
            
            cardContainerView.topAnchor.constraint(equalTo: deckNameLabel.bottomAnchor, constant: 20),
            cardContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            infoContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            infoContainer.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -12),
            infoIcon.widthAnchor.constraint(equalToConstant: 20)
        ])
        cardContainerView.bottomAnchor.constraint(equalTo: infoContainer.topAnchor, constant: -20).isActive = true
    }
    
    private func setupCurrentCard() {
        guard currentIndex < previewCards.count else { return }
        currentFlashcardView?.removeFromSuperview()
        let viewCard = FlashcardView()
        let q = previewCards[currentIndex].question
        let a = previewCards[currentIndex].answer
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