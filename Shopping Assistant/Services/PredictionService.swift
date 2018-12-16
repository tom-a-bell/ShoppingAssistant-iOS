import Foundation
import NaturalLanguage

class PredictionService {

    static let shared = PredictionService()

    func predictedLocation(for item: ShoppingListItem) -> String? {
        guard #available(iOS 12.0, *) else { return nil }

        let locationPredictor = try? NLModel(mlModel: LocationClassifier().model)
        return locationPredictor?.predictedLabel(for: item.name.lowercased())
    }
}
