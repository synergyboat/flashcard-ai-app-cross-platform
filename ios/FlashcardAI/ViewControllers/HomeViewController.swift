import UIKit

class HomeViewController: UIViewController {
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 100, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(red: 254/255, green: 248/255, blue: 255/255, alpha: 1.0)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "folder.badge.questionmark")
        imageView.tintColor = UIColor(white: 0.8, alpha: 1.0)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyStateTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to Flashcard AI!"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emptyStateSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap the AI button below to generate your first deck of flashcards"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1.0)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let aiButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1.0)
        button.setImage(UIImage(systemName: "sparkles"), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var decks: [Deck] = []
    private let databaseService = DatabaseService.shared
    
    // Animation state
    private var isShakingMode = false
    private var shakingCells: Set<IndexPath> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        loadDecks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDecks()
    }
    
    private func setupUI() {
        title = AppConfig.ScreenTitles.home
        view.backgroundColor = UIColor(red: 254/255, green: 248/255, blue: 255/255, alpha: 1.0)
        
        view.addSubview(collectionView)
        view.addSubview(emptyStateView)
        view.addSubview(aiButton)
        
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateTitleLabel)
        emptyStateView.addSubview(emptyStateSubtitleLabel)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            emptyStateView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            emptyStateView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40),
            
            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 64),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 64),
            
            emptyStateTitleLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 16),
            emptyStateTitleLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateTitleLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            
            emptyStateSubtitleLabel.topAnchor.constraint(equalTo: emptyStateTitleLabel.bottomAnchor, constant: 8),
            emptyStateSubtitleLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateSubtitleLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyStateSubtitleLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor),
            
            aiButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            aiButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            aiButton.widthAnchor.constraint(equalToConstant: 56),
            aiButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        aiButton.addTarget(self, action: #selector(aiButtonTapped), for: .touchUpInside)
        

    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DeckCollectionViewCell.self, forCellWithReuseIdentifier: DeckCollectionViewCell.identifier)
        
        // Add long press gesture
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.5
        collectionView.addGestureRecognizer(longPressGesture)
        
        // Add tap gesture to exit shaking mode
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func loadDecks() {
        Task {
            decks = await databaseService.getDecks()
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.updateEmptyState()
            }
        }
    }
    
    private func updateEmptyState() {
        emptyStateView.isHidden = !decks.isEmpty
    }
    
    @objc private func aiButtonTapped() {
        let aiGenerateVC = AIGenerateViewController()
        navigationController?.pushViewController(aiGenerateVC, animated: true)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let point = gesture.location(in: collectionView)
        if collectionView.indexPathForItem(at: point) != nil {
            startShakingMode()
        }
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        if isShakingMode {
            stopShakingMode()
        }
    }
    
    private func startShakingMode() {
        guard !isShakingMode else { return }
        isShakingMode = true
        
        // Start shaking all visible cells
        for cell in collectionView.visibleCells {
            if let deckCell = cell as? DeckCollectionViewCell {
                deckCell.startShaking()
            }
        }
    }
    
    private func stopShakingMode() {
        guard isShakingMode else { return }
        isShakingMode = false
        
        // Stop shaking all cells
        for cell in collectionView.visibleCells {
            if let deckCell = cell as? DeckCollectionViewCell {
                deckCell.stopShaking()
            }
        }
    }
    
    private func showEditDeckModal(for indexPath: IndexPath) {
        let deck = decks[indexPath.item]
        
        let alert = UIAlertController(title: "Edit Deck", message: "Edit deck name and description", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = deck.name
            textField.placeholder = "Deck Name"
        }
        
        alert.addTextField { textField in
            textField.text = deck.description
            textField.placeholder = "Description (optional)"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let nameField = alert.textFields?[0],
                  let descriptionField = alert.textFields?[1],
                  let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !name.isEmpty else {
                return
            }
            
            let description = descriptionField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let updatedDeck = Deck(id: deck.id, name: name, description: description, flashcardCount: deck.flashcardCount)
            
            Task {
                await self?.databaseService.updateDeck(updatedDeck)
                DispatchQueue.main.async {
                    self?.decks[indexPath.item] = updatedDeck
                    self?.collectionView.reloadItems(at: [indexPath])
                }
            }
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.confirmDeleteDeck(at: indexPath)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(saveAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true)
    }
    
    private func confirmDeleteDeck(at indexPath: IndexPath) {
        let deck = decks[indexPath.item]
        let alert = UIAlertController(title: "Confirm Deletion", message: "This action cannot be undone.\n\nAre you sure you want to delete this deck?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let deckId = deck.id else { return }
            
            Task {
                await self?.databaseService.deleteDeck(id: deckId)
                DispatchQueue.main.async {
                    self?.decks.remove(at: indexPath.item)
                    self?.collectionView.deleteItems(at: [indexPath])
                    self?.updateEmptyState()
                    self?.stopShakingMode()
                }
            }
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(deleteAction)
        
        present(alert, animated: true)
    }

}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return decks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DeckCollectionViewCell.identifier, for: indexPath) as? DeckCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: decks[indexPath.item])
        
        // Apply shaking state if in shaking mode
        if isShakingMode {
            cell.startShaking()
        } else {
            cell.stopShaking()
        }
        
        // Set edit button callback
        cell.onEditTapped = { [weak self] in
            self?.showEditDeckModal(for: indexPath)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Don't navigate if in shaking mode
        guard !isShakingMode else { return }
        
        let deck = decks[indexPath.item]
        // Directly start study session to match Flutter UX
        Task {
            if let deckId = deck.id {
                let flashcards = await databaseService.getFlashcards(deckId: deckId)
                DispatchQueue.main.async {
                    if flashcards.isEmpty {
                        let alert = UIAlertController(title: "No Cards", message: "This deck has no flashcards to study.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                        return
                    }
                    let studyVC = StudyViewController()
                    studyVC.configure(with: deck, flashcards: flashcards)
                    self.navigationController?.pushViewController(studyVC, animated: true)
                }
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 48 // 16 * 3 (left + right + middle)
        let availableWidth = collectionView.bounds.width - padding
        let itemWidth = availableWidth / 2
        return CGSize(width: itemWidth, height: 120)
    }
} 