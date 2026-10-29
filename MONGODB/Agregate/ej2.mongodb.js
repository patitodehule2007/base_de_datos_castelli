db.BaseEjerciciosAggregate.aggregate([
    { $unwind: "$compras" },
    { $unwind: "$compras.productos" },
    { $group: { _id: "$compras.productos.idProd", cantidadCompras: { $sum: 1 } } }
]
)