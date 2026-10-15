db.createCollection("usuarioCompras")

db.usuarioCompras.insertOne({
    "nombre": "facundo",
    "apellido": "devichenzo",
    "email": "devi@devi.chenzo",
    "clave": "Pibble67",
    "direccionesEntrega": [
        {
            "calle": "pedro moran 2818",
            "ciudad": "CABA",
            "codigoPostal": "6767",
            "provincia": "CABA"
        }
    ]
})