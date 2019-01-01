import UIKit

class ShoppingListViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!

    private let viewModel = ShoppingListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        viewModel.delegate = self
        viewModel.onViewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.onViewWillAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.onViewWillDisappear()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? AddShoppingListItemViewController else { return }

        let item = viewModel.selectedItem ?? ShoppingListItem.newItem()
        destination.viewModel = AddShoppingListItemViewModel(withItem: item)
    }

    // MARK: - Actions

    @IBAction func addItem() {
        viewModel.didDeselectItem()
        performSegue(withIdentifier: "AddItem", sender: self)
    }
}

// MARK: - UITableViewDataSource
extension ShoppingListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingListItemCell", for: indexPath)

        let item = viewModel.items[indexPath.row]
        cell.textLabel?.text = item.name.capitalized
        cell.accessoryType = item.isCompleted ? .checkmark : .none

        if let location = item.location {
            cell.detailTextLabel?.text = location.name
        } else if let suggestedLocation = PredictionService.shared.predictedLocation(for: item) {
            cell.detailTextLabel?.attributedText = suggestedLocationLabel(for: suggestedLocation)
        }

        cell.editingAccessoryType = .none
        cell.selectionStyle = .none

        return cell
    }

    private func suggestedLocationLabel(for suggestedLocation: String) -> NSAttributedString {
        let labelText = "Suggested: \(suggestedLocation)"
        let labelAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        return NSAttributedString(string: labelText, attributes: labelAttributes)
    }
}

// MARK: - UITableViewDelegate
extension ShoppingListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.items[indexPath.row]
        viewModel.didSelect(item)

        performSegue(withIdentifier: "AddItem", sender: self)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        viewModel.didDeselectItem()
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let completeAction = contextualToggleDoneAction(forRowAtIndexPath: indexPath)
        return UISwipeActionsConfiguration(actions: [completeAction])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = contextualDeleteAction(forRowAtIndexPath: indexPath)
        let snoozeAction = contextualSnoozeAction(forRowAtIndexPath: indexPath)
        return UISwipeActionsConfiguration(actions: [deleteAction, snoozeAction])
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        viewModel.didEndEditing()
    }

    private func contextualToggleDoneAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        var item = viewModel.items[indexPath.row]
        let handler: UIContextualAction.Handler = { action, view, completionHandler in
            item.toggleStatus()
            self.viewModel.didUpdate(item)
            self.tableView.reloadRows(at: [indexPath], with: .none)
            completionHandler(true)
        }

        let image = UIImage(named: "Actions/Checkmark")
        let title = item.isCompleted ? "Undo" : "Done"
        let color = item.isCompleted ? .gray : UIColor.init(hexString: "1C7492")

        return UIContextualAction(withHandler: handler, style: .normal, title: title, image: image, backgroundColor: color)
    }

    private func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let item = viewModel.items[indexPath.row]
        let handler: UIContextualAction.Handler = { action, view, completionHandler in
            self.viewModel.didRemove(item)
            self.tableView.deleteRows(at: [indexPath], with: .left)
            completionHandler(true)
        }

        let image = UIImage(named: "Actions/Trash")
        return UIContextualAction(withHandler: handler, style: .destructive, title: "Delete", image: image, backgroundColor: .red)
    }

    private func contextualSnoozeAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let handler: UIContextualAction.Handler = { action, view, completionHandler in
            completionHandler(true)
        }

        let image = UIImage(named: "Actions/Alarm")
        return UIContextualAction(withHandler: handler, style: .normal, title: "Snooze", image: image, backgroundColor: .orange)
    }
}

// MARK: - ShoppingListViewModelDelegate
extension ShoppingListViewController: ShoppingListViewModelDelegate {
    func didLoadItems() {
        tableView.reloadData()
    }
}

// MARK: - ActivityIndicatable
extension ShoppingListViewController: ActivityIndicatable {}

// MARK: - ErrorPresentable
extension ShoppingListViewController: ErrorPresentable {}
