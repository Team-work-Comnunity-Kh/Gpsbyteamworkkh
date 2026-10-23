import { DataSource, DataSourceOptions } from 'typeorm';
import { config } from 'dotenv';

config();

export const typeormConfig: DataSourceOptions = {
  type: 'postgres',
  host: process.env.DATABASE_HOST || 'localhost',
  port: parseInt(process.env.DATABASE_PORT || '5432', 10),
  username: process.env.DATABASE_USER || 'smartgps',
  password: process.env.DATABASE_PASSWORD || 'smartgps123',
  database: process.env.DATABASE_NAME || 'smartgps_db',
  entities: [],
  migrations: [],
  synchronize: false,
  logging: process.env.NODE_ENV === 'development',
};

const dataSource = new DataSource(typeormConfig);
export default dataSource;
