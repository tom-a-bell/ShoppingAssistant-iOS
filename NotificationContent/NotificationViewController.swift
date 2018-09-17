import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tableSeparator: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    private var items: [NotificationItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableSeparator()
        tableView.dataSource = self
    }

    private func setupTableSeparator() {
        tableSeparator.backgroundColor = tableView.separatorColor
        tableSeparator.frame.size.height = 1 / UIScreen.main.scale
    }
}

extension NotificationViewController:UNNotificationContentExtension {
    func didReceive(_ notification: UNNotification) {
        locationLabel.text = notification.request.content.title

        items = getItems(from: notification)

        tableView.reloadData()
        tableHeight.constant = CGFloat(items.count * 40)
    }

    private func getItems(from notification: UNNotification) -> [NotificationItem] {
        return notification.request.content.userInfo.values
            .compactMap { NotificationItem(from: $0) }
            .sorted(by: { $0.lastUpdated > $1.lastUpdated })
    }
}

extension NotificationViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationItemCell", for: indexPath)

        let item = items[indexPath.row]
        cell.textLabel?.text = item.name.capitalized
        cell.accessoryType = .none

        return cell
    }
}
