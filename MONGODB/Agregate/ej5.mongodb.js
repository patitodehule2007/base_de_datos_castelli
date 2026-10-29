db.BaseEjerciciosAggregate.aggregate(
    [
        { $unwind: "$compras" },
        { $group: { _id: "$dni", cantidadCompras: { $sum: 1 } } },
        { $group: { _id: null, maximoCompra: { $max: "$cantidadCompras" } } }
    ]
)