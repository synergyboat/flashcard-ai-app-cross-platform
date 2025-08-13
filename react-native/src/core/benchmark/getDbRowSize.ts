export function getRowSizeInBytes(row: Record<string, unknown>): number {
  try {
    const json = JSON.stringify(row);
    // Cross-platform UTF-8 byte length without relying on TextEncoder/Buffer
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const byteLength = (unescape(encodeURIComponent(json)) as any).length as number;
    return byteLength;
  } catch {
    return 0;
  }
}

export function getRowSizeInKB(row: Record<string, unknown>): number {
  return getRowSizeInBytes(row) / 1024.0;
}


