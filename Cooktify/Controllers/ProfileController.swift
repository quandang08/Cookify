import UIKit

private let recentlyCellReuseIdentifier = "RecentlyCell"

final class ProfileController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recentlyCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    
    private var refreshControl = UIRefreshControl()

    private var recentlyViewedItems: [RecipeDatabase.RecentlyViewedItem] = []
    private let db = RecipeDatabase.shared
    private let relativeFormatter: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .full
        return f
    }()
    @objc func openTodoScreenTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // PHẢI DÙNG LỆNH NÀY ĐỂ GỌI MÀN HÌNH TỪ STORYBOARD
        if let todoVC = storyboard.instantiateViewController(withIdentifier: "MiniTodoViewController") as? MiniTodoViewController {
            
            if let navigationController = self.navigationController {
                navigationController.pushViewController(todoVC, animated: true)
            } else {
                let navVC = UINavigationController(rootViewController: todoVC)
                navVC.modalPresentationStyle = .pageSheet
                present(navVC, animated: true)
            }
        } else {
            print("Không tìm thấy màn hình có ID là MiniTodoViewController trong Storyboard!")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        setupTable()
        tableView.isScrollEnabled = true
        loadData()
        
        favoriteCountLabel.isUserInteractionEnabled = true
        let favTap = UITapGestureRecognizer(target: self, action: #selector(favoriteCountTapped))
        favoriteCountLabel.addGestureRecognizer(favTap)
        
        // Enable pull-to-refresh
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        // Listen for database changes to update counts and list live
        NotificationCenter.default.addObserver(self, selector: #selector(handleDataDidChange), name: Notification.Name("RecipeDatabaseDidChange"), object: nil)
        let todoButton = UIBarButtonItem(image: UIImage(systemName: "list.bullet.clipboard"), style: .plain, target: self, action: #selector(openTodoScreenTapped))
                self.navigationItem.rightBarButtonItem = todoButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh data whenever the profile appears
        loadData()
    }
    
    @objc private func favoriteCountTapped() {
        if let tabBar = self.tabBarController, tabBar.viewControllers?.indices.contains(1) == true {
            tabBar.selectedIndex = 1
        }
    }
    
    @objc private func handleRefresh() {
        loadData()
        DispatchQueue.main.async { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    @objc private func handleDataDidChange() {
        loadData()
    }

    private func setupTable() {
        assert(tableView != nil, "tableView outlet is nil. Connect the IBOutlet in storyboard.")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 72
        // Allow dynamic scrolling and automatic row height if needed
        tableView.estimatedRowHeight = 72
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: recentlyCellReuseIdentifier)
        print("Registered cell identifier: \(recentlyCellReuseIdentifier)")
    }

    private func loadData() {
        favoriteCountLabel.text = "\(db.countFavoriteRecipes())"
        
        let rawItems = db.fetchRecentlyViewedItems(limit: 200)
        
        let sorted = rawItems.sorted { $0.viewedAt > $1.viewedAt }
        

        var seen = Set<Int>()
        var uniques: [RecipeDatabase.RecentlyViewedItem] = []
        for item in sorted {
            let id = item.recipe.id
            if !seen.contains(id) {
                seen.insert(id)
                uniques.append(item)
            }
        }
        
        let topUnique = uniques.prefix(10)
        recentlyViewedItems = Array(topUnique)

        recentlyCountLabel.text = "\(uniques.count)"
        
        tableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("RecipeDatabaseDidChange"), object: nil)
    }
}

extension ProfileController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        recentlyViewedItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = recentlyViewedItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: recentlyCellReuseIdentifier, for: indexPath)

        var config = cell.defaultContentConfiguration()
        config.text = item.recipe.name
        let relative = relativeFormatter.localizedString(for: item.viewedAt, relativeTo: Date())
        config.secondaryText = relative
        if let img = ImageStorageManager.shared.loadImage(named: item.recipe.image) {
            config.image = img
        } else {
            config.image = UIImage(systemName: "photo")
        }
        config.imageProperties.cornerRadius = 8
        cell.contentConfiguration = config
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = recentlyViewedItems[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "RecipeDetailController") as? RecipeDetailController {
            detailVC.recipeId = item.recipe.id
            if let navigationController = self.navigationController {
                navigationController.pushViewController(detailVC, animated: true)
            } else if let tabNav = self.tabBarController?.selectedViewController as? UINavigationController {
                tabNav.pushViewController(detailVC, animated: true)
            } else {
                let nav = UINavigationController(rootViewController: detailVC)
                nav.modalPresentationStyle = .fullScreen
                present(nav, animated: true)
            }
        }
    }
}
