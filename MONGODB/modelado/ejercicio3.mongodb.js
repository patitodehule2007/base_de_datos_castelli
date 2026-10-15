db.createCollection("pedidosCompra")

db.pedidosCompra.insertOne({
    "idUsuario": "'6ad0ba96e1abd65912a60dec",
    "fecha": "2026-5-2",
    "productos": [{
        "idProducto": "6ad0ba96e1abd65912a60dac",
        "cantidad": 3,
        "precioUnitario": 50,
        "montoTotal": 150
    }],
});