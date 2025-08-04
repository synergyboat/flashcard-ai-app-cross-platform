import 'reflect-metadata';

// Metadata keys
export const ENTITY_METADATA_KEY = Symbol('entity');
export const COLUMN_METADATA_KEY = Symbol('column');
export const PRIMARY_KEY_METADATA_KEY = Symbol('primaryKey');
export const FOREIGN_KEY_METADATA_KEY = Symbol('foreignKey');

// Entity decorator
export function Entity(tableName: string) {
  return function <T extends { new (...args: any[]): {} }>(constructor: T) {
    Reflect.defineMetadata(ENTITY_METADATA_KEY, { tableName }, constructor);
    return constructor;
  };
}

// Column decorator
export function Column(options: { name?: string; type?: string } = {}) {
  return function (target: any, propertyKey: string) {
    const existingColumns = Reflect.getMetadata(COLUMN_METADATA_KEY, target.constructor) || [];
    existingColumns.push({
      propertyKey,
      name: options.name || propertyKey,
      type: options.type || 'TEXT',
    });
    Reflect.defineMetadata(COLUMN_METADATA_KEY, existingColumns, target.constructor);
  };
}

// Primary Key decorator
export function PrimaryKey(autoGenerate: boolean = true) {
  return function (target: any, propertyKey: string) {
    Reflect.defineMetadata(PRIMARY_KEY_METADATA_KEY, { propertyKey, autoGenerate }, target.constructor);
    // Also mark as column
    Column({ type: 'INTEGER' })(target, propertyKey);
  };
}

// Foreign Key decorator
export function ForeignKey(options: { 
  referencedTable: string; 
  referencedColumn: string; 
  onDelete?: 'CASCADE' | 'SET NULL' | 'RESTRICT' 
}) {
  return function (target: any, propertyKey: string) {
    const existingForeignKeys = Reflect.getMetadata(FOREIGN_KEY_METADATA_KEY, target.constructor) || [];
    existingForeignKeys.push({
      propertyKey,
      ...options,
    });
    Reflect.defineMetadata(FOREIGN_KEY_METADATA_KEY, existingForeignKeys, target.constructor);
    // Also mark as column
    Column({ type: 'INTEGER' })(target, propertyKey);
  };
}

// Date converter decorator
export function DateColumn() {
  return function (target: any, propertyKey: string) {
    Column({ type: 'TEXT' })(target, propertyKey);
  };
}