//
//  MockBrokerStore.swift
//  InvestFlow
//
//  Created by Stephano Portella on 28/08/2026.
//

import Foundation
import FinCore

/// "Broker" en memoria que respalda los repositorios mock (entorno `.development`).
///
/// Antes de que existiera, `OrderRepository` y `PortfolioRepository` devolvían
/// constantes fijas: colocar una orden no tenía ningún efecto sobre el portafolio
/// ni el cash. `MockBrokerStore` es la única fuente de verdad que comparten ambos
/// repos mock — un singleton `actor` con estado mutable, el mismo patrón que `CacheLayer`.
///
/// Alcance: el estado vive solo mientras corre el proceso de la app. No hay disco ni
/// backend detrás, así que relanzar la app reinicia todo a los valores semilla de
/// abajo. Dentro de una misma sesión, las compras/ventas se reflejan por completo.
public actor MockBrokerStore {

    /// Instancia compartida conectada a `OrderRepository` / `PortfolioRepository`
    /// vía `AppCompositionRoot`. Los tests construyen sus propias instancias.
    public static let shared = MockBrokerStore()

    private(set) var cashBalance: Decimal
    private(set) var positions: [Position]
    private(set) var orders: [Order]
    private(set) var transactions: [Transaction]

    public init(
        cashBalance: Decimal = MockBrokerStore.seedCashBalance,
        positions: [Position] = MockBrokerStore.seedPositions,
        orders: [Order] = MockBrokerStore.seedOrders,
        transactions: [Transaction] = MockBrokerStore.seedTransactions
    ) {
        self.cashBalance = cashBalance
        self.positions = positions
        self.orders = orders
        self.transactions = transactions
    }

    // MARK: - Lecturas

    public func currentPortfolio(for userID: String) -> Portfolio {
        Portfolio(
            userID:      userID,
            positions:   positions,
            cashBalance: cashBalance,
            currency:    .usd,
            updatedAt:   Date()
        )
    }

    public func currentPositions() -> [Position] { positions }
    public func currentCashBalance() -> Decimal { cashBalance }
    public func currentOrders() -> [Order] { orders }
    public func currentTransactions() -> [Transaction] { transactions }

    // MARK: - Escrituras

    /// Aplica una orden colocada al portafolio mock y devuelve el `Order` resultante.
    ///
    /// Semántica:
    /// - Las órdenes **market** se ejecutan de inmediato a `fillPrice`: el cash se mueve
    ///   (`- precio·cant` en compra, `+ precio·cant` en venta), la posición se
    ///   crea / promedia al alza / reduce / elimina, y se anteponen al historial los
    ///   registros `Order` + `Transaction` correspondientes.
    /// - Las órdenes **límite / stop** se registran como `.pending` sin impacto en cash,
    ///   posición ni transacciones — en la demo nada las ejecuta.
    /// - Agregar a una posición existente mezcla el costo base con un
    ///   promedio ponderado por cantidad:
    ///   `nuevoProm = (cantVieja·promViejo + cantCompra·fillPrice) / (cantVieja + cantCompra)`.
    /// - Vender más unidades de las que se tienen lanza `IFError.validationFailed`.
    public func applyOrder(_ request: OrderRequest, fillPrice: Decimal) throws -> Order {
        guard request.quantity > .zero else {
            throw IFError.validationFailed("La cantidad debe ser mayor a cero.")
        }

        let isMarket = request.type == .market
        let now = Date()

        if isMarket {
            try applyFill(side: request.side,
                          instrumentID: request.instrumentID,
                          quantity: request.quantity,
                          fillPrice: fillPrice)
        }

        let order = Order(
            id:               UUID().uuidString,
            instrumentID:     request.instrumentID,
            side:             request.side,
            type:             request.type,
            quantity:         request.quantity,
            limitPrice:       request.limitPrice,
            stopPrice:        request.stopPrice,
            status:           isMarket ? .filled : .pending,
            timeInForce:      request.timeInForce,
            filledQuantity:   isMarket ? request.quantity : .zero,
            averageFillPrice: isMarket ? fillPrice : nil,
            placedAt:         now,
            updatedAt:        now
        )
        orders.insert(order, at: 0)

        if isMarket {
            transactions.insert(
                Transaction(
                    id:           UUID().uuidString,
                    orderID:      order.id,
                    instrumentID: request.instrumentID,
                    type:         request.side == .buy ? .buy : .sell,
                    quantity:     request.quantity,
                    price:        fillPrice,
                    fee:          .zero,
                    currency:     .usd,
                    executedAt:   now
                ),
                at: 0
            )
        }

        return order
    }

    /// Restaura el estado semilla. Utilidad solo para tests.
    public func reset() {
        cashBalance = Self.seedCashBalance
        positions = Self.seedPositions
        orders = Self.seedOrders
        transactions = Self.seedTransactions
    }

    // MARK: - Lógica de ejecución

    private func applyFill(side: OrderSide, instrumentID: String, quantity: Decimal, fillPrice: Decimal) throws {
        let notional = fillPrice * quantity

        switch side {
        case .buy:
            guard cashBalance >= notional else {
                throw IFError.validationFailed("Saldo insuficiente para esta operación.")
            }
            cashBalance -= notional

            if let i = positions.firstIndex(where: { $0.instrumentID == instrumentID }) {
                let old = positions[i]
                let newQty = old.quantity + quantity
                let blendedAvg = ((old.averageCostBasis * old.quantity) + notional) / newQty
                positions[i] = Position(
                    instrumentID:     old.instrumentID,
                    instrumentType:   old.instrumentType,
                    quantity:         newQty,
                    averageCostBasis: blendedAvg,
                    currentPrice:     old.currentPrice
                )
            } else {
                positions.append(Position(
                    instrumentID:     instrumentID,
                    instrumentType:   Self.instrumentType(for: instrumentID),
                    quantity:         quantity,
                    averageCostBasis: fillPrice,
                    currentPrice:     fillPrice
                ))
            }

        case .sell:
            guard let i = positions.firstIndex(where: { $0.instrumentID == instrumentID }),
                  positions[i].quantity >= quantity else {
                throw IFError.validationFailed("No tienes suficientes unidades de \(instrumentID) para vender.")
            }
            cashBalance += notional

            let old = positions[i]
            let newQty = old.quantity - quantity
            if newQty <= .zero {
                positions.remove(at: i)
            } else {
                positions[i] = Position(
                    instrumentID:     old.instrumentID,
                    instrumentType:   old.instrumentType,
                    quantity:         newQty,
                    averageCostBasis: old.averageCostBasis,
                    currentPrice:     old.currentPrice
                )
            }
        }
    }

    /// Clase de activo aproximada para los instrumentos que el universo de la demo conoce.
    private static func instrumentType(for instrumentID: String) -> InstrumentType {
        switch instrumentID {
        case "BTC", "ETH":  return .crypto
        case "SPY", "QQQ":  return .etf
        default:            return .stock
        }
    }
}

// MARK: - Datos semilla
//
// Los mismos valores que los repositorios mock devolvían como constantes estáticas
// antes de que existiera este store, para que una sesión nueva se vea idéntica al
// comportamiento anterior.

public extension MockBrokerStore {

    static let seedCashBalance: Decimal = 5_240

    static let seedPositions: [Position] = [
        Position(instrumentID: "AAPL", instrumentType: .stock,  quantity: 10,   averageCostBasis: 165.20, currentPrice: 189.45),
        Position(instrumentID: "BTC",  instrumentType: .crypto, quantity: 0.15, averageCostBasis: 52_000,  currentPrice: 67_420),
        Position(instrumentID: "SPY",  instrumentType: .etf,    quantity: 5,    averageCostBasis: 490,     currentPrice: 524.80),
        Position(instrumentID: "QQQ",  instrumentType: .etf,    quantity: 3,    averageCostBasis: 420,     currentPrice: 449.20)
    ]

    static let seedOrders: [Order] = [
        Order(id: "ord_001", instrumentID: "AAPL", side: .buy, type: .market,
              quantity: 10, status: .filled, filledQuantity: 10, averageFillPrice: 165.20,
              placedAt: Date().addingTimeInterval(-86_400 * 30), updatedAt: Date().addingTimeInterval(-86_400 * 30)),
        Order(id: "ord_002", instrumentID: "BTC", side: .buy, type: .market,
              quantity: Decimal(string: "0.15")!, status: .filled, filledQuantity: Decimal(string: "0.15")!, averageFillPrice: 52_000,
              placedAt: Date().addingTimeInterval(-86_400 * 20), updatedAt: Date().addingTimeInterval(-86_400 * 20)),
        Order(id: "ord_003", instrumentID: "TSLA", side: .buy, type: .limit,
              quantity: 5, limitPrice: 230, status: .pending, filledQuantity: .zero,
              placedAt: Date().addingTimeInterval(-3_600), updatedAt: Date().addingTimeInterval(-3_600)),
        Order(id: "ord_004", instrumentID: "ETH", side: .sell, type: .limit,
              quantity: Decimal(string: "0.5")!, limitPrice: 3_800, status: .pending, filledQuantity: .zero,
              placedAt: Date().addingTimeInterval(-1_800), updatedAt: Date().addingTimeInterval(-1_800))
    ]

    static let seedTransactions: [Transaction] = [
        Transaction(id: "txn_001", orderID: "ord_001", instrumentID: "AAPL", type: .buy,
                    quantity: 10, price: 165.20, fee: 0, currency: .usd, executedAt: Date().addingTimeInterval(-86_400 * 30)),
        Transaction(id: "txn_002", orderID: "ord_002", instrumentID: "BTC", type: .buy,
                    quantity: Decimal(string: "0.15")!, price: 52_000, fee: 0, currency: .usd, executedAt: Date().addingTimeInterval(-86_400 * 20)),
        Transaction(id: "txn_003", instrumentID: nil, type: .deposit,
                    price: 10_000, fee: 0, currency: .usd, executedAt: Date().addingTimeInterval(-86_400 * 45)),
        Transaction(id: "txn_004", orderID: "ord_003", instrumentID: "SPY", type: .buy,
                    quantity: 5, price: 490, fee: 0, currency: .usd, executedAt: Date().addingTimeInterval(-86_400 * 15)),
        Transaction(id: "txn_005", orderID: "ord_004", instrumentID: "QQQ", type: .buy,
                    quantity: 3, price: 420, fee: 0, currency: .usd, executedAt: Date().addingTimeInterval(-86_400 * 10))
    ]
}
