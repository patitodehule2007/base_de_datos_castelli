/* 
Se quiere crear una base de datos para almacenar información de un sistema de
pacientes y sus historias clínicas. De cada paciente almacenamos: nombre,
apellido, dni, fecha de nacimiento, teléfono. Cada paciente tiene una única
historia clínica con los datos: número de historia, fecha de inicio, observaciones
generales. A su vez, cada historia clínica tiene múltiples registros médicos de los
cuales almacenamos: fecha de consulta, diagnóstico, tratamiento y médico.
*/
db.createCollection("pacientes")

db.pacientes.insertOne({
    "nombre": "ingnacio",
    "apellido": "wenner",
    "dni": 40239455,
    "fechaNacimiento": "2000-2-2",
    "telefono": 43209345345,
    "historiaClinica": [
        {
            "numeroHistoria": 800,
            "fechaInicio": "2200-2-3",
            "observacionesGenerales": ["paciente sano"],
            "consultas": [{
                "fechaConsulta": "2100-2-8",
                "diagnostico": "bien",
                "tratamiento": "no hay problema",
                "idMedico": "6ad9ba96e1abd65912a60dac"
            }]
        }
    ]

})
