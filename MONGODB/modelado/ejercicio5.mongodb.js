/*
Se quiere crear una base de datos para almacenar información de un sistema de
materias y profesores. De las materias nos interesa guardar: nombre de la
materia, código de la materia, y horas semanales. De los profesores
almacenamos: nombre, apellido, email y título. Una materia puede tener varios
profesores y un profesor puede dictar varias materias.

*/

db.createCollection("materias")

db.materias.insertOne({
    "codigoMateria": "3993204",
    "nombre": "lengua",
    "horasSemanales": 45,
    "profesores": []
})

db.createCollection("profesores")

db.profesores.insertOne({
    "nombre": "Pepe",
    "apellido": "lopez",
    "email": "jfojef@a.com",
    "título": "profesor",
    "materias": [0]
})