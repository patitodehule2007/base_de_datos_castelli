db.BaseEjerciciosAggregate.aggregate([
    { $unwind: "$compras" },
    { $unwind: "$compras.productos" },
    { $group: { _id: "$compras.idcompra", cantidadCompras: { $sum: "$compras.productos.cantidad" } } },
    { $group: { _id: null, compras: { $avg: "$cantidadCompras" } } }
])