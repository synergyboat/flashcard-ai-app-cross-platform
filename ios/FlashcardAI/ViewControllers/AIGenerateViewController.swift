import UIKit

class AIGenerateViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Generate Deck with AI"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let topicLabel: UILabel = {
        let label = UILabel()
        label.text = "Topic"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
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
        label.text = "Enter your prompt here"
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
    
    private let cardCountTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(red: 225/255, green: 229/255, blue: 233/255, alpha: 1.0).cgColor
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        textField.text = "5"
        textField.keyboardType = .numberPad
        textField.borderStyle = .none
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
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
    
    private let infoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 225/255, green: 229/255, blue: 233/255, alpha: 1.0).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let infoTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "How it works:"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoTextLabel: UILabel = {
        let label = UILabel()
        label.text = """
        • Enter any topic you want to study
        • Choose how many flashcards to generate
        • AI will create educational questions and answers
        • Your new deck will be saved automatically
        """
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let aiStatusTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "AI Status:"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let aiStatusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let aiStatusNoteLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1.0)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let aiService = AIService.shared
    private let databaseService = DatabaseService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTargets()
        updateAIStatus()
    }
    
    private func setupUI() {
        title = "AI Generate Deck"
        view.backgroundColor = UIColor(red: 248/255, green: 249/255, blue: 250/255, alpha: 1.0)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(topicLabel)
        contentView.addSubview(topicTextView)
        contentView.addSubview(placeholderLabel)
        contentView.addSubview(cardCountLabel)
        contentView.addSubview(cardCountTextField)
        contentView.addSubview(generateButton)
        contentView.addSubview(loadingView)
        contentView.addSubview(infoContainerView)
        
        loadingView.addSubview(loadingIndicator)
        loadingView.addSubview(loadingLabel)
        
        infoContainerView.addSubview(infoTitleLabel)
        infoContainerView.addSubview(infoTextLabel)
        infoContainerView.addSubview(aiStatusTitleLabel)
        infoContainerView.addSubview(aiStatusLabel)
        infoContainerView.addSubview(aiStatusNoteLabel)
        
        generateButton.setTitle("Generate Deck", for: .normal)
        generateButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            topicLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            topicLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            topicLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            topicTextView.topAnchor.constraint(equalTo: topicLabel.bottomAnchor, constant: 8),
            topicTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            topicTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            topicTextView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: topicTextView.topAnchor, constant: 16),
            placeholderLabel.leadingAnchor.constraint(equalTo: topicTextView.leadingAnchor, constant: 16),
            
            cardCountLabel.topAnchor.constraint(equalTo: topicTextView.bottomAnchor, constant: 24),
            cardCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            cardCountTextField.topAnchor.constraint(equalTo: cardCountLabel.bottomAnchor, constant: 8),
            cardCountTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardCountTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardCountTextField.heightAnchor.constraint(equalToConstant: 50),
            
            generateButton.topAnchor.constraint(equalTo: cardCountTextField.bottomAnchor, constant: 24),
            generateButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            generateButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            loadingView.topAnchor.constraint(equalTo: generateButton.bottomAnchor, constant: 32),
            loadingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            loadingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            loadingIndicator.topAnchor.constraint(equalTo: loadingView.topAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            
            loadingLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 12),
            loadingLabel.leadingAnchor.constraint(equalTo: loadingView.leadingAnchor),
            loadingLabel.trailingAnchor.constraint(equalTo: loadingView.trailingAnchor),
            loadingLabel.bottomAnchor.constraint(equalTo: loadingView.bottomAnchor),
            
            infoContainerView.topAnchor.constraint(equalTo: loadingView.bottomAnchor, constant: 32),
            infoContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            infoContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            
            infoTitleLabel.topAnchor.constraint(equalTo: infoContainerView.topAnchor, constant: 20),
            infoTitleLabel.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 20),
            infoTitleLabel.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -20),
            
            infoTextLabel.topAnchor.constraint(equalTo: infoTitleLabel.bottomAnchor, constant: 12),
            infoTextLabel.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 20),
            infoTextLabel.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -20),
            
            aiStatusTitleLabel.topAnchor.constraint(equalTo: infoTextLabel.bottomAnchor, constant: 20),
            aiStatusTitleLabel.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 20),
            aiStatusTitleLabel.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -20),
            
            aiStatusLabel.topAnchor.constraint(equalTo: aiStatusTitleLabel.bottomAnchor, constant: 8),
            aiStatusLabel.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 20),
            aiStatusLabel.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -20),
            
            aiStatusNoteLabel.topAnchor.constraint(equalTo: aiStatusLabel.bottomAnchor, constant: 4),
            aiStatusNoteLabel.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 20),
            aiStatusNoteLabel.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -20),
            aiStatusNoteLabel.bottomAnchor.constraint(equalTo: infoContainerView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupTargets() {
        generateButton.addTarget(self, action: #selector(generateButtonTapped), for: .touchUpInside)
        
        topicTextView.delegate = self
        
        // Add toolbar to number pad
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([doneButton], animated: false)
        cardCountTextField.inputAccessoryView = toolbar
    }
    
    private func updateAIStatus() {
        aiStatusLabel.text = aiService.getAIStatus()
        aiStatusNoteLabel.text = aiService.isRealAIEnabled() 
            ? "Using OpenAI GPT-3.5 for real AI generation"
            : "Using demo mode with pre-generated content"
    }
    
    @objc private func generateButtonTapped() {
        guard let topic = topicTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !topic.isEmpty else {
            showAlert(title: "Error", message: "Please enter a topic")
            return
        }
        
        guard let cardCountText = cardCountTextField.text,
              let cardCount = Int(cardCountText),
              cardCount >= 1 && cardCount <= 20 else {
            showAlert(title: "Error", message: "Please enter a valid number of cards (1-20)")
            return
        }
        
        setLoading(true)
        
        let request = AIGenerationRequest(topic: topic, cardCount: cardCount)
        
        Task {
            do {
                print("🤖 Starting AI generation for topic: \(topic)")
                let response = try await aiService.generateFlashcards(request: request)
                print("✅ AI generation completed. Got \(response.flashcards.count) cards")
                
                // Create deck in database
                print("💾 Creating deck in database...")
                let deckId = await databaseService.createDeck(
                    name: response.deck.name,
                    description: response.deck.description
                )
                print("✅ Deck created with ID: \(deckId)")
                
                // Create flashcards with explicit unique IDs
                let flashcards = response.flashcards.map { cardInfo in
                    Flashcard(
                        id: UUID().uuidString, // Explicitly generate new UUID
                        deckId: deckId,
                        question: cardInfo.question,
                        answer: cardInfo.answer
                    )
                }
                
                print("💾 Creating \(flashcards.count) flashcards...")
                print("🆔 Flashcard IDs: \(flashcards.map { $0.id })")
                await databaseService.createFlashcards(flashcards)
                print("✅ All flashcards created successfully")
                
                DispatchQueue.main.async {
                    print("🎉 Showing success alert")
                    self.setLoading(false)
                    
                    let alert = UIAlertController(
                        title: "Success!",
                        message: "Generated \(response.flashcards.count) flashcards about \"\(topic)\"",
                        preferredStyle: .alert
                    )
                    
                    alert.addAction(UIAlertAction(title: "View Deck", style: .default) { _ in
                        self.navigateToDeckDetails(deckId: deckId, deckName: response.deck.name)
                    })
                    
                    alert.addAction(UIAlertAction(title: "Generate Another", style: .default) { _ in
                        self.resetForm()
                    })
                    
                    self.present(alert, animated: true)
                }
                
            } catch {
                print("❌ Error during generation: \(error)")
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
        cardCountTextField.text = "5"
        placeholderLabel.isHidden = false
    }
    
    private func navigateToDeckDetails(deckId: String, deckName: String) {
        print("🚀 Navigating to deck details for deckId: '\(deckId)'")
        Task {
            if let deck = await databaseService.getDeck(id: deckId) {
                print("✅ Found deck: \(deck.name) with \(deck.flashcardCount ?? 0) cards")
                DispatchQueue.main.async {
                    let deckDetailsVC = DeckDetailsViewController()
                    deckDetailsVC.configure(with: deck)
                    self.navigationController?.pushViewController(deckDetailsVC, animated: true)
                }
            } else {
                print("❌ Failed to find deck with id: '\(deckId)'")
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
}

// MARK: - UITextViewDelegate
extension AIGenerateViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
} 