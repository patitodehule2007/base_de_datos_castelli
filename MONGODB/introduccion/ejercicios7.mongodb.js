db["ej1"].updateOne({ _id: { "$numberInt": "1" } }, {
  $push: {
    "id_compra": 9,
    "monto": 120.5,
    "productos": [
      "laptop",
      "mouse",
      "teclado"
    ]
  }
})