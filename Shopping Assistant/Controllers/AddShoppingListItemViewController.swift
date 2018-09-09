import UIKit

class AddShoppingListItemViewController: BaseViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var locationSwitch: UISwitch!
    @IBOutlet weak var locationPicker: UIPickerView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!

    public var viewModel: AddShoppingListItemViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self
        viewModel.onViewDidLoad()

        locationPicker.dataSource = self
        locationPicker.delegate = self
        nameField.delegate = self

        nameField.addTarget(self, action: #selector(nameFieldDidChange(sender:)), for: .editingChanged)
        nameField.text = viewModel.item.name.capitalized
        nameField.becomeFirstResponder()

        locationSwitch.isOn = viewModel.item.hasLocation
        locationPicker.alpha = 0
    }

    // MARK: - Actions

    @IBAction func switchToggled() {
        if locationSwitch.isOn {
            viewModel.setLocation(viewModel.locations.first)
            locationPicker.fadeIn(0.5)
        } else {
            viewModel.setLocation(nil)
            locationPicker.fadeOut(0.5)
        }
    }

    @IBAction func saveItem() {
        viewModel.didSaveItem()
    }

    @IBAction func cancelChanges() {
        viewModel.didCancelChanges()
    }
}

// MARK: - UITextFieldDelegate
extension AddShoppingListItemViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let name = textField.text else { return }
        viewModel.setName(name)
    }

    @objc func nameFieldDidChange(sender: UITextField) {
        guard let name = sender.text else { return }
        viewModel.setName(name)
    }
}

// MARK: - UIPickerViewDataSource
extension AddShoppingListItemViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.locations.count
    }
}

// MARK: - UIPickerViewDelegate
extension AddShoppingListItemViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let location = viewModel.locations[row]
        return location.name
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let location = viewModel.locations[row]
        viewModel.setLocation(location)
    }
}

// MARK: - AddShoppingListItemViewModelDelegate
extension AddShoppingListItemViewController: AddShoppingListItemViewModelDelegate {
    func didSaveItem() {
        navigationController?.popViewController(animated: true)
    }

    func didCancelChanges() {
        navigationController?.popViewController(animated: true)
    }

    func didLoadLocations() {
        locationPicker.reloadAllComponents()

        if let row = viewModel.locations.map({ $0.id }).index(of: viewModel.item.locationId) {
            locationPicker.selectRow(row, inComponent: 0, animated: false)
        }

        if locationSwitch.isOn {
            locationPicker.fadeIn(0.5)
        }
    }
}

// MARK: - ActivityIndicatable
extension AddShoppingListItemViewController: ActivityIndicatable {}

// MARK: - ErrorPresentable
extension AddShoppingListItemViewController: ErrorPresentable {}
