import UIKit

struct MiniTodoItem: Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var isDone: Bool
    var reminderTime: Date?
}

final class MiniTodoViewController: UIViewController {
    
    
    private var items: [MiniTodoItem] = [] {
        didSet { save() }
    }


    @IBOutlet weak var tableView: UITableView!
    private let storageKey = "MiniTodoItems"
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Mini To‑Do"
        
        setupNavBar()
        load()
        
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
    }

    @objc private func backTapped() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - Persistence
    private func save() {
        let data = try? JSONEncoder().encode(items)
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([MiniTodoItem].self, from: data) else { return }
        items = decoded
    }

    // MARK: - Actions
    @objc private func addTapped() {
        presentEditAlert(title: "Thêm việc cần làm", placeholder: "Nhập nội dung...", initialText: nil, initialDate: nil) { [weak self] text, date in
            guard let self = self, let text = text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
            self.items.insert(MiniTodoItem(title: text, isDone: false, reminderTime: date), at: 0)
            self.tableView.reloadData()
        }
    }

    private func presentEditAlert(title: String, placeholder: String, initialText: String?, initialDate: Date?, completion: @escaping (String?, Date?) -> Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        alert.addTextField { tf in
            tf.placeholder = placeholder
            tf.text = initialText
        }
        
        let datePickerVC = UIViewController()
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .wheels
        
        if let initialDate = initialDate {
            datePicker.date = initialDate
        }
        
        datePickerVC.view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: datePickerVC.view.topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: datePickerVC.view.bottomAnchor),
            datePicker.leadingAnchor.constraint(equalTo: datePickerVC.view.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: datePickerVC.view.trailingAnchor)
        ])
        
        datePickerVC.preferredContentSize = CGSize(width: 270, height: 120)
        alert.setValue(datePickerVC, forKey: "contentViewController")
        
        alert.addAction(UIAlertAction(title: "Huỷ", style: .cancel))
        alert.addAction(UIAlertAction(title: "Lưu", style: .default, handler: { _ in
            let text = alert.textFields?.first?.text
            let selectedTime = datePicker.date
            completion(text, selectedTime)
        }))
        
        present(alert, animated: true)
    }
}

extension MiniTodoViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Nạp Cell từ Storyboard
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        let item = items[indexPath.row]
        
        config.text = item.title
        
        var statusText = item.isDone ? "Đã xong" : "Chưa xong"
        if let time = item.reminderTime {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            statusText += " - \(formatter.string(from: time))"
        }
        config.secondaryText = statusText
        
        cell.contentConfiguration = config
        cell.accessoryType = item.isDone ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        items[indexPath.row].isDone.toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Xoá") { [weak self] _, _, completion in
            guard let self = self else { return }
            self.items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Sửa") { [weak self] _, _, completion in
            guard let self = self else { return }
            let currentItem = self.items[indexPath.row]
            
            self.presentEditAlert(title: "Sửa nội dung", placeholder: "Nhập nội dung...", initialText: currentItem.title, initialDate: currentItem.reminderTime) { text, date in
                if let text = text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    self.items[indexPath.row].title = text
                    self.items[indexPath.row].reminderTime = date
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
            completion(true)
        }
        editAction.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [editAction])
    }
}
