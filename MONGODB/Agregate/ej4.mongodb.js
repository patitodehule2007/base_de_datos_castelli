db.BaseEjerciciosAggregate.aggregate(
    [
        { $unwind: "$compras" },
        { _id: "dni", cantidadCompras: { $sum: 1 } },
        { $match: { cantidadCompras: { $gt: 2 } } }
    ]
)