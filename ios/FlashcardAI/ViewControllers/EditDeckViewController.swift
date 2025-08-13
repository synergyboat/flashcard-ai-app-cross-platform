import UIKit

class EditDeckViewController: UIViewController {
    
    private var deck: Deck
    
    // Callbacks
    var onDeckUpdated: ((Deck) -> Void)?
    var onDeckDeleted: (() -> Void)?
    
    // UI Elements
    private let handleBar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        view.layer.cornerRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Edit Deck"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let nameFieldLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(red: 225/255, green: 229/255, blue: 233/255, alpha: 1.0).cgColor
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let descriptionFieldLabel: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(red: 225/255, green: 229/255, blue: 233/255, alpha: 1.0).cgColor
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let saveButton = GradientButton()
    
    private let databaseService = DatabaseService.shared
    
    init(deck: Deck) {
        self.deck = deck
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateFields()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(handleBar)
        view.addSubview(titleLabel)
        view.addSubview(deleteButton)
        view.addSubview(nameFieldLabel)
        view.addSubview(nameTextField)
        view.addSubview(descriptionFieldLabel)
        view.addSubview(descriptionTextField)
        view.addSubview(saveButton)
        
        // Configure save button
        saveButton.setTitle("Save changes", for: .normal)
        saveButton.layer.cornerRadius = 25
        saveButton.gradientLayer.cornerRadius = 25
        saveButton.layer.shadowColor = UIColor.systemBlue.withAlphaComponent(0.8).cgColor
        saveButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        saveButton.layer.shadowOpacity = 0.3
        saveButton.layer.shadowRadius = 8
        saveButton.layer.masksToBounds = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add checkmark icon to save button
        if let checkImage = UIImage(systemName: "checkmark") {
            saveButton.setImage(checkImage, for: .normal)
            saveButton.imageView?.tintColor = .white
            saveButton.semanticContentAttribute = .forceLeftToRight
        }
        
        NSLayoutConstraint.activate([
            handleBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            handleBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            handleBar.widthAnchor.constraint(equalToConstant: 40),
            handleBar.heightAnchor.constraint(equalToConstant: 4),
            
            titleLabel.topAnchor.constraint(equalTo: handleBar.bottomAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            deleteButton.topAnchor.constraint(equalTo: handleBar.bottomAnchor, constant: 16),
            deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            nameFieldLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            nameFieldLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameFieldLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            nameTextField.topAnchor.constraint(equalTo: nameFieldLabel.bottomAnchor, constant: 8),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 48),
            
            descriptionFieldLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            descriptionFieldLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionFieldLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            descriptionTextField.topAnchor.constraint(equalTo: descriptionFieldLabel.bottomAnchor, constant: 8),
            descriptionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            descriptionTextField.heightAnchor.constraint(equalToConstant: 48),
            
            saveButton.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor, constant: 32),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Add targets
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func populateFields() {
        nameTextField.text = deck.name
        descriptionTextField.text = deck.description
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func deleteButtonTapped() {
        let alert = UIAlertController(title: "Confirm Deletion", message: nil, preferredStyle: .alert)
        
        // Add warning container
        let warningMessage = "This action cannot be undone.\n\nAre you sure you want to delete this Deck?"
        alert.message = warningMessage
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive) { [weak self] _ in
            self?.deleteDeck()
        })
        
        present(alert, animated: true)
    }
    
    @objc private func saveButtonTapped() {
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty else {
            showAlert(title: "Error", message: "Please enter a deck name")
            return
        }
        
        let description = descriptionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // Update deck
        deck = Deck(
            id: deck.id,
            name: name,
            description: description,
            flashcardCount: deck.flashcardCount
        )
        
        Task {
            await databaseService.updateDeck(deck)
            
            DispatchQueue.main.async {
                self.onDeckUpdated?(self.deck)
                self.dismiss(animated: true)
            }
        }
    }
    
    private func deleteDeck() {
        Task {
            if let deckId = deck.id {
                await databaseService.deleteDeck(id: deckId)
                
                DispatchQueue.main.async {
                    self.onDeckDeleted?()
                    self.dismiss(animated: true)
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