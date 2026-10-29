db.BaseEjerciciosAggregate.aggregate([
    { $unwind: "$compras" },
    { $unwind: "$compras.productos" },
    { $group: { _id: "$compras.idcompra", cantidadGastado: { $sum: { $multiply: ["$compras.productos.precio", "$compras.productos.cantidad"] } } } }
])