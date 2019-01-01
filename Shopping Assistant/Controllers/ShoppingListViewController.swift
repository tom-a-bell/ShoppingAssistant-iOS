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
        return viewModel.completedItems.isEmpty ? 1 : 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return viewModel.activeItems.count
        case 1:
            return viewModel.completedItems.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return CGFloat.leastNonzeroMagnitude
        default:
            return 30
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Completed"
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingListItemCell", for: indexPath)

        let item = itemForRowAt(indexPath)
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

    private func itemForRowAt(_ indexPath: IndexPath) -> ShoppingListItem {
        switch indexPath.section {
        case 0:
            return viewModel.activeItems[indexPath.row]
        case 1:
            return viewModel.completedItems[indexPath.row]
        default:
            return viewModel.items[indexPath.row]
        }
    }
}

// MARK: - UITableViewDelegate
extension ShoppingListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = itemForRowAt(indexPath)
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

    private func contextualToggleDoneAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        var item = itemForRowAt(indexPath)
        let handler: UIContextualAction.Handler = { action, view, completionHandler in
            item.toggleStatus()
            self.viewModel.didUpdate(item)
            completionHandler(true)
        }

        let image = UIImage(named: "Actions/Checkmark")
        let title = item.isCompleted ? "Undo" : "Done"
        let color = item.isCompleted ? .gray : UIColor.init(hexString: "1C7492")

        return UIContextualAction(withHandler: handler, style: .normal, title: title, image: image, backgroundColor: color)
    }

    private func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let item = itemForRowAt(indexPath)
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

    func didUpdateItems() {
        let sections = viewModel.completedItems.isEmpty ? [0] : [0, 1]
        tableView.reloadSections(IndexSet(sections), with: .fade)
    }

    func didUpdate(_ item: ShoppingListItem) {
        tableView.reloadData()
        viewModel.didInsert(item)
//        let section = item.isCompleted ? 1 : 0
//        tableView.reloadSections(IndexSet([section]), with: .fade)
        let indexPath = item.isCompleted ? IndexPath(row: 0, section: 0) : IndexPath(row: 0, section: 1)
        tableView.insertRows(at: [indexPath], with: .bottom)
    }
}

// MARK: - ActivityIndicatable
extension ShoppingListViewController: ActivityIndicatable {}

// MARK: - ErrorPresentable
extension ShoppingListViewController: ErrorPresentable {}
