import { Platform } from 'react-native';

// Utility function to get the size of an object in bytes
export const getObjectSizeInBytes = (obj: any): number => {
    const jsonString = JSON.stringify(obj);
    return new TextEncoder().encode(jsonString).length;
};

// Utility function to get the size of an object in KB
export const getObjectSizeInKB = (obj: any): number => {
    return getObjectSizeInBytes(obj) / 1024.0;
};

// Utility function to log database row size
export const logDbRowSize = (
    row: Record<string, any>,
    options: {
        name?: string;
        tag?: string;
        log?: boolean;
    } = {}
) => {
    const { name = '', tag = 'db_row_size', log = true } = options;
    const sizeInBytes = getObjectSizeInBytes(row);
    const sizeInKB = getObjectSizeInKB(row);

    if (log && __DEV__) {
        console.log(`${tag} | Row size for ${name}: ${sizeInBytes} bytes (${sizeInKB.toFixed(2)} KB)`);
    }
};

// Utility function to log total database row size
export const logTotalDbRowSize = (
    rows: Record<string, any>[],
    options: {
        name?: string;
        tag?: string;
        log?: boolean;
    } = {}
) => {
    const { name = '', tag = 'db_row_size', log = true } = options;
    const totalSizeInBytes = rows.reduce((sum, row) => sum + getObjectSizeInBytes(row), 0);
    const totalSizeInKB = totalSizeInBytes / 1024;

    if (log && __DEV__) {
        console.log(`${tag} | Total row size for ${name}: ${totalSizeInBytes} bytes (${totalSizeInKB.toFixed(2)} KB)`);
    }
};

// Utility function to log execution duration
export const logExecDuration = async <T>(
    action: () => Promise<T>,
    options: {
        name?: string;
        tag?: string;
        log?: boolean;
    } = {}
): Promise<T> => {
    const { name = 'no_name', tag = 'no_tag', log = true } = options;
    const startTime = Date.now();

    const result = await action();

    const endTime = Date.now();
    const duration = endTime - startTime;

    if (log && __DEV__) {
        console.log(`${tag} | Execution time for ${name}: ${duration} ms`);
    }

    return result;
}; 