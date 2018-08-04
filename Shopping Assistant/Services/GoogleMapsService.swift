import Foundation
import GoogleMaps
import Promises
import Moya

class GoogleMapsService {

    static let shared = GoogleMapsService()

    private let placesProvider = MoyaProvider<GooglePlacesService>()

    func initialize() {
        GMSServices.provideAPIKey(GoogleConfiguration.apiKey)
    }

    func getNearbyPlaces(coordinate: CLLocationCoordinate2D, radius: Double, types: [String]) -> Promise<[GooglePlace]> {
        let getNearbyPlaces = GooglePlacesService.getNearbyPlaces(coordinate: coordinate, radius: radius, types: types, apiKey: GoogleConfiguration.apiKey)
        return Promise<[GooglePlace]> { fulfill, reject in
            self.placesProvider.request(getNearbyPlaces) { result in
                switch result {
                case let .success(response):
                    do {
                        let successResponse = try response.filterSuccessfulStatusCodes()
                        let placesResponse = try self.convertToPlacesResponse(successResponse)
                        fulfill(placesResponse.results)
                    }
                    catch {
                        let responseError = self.createResponseError(response)
                        reject(responseError)
                    }
                case let .failure(error):
                    reject(error)
                }
            }
        }
    }

    private func convertToPlacesResponse(_ response: Response) throws -> GooglePlacesResponse {
        return try response.map(GooglePlacesResponse.self)
    }

    private func createResponseError(_ response: Response) -> ResponseError {
        let errorResponse = try? response.map(ErrorResponse.self)
        let errorMessage = errorResponse?.Message ?? errorResponse?.message ?? "Unknown error"
        return ResponseError(statusCode: response.statusCode, message: errorMessage)
    }

    private struct ErrorResponse: Decodable {
        let Message: String?
        let message: String?
        let type: String?
    }
}