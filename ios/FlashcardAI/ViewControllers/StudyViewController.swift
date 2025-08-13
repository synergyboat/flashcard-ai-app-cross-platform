import UIKit

class StudyViewController: UIViewController {
    
    private let headerView = UIView()
    private let deckNameLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    // Removed progress indicator per new UI
    // private let progressView = UIProgressView()
    private let cardContainerView = UIView()
    
    private var deck: Deck?
    private var flashcards: [Flashcard] = []
    private var currentIndex = 0
    private var currentFlashcardView: FlashcardView?
    private let editButton = UIButton(type: .system)
    private let databaseService = DatabaseService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCurrentCard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 254/255, green: 248/255, blue: 255/255, alpha: 1.0)
        
        setupHeaderView()
        setupCardContainer()
        setupEditButton()
        setupConstraints()
    }
    
    private func setupHeaderView() {
        headerView.backgroundColor = .white
        headerView.layer.shadowColor = UIColor.black.cgColor
        headerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        headerView.layer.shadowOpacity = 0.1
        headerView.layer.shadowRadius = 2
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        deckNameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        deckNameLabel.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        deckNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
        closeButton.backgroundColor = UIColor(red: 254/255, green: 248/255, blue: 255/255, alpha: 1.0)
        closeButton.layer.cornerRadius = 20
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        headerView.addSubview(deckNameLabel)
        headerView.addSubview(closeButton)
        
        view.addSubview(headerView)
    }
    
    private func setupCardContainer() {
        cardContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardContainerView)
    }
    
    private func setupEditButton() {
        editButton.setTitle("Edit", for: .normal)
        editButton.setTitleColor(UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1.0), for: .normal)
        editButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        view.addSubview(editButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header view
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            deckNameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            deckNameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            deckNameLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -20),
            
            closeButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            
            deckNameLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
            
            // Card container
            cardContainerView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            cardContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cardContainerView.bottomAnchor.constraint(equalTo: editButton.topAnchor, constant: -20),
            
            editButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            editButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            editButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            editButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func configure(with deck: Deck, flashcards: [Flashcard]) {
        self.deck = deck
        self.flashcards = flashcards
        deckNameLabel.text = deck.name
    }
    
    private func setupCurrentCard() {
        guard currentIndex < flashcards.count else {
            showStudyComplete()
            return
        }
        
        // Remove previous card
        currentFlashcardView?.removeFromSuperview()
        
        // Create new card
        let flashcardView = FlashcardView()
        flashcardView.delegate = self
        flashcardView.configure(with: flashcards[currentIndex])
        flashcardView.translatesAutoresizingMaskIntoConstraints = false
        
        cardContainerView.addSubview(flashcardView)
        
        NSLayoutConstraint.activate([
            flashcardView.centerXAnchor.constraint(equalTo: cardContainerView.centerXAnchor),
            flashcardView.centerYAnchor.constraint(equalTo: cardContainerView.centerYAnchor),
            flashcardView.leadingAnchor.constraint(greaterThanOrEqualTo: cardContainerView.leadingAnchor),
            flashcardView.trailingAnchor.constraint(lessThanOrEqualTo: cardContainerView.trailingAnchor),
            flashcardView.topAnchor.constraint(greaterThanOrEqualTo: cardContainerView.topAnchor),
            flashcardView.bottomAnchor.constraint(lessThanOrEqualTo: cardContainerView.bottomAnchor),
            flashcardView.widthAnchor.constraint(equalTo: cardContainerView.widthAnchor, multiplier: 0.9),
            flashcardView.heightAnchor.constraint(equalTo: cardContainerView.heightAnchor, multiplier: 0.7)
        ])
        
        currentFlashcardView = flashcardView
    }
    
    
    private func moveToNextCard() {
        // Mark current card as reviewed
        if currentIndex < flashcards.count, let flashcardId = flashcards[currentIndex].id {
            Task {
                await databaseService.updateFlashcardReview(id: flashcardId)
            }
        }
        
        currentIndex += 1
        
        if currentIndex < flashcards.count {
            setupCurrentCard()
        } else {
            showStudyComplete()
        }
    }
    
    private func showStudyComplete() {
        let alert = UIAlertController(
            title: "Study Session Complete!",
            message: "You've reviewed all \(flashcards.count) cards in this deck.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Study Again", style: .default) { _ in
            self.restartStudySession()
        })
        
        alert.addAction(UIAlertAction(title: "Finish", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func restartStudySession() {
        currentIndex = 0
        setupCurrentCard()
    }
    
    @objc private func closeButtonTapped() {
        let alert = UIAlertController(
            title: "End Study Session",
            message: "Are you sure you want to end this study session?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Continue Studying", style: .cancel))
        alert.addAction(UIAlertAction(title: "End Session", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    @objc private func editTapped() {
        guard currentIndex < flashcards.count else { return }
        let card = flashcards[currentIndex]
        let sheet = EditFlashcardSheetViewController(flashcard: card)
        sheet.onSaved = { [weak self] (updated: Flashcard) in
            guard let self = self else { return }
            self.flashcards[self.currentIndex] = updated
            self.setupCurrentCard()
        }
        sheet.onDeleted = { [weak self] in
            guard let self = self else { return }
            if self.currentIndex < self.flashcards.count {
                self.flashcards.remove(at: self.currentIndex)
                if self.currentIndex >= self.flashcards.count {
                    self.currentIndex = max(0, self.flashcards.count - 1)
                }
            }
            self.setupCurrentCard()
        }
        if #available(iOS 15.0, *), let sheetController = sheet.sheetPresentationController {
            sheetController.detents = [.medium()]
            sheetController.prefersGrabberVisible = true
        }
        present(sheet, animated: true)
    }
}

// MARK: - FlashcardViewDelegate
extension StudyViewController: FlashcardViewDelegate {
    func flashcardDidSwipeLeft(_ flashcardView: FlashcardView) {
        moveToNextCard()
    }
    
    func flashcardDidSwipeRight(_ flashcardView: FlashcardView) {
        moveToNextCard()
    }
} 

// MARK: - Inline Edit Sheet (kept in same file to avoid Xcode project linking issues)
final class EditFlashcardSheetViewController: UIViewController {
    private let questionLabel = UILabel()
    private let questionField = UITextField()
    private let answerLabel = UILabel()
    private let answerField = UITextField()
    private let saveButton = GradientButton()
    private let deleteButton = UIButton(type: .system)
    private let contentStack = UIStackView()
    private let databaseService = DatabaseService.shared
    private var flashcard: Flashcard
    var onSaved: ((Flashcard) -> Void)?
    var onDeleted: (() -> Void)?

    init(flashcard: Flashcard) {
        self.flashcard = flashcard
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        if #available(iOS 15.0, *), let sheet = sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }

        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentStack)

        questionLabel.text = "Question"
        questionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        questionLabel.textColor = .darkGray

        questionField.text = flashcard.question
        questionField.font = UIFont.systemFont(ofSize: 16)
        questionField.borderStyle = .roundedRect

        answerLabel.text = "Answer"
        answerLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        answerLabel.textColor = .darkGray

        answerField.text = flashcard.answer
        answerField.font = UIFont.systemFont(ofSize: 16)
        answerField.borderStyle = .roundedRect

        saveButton.setTitle("Save changes", for: .normal)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(UIColor(red: 255/255, green: 68/255, blue: 68/255, alpha: 1.0), for: .normal)
        deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        contentStack.addArrangedSubview(questionLabel)
        contentStack.addArrangedSubview(questionField)
        contentStack.addArrangedSubview(answerLabel)
        contentStack.addArrangedSubview(answerField)
        contentStack.addArrangedSubview(saveButton)
        contentStack.addArrangedSubview(deleteButton)

        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 20)
        ])
    }

    @objc private func saveTapped() {
        guard let id = flashcard.id else { return }
        let newQuestion = questionField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let newAnswer = answerField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if newQuestion.isEmpty || newAnswer.isEmpty { return }
        Task {
            await databaseService.updateFlashcard(id: id, question: newQuestion, answer: newAnswer)
            let updated = Flashcard(id: id, deckId: flashcard.deckId, question: newQuestion, answer: newAnswer, createdAt: flashcard.createdAt, updatedAt: Date(), lastReviewed: flashcard.lastReviewed)
            DispatchQueue.main.async {
                self.onSaved?(updated)
                self.dismiss(animated: true)
            }
        }
    }

    @objc private func deleteTapped() {
        guard let id = flashcard.id else { return }
        Task {
            await databaseService.deleteFlashcard(id: id)
            DispatchQueue.main.async {
                self.onDeleted?()
                self.dismiss(animated: true)
            }
        }
    }
}