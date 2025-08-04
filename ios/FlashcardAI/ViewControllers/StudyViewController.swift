import UIKit

class StudyViewController: UIViewController {
    
    private let headerView = UIView()
    private let deckNameLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let progressView = UIProgressView()
    private let cardContainerView = UIView()
    
    private var deck: Deck?
    private var flashcards: [Flashcard] = []
    private var currentIndex = 0
    private var currentFlashcardView: FlashcardView?
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
        setupConstraints()
        updateProgress()
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
        
        progressView.progressTintColor = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1.0)
        progressView.trackTintColor = UIColor(red: 225/255, green: 229/255, blue: 233/255, alpha: 1.0)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(deckNameLabel)
        headerView.addSubview(closeButton)
        headerView.addSubview(progressView)
        
        view.addSubview(headerView)
    }
    
    private func setupCardContainer() {
        cardContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardContainerView)
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
            
            progressView.topAnchor.constraint(equalTo: deckNameLabel.bottomAnchor, constant: 16),
            progressView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            progressView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20),
            progressView.heightAnchor.constraint(equalToConstant: 4),
            
            // Card container
            cardContainerView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            cardContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cardContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
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
        updateProgress()
    }
    
    private func updateProgress() {
        let progress = Float(currentIndex) / Float(max(flashcards.count, 1))
        progressView.setProgress(progress, animated: true)
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
}

// MARK: - FlashcardViewDelegate
extension StudyViewController: FlashcardViewDelegate {
    func flashcardDidSwipeLeft(_ flashcardView: FlashcardView) {
        print("Swipe left - moving to next card")
        moveToNextCard()
    }
    
    func flashcardDidSwipeRight(_ flashcardView: FlashcardView) {
        print("Swipe right - moving to next card")
        moveToNextCard()
    }
} 