import Combine
import GRDBCombine
import SwiftUI

/// A view controller that uses a @DatabasePublished property wrapper, and
/// feeds both HallOfFameViewController, and the SwiftUI HallOfFameView.
class HallOfFameViewModel {
    /// @DatabasePublished automatically updates the hallOfFame
    /// property whenever the database changes.
    ///
    /// The property is a Result because database access may
    /// eventually fail.
    @DatabasePublished(HallOfFame.current, in: Current.database())
    private var hallOfFame: Result<HallOfFame, Error>

    // MARK: - Publishers
    
    /// A publisher for the title of the Hall of Fame
    var titlePublisher: AnyPublisher<String, Never> {
        return $hallOfFame
            .playerCount
            .map(Self.title)
            .replaceError(with: Self.errorTitle)
            .eraseToAnyPublisher()
    }

    /// A publisher for the best players
    var bestPlayersPublisher: AnyPublisher<[Player], Never> {
        $hallOfFame
            .bestPlayers
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    // MARK: - Current Values
    
    /// The title of the Hall of Fame
    var title: String {
        do {
            return try Self.title(hallOfFame.get().playerCount)
        } catch {
            return Self.errorTitle
        }
    }

    /// The best players
    var bestPlayers: [Player] {
        do {
            return try hallOfFame.get().bestPlayers
        } catch {
            return []
        }
    }
    
    // MARK: - Helpers
    
    private static let errorTitle = "An error occured"
    private static func title(_ playerCount: Int) -> String { "Best of \(playerCount) players" }
}

// MARK: - SwiftUI Support

extension HallOfFameViewModel: BindableObject {
    var didChange: DatabasePublished<HallOfFame> { $hallOfFame }
}
