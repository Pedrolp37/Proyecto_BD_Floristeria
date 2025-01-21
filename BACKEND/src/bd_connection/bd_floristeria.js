import pg from 'pg';
import {DB_USER,DB_HOST,DB_PASSWORD,DB_DATABASE,DB_PORT} from '../../config.js'

export const pool = new pg.Pool({
    user: DB_USER,
    password: DB_PASSWORD,
    host: DB_HOST,
    port: DB_PORT,
    database: DB_DATABASE,
});

// Intenta conectarte a la base de datos
pool.connect()
  .then(() => {
    console.log('Conexión a la base de datos exitosa');
  })
  .catch((error) => {
    console.error('Error al conectar a la base de datos:', error);
  });