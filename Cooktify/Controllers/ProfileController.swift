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
        
        // Fetch more items to ensure we can filter to unique by recipe id while preserving most-recent-first order
        let rawItems = db.fetchRecentlyViewedItems(limit: 200)
        
        // Sort descending by viewedAt to ensure most recent first (in case DB doesn't already)
        let sorted = rawItems.sorted { $0.viewedAt > $1.viewedAt }
        
        // Filter to unique recipes, keeping the first (most recent) occurrence of each recipe.id
        var seen = Set<Int>()
        var uniques: [RecipeDatabase.RecentlyViewedItem] = []
        for item in sorted {
            let id = item.recipe.id
            if !seen.contains(id) {
                seen.insert(id)
                uniques.append(item)
            }
        }
        
        // Limit to top 10 unique items
        let topUnique = uniques.prefix(10)
        recentlyViewedItems = Array(topUnique)
        
        // Update the count label to reflect unique count (matches the list meaning)
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
