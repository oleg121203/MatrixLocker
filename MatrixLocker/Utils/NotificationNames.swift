import Foundation

extension Notification.Name {
    /// Сповіщення, що надсилається, коли користувач був неактивним протягом заданого часу.
    static let userIsInactive = Notification.Name("userIsInactive")

    /// Сповіщення, що надсилається для ручного запуску блокування екрана.
    static let lockScreen = Notification.Name("lockScreen")

    /// Сповіщення, що надсилається після успішного розблокування екрана.
    static let didUnlock = Notification.Name("didUnlock")
}
