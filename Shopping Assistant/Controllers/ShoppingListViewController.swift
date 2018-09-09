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
        viewModel.didSelectItem(item)

        performSegue(withIdentifier: "AddItem", sender: self)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        viewModel.didDeselectItem()
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedItem = viewModel.items[sourceIndexPath.row]
        viewModel.items.remove(at: sourceIndexPath.row)
        viewModel.items.insert(movedItem, at: destinationIndexPath.row)
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
        let action = UIContextualAction(style: .normal, title: title)
        { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            item.toggleStatus()
            self.viewModel.items[indexPath.row] = item
            self.tableView.reloadRows(at: [indexPath], with: .none)
            completionHandler(true)
        }

        action.image = UIImage(named: "Checkmark")
        action.backgroundColor = item.isCompleted ? UIColor.gray : UIColor.purple
        return action
    }

    private func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        return UIContextualAction(style: .destructive, title: "Delete")
        { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            self.viewModel.items.remove(at: indexPath.row)
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

    func showErrorMessage(_ message: String) {
        let errorAlert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default)

        errorAlert.addAction(dismissAction)

        self.present(errorAlert, animated: true, completion: nil)
    }
}

// MARK: - ActivityIndicatable
extension ShoppingListViewController: ActivityIndicatable {}
