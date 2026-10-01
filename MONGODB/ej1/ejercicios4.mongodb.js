db["ej1"].find({ compras: { $exists: 1 } }, { compras: { monto: 1 } })

