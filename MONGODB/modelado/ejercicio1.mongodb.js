db.createCollection("cliente")

db.cliente.insertOne({
    "nombre": "lucas",
    "apellido": "castelli",
    "mail": "alumno27.castelli.lucas.grabriel@ipm.edu.ar",
    "puesto": "dev",
    "carnet": {
        "numeroSerie": 12345,
        "fechaEmision": "2020-1-1",
        "fechavencimiento": "2067-6-7"
    }
})