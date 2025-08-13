import * as SQLite from 'expo-sqlite';
import {
  ENTITY_METADATA_KEY,
  COLUMN_METADATA_KEY,
  PRIMARY_KEY_METADATA_KEY,
  FOREIGN_KEY_METADATA_KEY,
} from './decorators';

export abstract class BaseEntity {
  // Get entity metadata
  static getTableName(): string {
    const metadata = Reflect.getMetadata(ENTITY_METADATA_KEY, this);
    if (!metadata) {
      throw new Error(`Entity ${this.name} is not decorated with @Entity`);
    }
    return metadata.tableName;
  }

  static getColumns(): Array<{ propertyKey: string; name: string; type: string }> {
    return Reflect.getMetadata(COLUMN_METADATA_KEY, this) || [];
  }

  static getPrimaryKey(): { propertyKey: string; autoGenerate: boolean } | null {
    return Reflect.getMetadata(PRIMARY_KEY_METADATA_KEY, this) || null;
  }

  static getForeignKeys(): Array<{
    propertyKey: string;
    referencedTable: string;
    referencedColumn: string;
    onDelete?: string;
  }> {
    return Reflect.getMetadata(FOREIGN_KEY_METADATA_KEY, this) || [];
  }

  // Generate CREATE TABLE SQL
  static generateCreateTableSQL(): string {
    const tableName = this.getTableName();
    const columns = this.getColumns();
    const primaryKey = this.getPrimaryKey();
    const foreignKeys = this.getForeignKeys();

    const columnDefinitions = columns.map(col => {
      let definition = `${col.name} ${col.type}`;
      
      if (primaryKey && col.propertyKey === primaryKey.propertyKey) {
        definition += ' PRIMARY KEY';
        if (primaryKey.autoGenerate) {
          definition += ' AUTOINCREMENT';
        }
      }
      
      // Check if this column has NOT NULL constraint (you can extend this)
      if (col.propertyKey !== primaryKey?.propertyKey) {
        // For now, assume non-optional fields are NOT NULL
        // You could extend decorators to include nullable option
      }
      
      return definition;
    });

    // Add foreign key constraints
    const foreignKeyConstraints = foreignKeys.map(fk => {
      let constraint = `FOREIGN KEY (${fk.propertyKey}) REFERENCES ${fk.referencedTable} (${fk.referencedColumn})`;
      if (fk.onDelete) {
        constraint += ` ON DELETE ${fk.onDelete}`;
      }
      return constraint;
    });

    const allDefinitions = [...columnDefinitions, ...foreignKeyConstraints];
    
    return `CREATE TABLE IF NOT EXISTS ${tableName} (${allDefinitions.join(', ')})`;
  }

  // Convert entity instance to database row
  toRow(): Record<string, any> {
    const columns = (this.constructor as typeof BaseEntity).getColumns();
    const row: Record<string, any> = {};

    columns.forEach(col => {
      const value = (this as any)[col.propertyKey];
      if (value !== undefined) {
        // Handle date conversion
        if (value instanceof Date) {
          row[col.name] = value.toISOString();
        } else {
          row[col.name] = value;
        }
      }
    });

    return row;
  }

  // Create entity instance from database row - to be overridden in subclasses
  static fromRow(row: Record<string, any>): any {
    throw new Error('fromRow must be implemented in subclass');
  }

  private static isISODateString(value: string): boolean {
    const isoDateRegex = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?Z?$/;
    return isoDateRegex.test(value);
  }
}