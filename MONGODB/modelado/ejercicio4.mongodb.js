db.createCollection("actores")

db.actores.insertOne({
    "nombre": "Juan",
    "apellido": "Lopez",
    "fechaNacimiento": "1967-6-7",
    "nacinalidad": "argentina",
    "peliculas": [0]
})

db.createCollection("pelicula")

db.pelicula.insertOne({
    "titulo": "toy story",
    "anio": "2000-2-2",
    "genero": "animado",
    "duracion": "2 horas",
    "actores": [0]
})
