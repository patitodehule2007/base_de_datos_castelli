
// 1

db["ej1"].insertOne({ nombre: "pepe", apellido: "rodriguez", edad: 67, mail: "pepe@a.com" })
db["ej1"].find({ nombre: "pepe", apellido: "rodriguez", edad: 67, mail: "pepe@a.com" })

/*
{
  _id: ObjectId('6abe456ccd803079c71698ec'),
  nombre: 'pepe',
  apellido: 'rodriguez',
  edad: 67,
  mail: 'pepe@a.com'
}

*/


db["ej1"].insertOne({ nombre: "ignacio", apellido: "lopez", edad: 30, mail: "juan@a.com" })
db["ej1"].find({ nombre: "ignacio", apellido: "lopez", edad: 30, mail: "juan@a.com" })

/*
{
  _id: ObjectId('6abe4605cd803079c71698ed'),
  nombre: 'ignacio',
  apellido: 'lopez',
  edad: 30,
  mail: 'juan@a.com'
}
*/