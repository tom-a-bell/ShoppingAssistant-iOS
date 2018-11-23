import UIKit

class ShoppingListViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!

    private let viewModel = ShoppingListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        viewModel.delegate = self
        viewModel.onViewDidLoad()

        navigationItem.rightBarButtonItem = editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.onViewWillAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.onViewWillDisappear()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(!tableView.isEditing, animated: true)
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
        cell.detailTextLabel?.text = item.location?.name
        cell.accessoryType = item.isCompleted ? .checkmark : .none

        cell.editingAccessoryType = .none
        cell.selectionStyle = .none

        return cell
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

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let item = viewModel.items[indexPath.row]
        if editingStyle == .delete {
            viewModel.didRemove(item)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = viewModel.items[sourceIndexPath.row]
        viewModel.didMove(item, to: destinationIndexPath.row)
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let completeAction = self.contextualToggleDoneAction(forRowAtIndexPath: indexPath)
        return UISwipeActionsConfiguration(actions: [completeAction])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        viewModel.didEndEditing()
    }

    private func contextualToggleDoneAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        var item = viewModel.items[indexPath.row]
        let title = item.isCompleted ? "Undo" : "Done"
        let action = UIContextualAction(style: .normal, title: title) { (_: UIContextualAction, _: UIView, completionHandler: (Bool) -> Void) in
            item.toggleStatus()
            self.viewModel.didUpdate(item)
            self.tableView.reloadRows(at: [indexPath], with: .none)
            completionHandler(true)
        }

        action.image = UIImage(named: "Checkmark")
        action.backgroundColor = item.isCompleted ? UIColor.gray : UIColor.purple
        return action
    }

    private func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let item = viewModel.items[indexPath.row]
        return UIContextualAction(style: .destructive, title: "Delete") { (_: UIContextualAction, _: UIView, completionHandler: (Bool) -> Void) in
            self.viewModel.didRemove(item)
            self.tableView.deleteRows(at: [indexPath], with: .left)
            completionHandler(true)
        }
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
