export async function logExecDuration<T>(
  action: () => Promise<T>,
  opts: { name?: string; tag?: string; log?: boolean } = {},
): Promise<T> {
  const { name = 'no_name', tag = 'no_tag', log = true } = opts;
  const start = Date.now();
  const result = await action();
  const elapsed = Date.now() - start;
  if (log) {
    // eslint-disable-next-line no-console
    console.log(`${tag} | Execution time for ${name}: ${elapsed} ms`);
  }
  return result;
}


