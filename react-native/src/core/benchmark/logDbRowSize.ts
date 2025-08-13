import { getRowSizeInBytes, getRowSizeInKB } from './getDbRowSize';

export function logDbRowSize(
  row: Record<string, unknown>,
  opts: { name?: string; tag?: string; log?: boolean } = {},
): void {
  const { name = '', tag = 'db_row_size', log = true } = opts;
  const sizeBytes = getRowSizeInBytes(row);
  const sizeKB = getRowSizeInKB(row);
  if (log) {
    // eslint-disable-next-line no-console
    console.log(`${tag} | Row size for ${name}: ${sizeBytes} bytes (${sizeKB.toFixed(2)} KB)`);
  }
}

export function logTotalDbRowSize(
  rows: Array<Record<string, unknown>>,
  opts: { name?: string; tag?: string; log?: boolean } = {},
): void {
  const { name = '', tag = 'db_row_size', log = true } = opts;
  const totalBytes = rows.reduce((sum, row) => sum + getRowSizeInBytes(row), 0);
  const totalKB = totalBytes / 1024.0;
  if (log) {
    // eslint-disable-next-line no-console
    console.log(`${tag} | Total row size for ${name}: ${totalBytes} bytes (${totalKB.toFixed(2)} KB)`);
  }
}


