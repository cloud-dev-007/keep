import 'reflect-metadata';
import { config as loadEnv } from 'dotenv';
import { DataSource, DataSourceOptions } from 'typeorm';
import { join } from 'path';

// Load env when this file is invoked by the TypeORM CLI (outside Nest's
// ConfigModule lifecycle). Inside the Nest app the same vars come through
// ConfigModule.forRoot() in app.module.ts.
loadEnv();

export const dataSourceOptions: DataSourceOptions = {
  type: 'postgres',
  host: process.env.DB_HOST ?? 'localhost',
  port: parseInt(process.env.DB_PORT ?? '5432', 10),
  username: process.env.DB_USER ?? 'postgres',
  password: process.env.DB_PASSWORD ?? 'pass123',
  database: process.env.DB_NAME ?? 'postgres',
  // Entities are autoloaded by Nest at runtime; the CLI needs explicit globs.
  entities: [join(__dirname, '/**/*.entity{.ts,.js}')],
  migrations: [join(__dirname, '/migrations/*{.ts,.js}')],
  migrationsTableName: 'q_engine_migrations',
  synchronize: false,
};

export default new DataSource(dataSourceOptions);
