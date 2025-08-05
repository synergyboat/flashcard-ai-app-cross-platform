import * as SQLite from 'expo-sqlite';
import { BaseEntity } from './base-entity';

export abstract class BaseRepository<T extends BaseEntity> {
  protected db: SQLite.SQLiteDatabase;
  protected entityClass: new (...args: any[]) => T;

  constructor(db: SQLite.SQLiteDatabase, entityClass: new (...args: any[]) => T) {
    this.db = db;
    this.entityClass = entityClass;
  }

  // Get table name from entity
  protected getTableName(): string {
    return (this.entityClass as any).getTableName();
  }

  // Find entity by ID
  async findById(id: number): Promise<T | null> {
    const tableName = this.getTableName();
    const rows = await this.db.getAllAsync(
      `SELECT * FROM ${tableName} WHERE id = ?`,
      [id]
    );

    if (rows.length === 0) return null;
    return (this.entityClass as any).fromRow(rows[0]);
  }

  // Find all entities
  async findAll(): Promise<T[]> {
    const tableName = this.getTableName();
    const rows = await this.db.getAllAsync(`SELECT * FROM ${tableName}`);
    return rows.map(row => (this.entityClass as any).fromRow(row));
  }

  // Save entity (insert or update)
  async save(entity: T): Promise<T> {
    const primaryKey = (this.entityClass as any).getPrimaryKey();
    const hasId = primaryKey && (entity as any)[primaryKey.propertyKey];

    if (hasId) {
      await this.update(entity);
      return entity;
    } else {
      return await this.insert(entity);
    }
  }

  // Insert new entity
  async insert(entity: T): Promise<T> {
    const tableName = this.getTableName();
    const row = entity.toRow();
    const primaryKey = (this.entityClass as any).getPrimaryKey();

    // Remove id from row if it's auto-generated
    if (primaryKey?.autoGenerate) {
      delete row[primaryKey.propertyKey];
    }

    const columns = Object.keys(row);
    const values = Object.values(row);
    const placeholders = values.map(() => '?').join(', ');

    const result = await this.db.runAsync(
      `INSERT INTO ${tableName} (${columns.join(', ')}) VALUES (${placeholders})`,
      values
    );

    // Set the generated ID
    if (primaryKey?.autoGenerate && result.lastInsertRowId) {
      (entity as any)[primaryKey.propertyKey] = result.lastInsertRowId;
    }

    return entity;
  }

  // Update existing entity
  async update(entity: T): Promise<void> {
    const tableName = this.getTableName();
    const row = entity.toRow();
    const primaryKey = (this.entityClass as any).getPrimaryKey();

    if (!primaryKey) {
      throw new Error('Cannot update entity without primary key');
    }

    const idValue = (entity as any)[primaryKey.propertyKey];
    if (!idValue) {
      throw new Error('Cannot update entity without ID value');
    }

    // Remove id from update row
    delete row[primaryKey.propertyKey];

    const columns = Object.keys(row);
    const values = Object.values(row);
    const setClause = columns.map(col => `${col} = ?`).join(', ');

    await this.db.runAsync(
      `UPDATE ${tableName} SET ${setClause} WHERE ${primaryKey.propertyKey} = ?`,
      [...values, idValue]
    );
  }

  // Delete entity by ID
  async deleteById(id: number): Promise<void> {
    const tableName = this.getTableName();
    await this.db.runAsync(`DELETE FROM ${tableName} WHERE id = ?`, [id]);
  }

  // Delete entity
  async delete(entity: T): Promise<void> {
    const primaryKey = (this.entityClass as any).getPrimaryKey();
    if (!primaryKey) {
      throw new Error('Cannot delete entity without primary key');
    }

    const idValue = (entity as any)[primaryKey.propertyKey];
    if (!idValue) {
      throw new Error('Cannot delete entity without ID value');
    }

    await this.deleteById(idValue);
  }

  // Execute custom query
  protected async executeQuery(sql: string, params: any[] = []): Promise<any[]> {
    return await this.db.getAllAsync(sql, params);
  }

  // Execute custom update/insert/delete
  protected async executeUpdate(sql: string, params: any[] = []): Promise<SQLite.SQLiteRunResult> {
    return await this.db.runAsync(sql, params);
  }

  // Count entities
  async count(): Promise<number> {
    const tableName = this.getTableName();
    const result = await this.db.getAllAsync(`SELECT COUNT(*) as count FROM ${tableName}`);
    return (result[0] as { count: number }).count;
  }
}