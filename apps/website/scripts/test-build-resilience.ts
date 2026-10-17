/**
 * Ensures production build survives manifest fetch failures (cases a–d).
 * Run: bun run test:build-resilience
 */
import { spawn } from 'node:child_process';
import { createServer } from 'node:http';
import { join } from 'node:path';

const websiteRoot = join(import.meta.dir, '..');

function runBuild(label: string, manifestUrl: string | null) {
  return new Promise<void>((resolve, reject) => {
    const env: Record<string, string> = { ...process.env } as Record<string, string>;
    if (manifestUrl === null) {
      delete env.WEBSITE_UPDATE_MANIFEST_URL;
    } else {
      env.WEBSITE_UPDATE_MANIFEST_URL = manifestUrl;
    }

    const child = spawn('bun', ['run', 'build'], {
      cwd: websiteRoot,
      env,
      shell: true,
      stdio: 'inherit',
    });
    child.on('close', (code) => {
      if (code === 0) {
        console.log(`PASS ${label} (exit 0)`);
        resolve();
      } else {
        reject(new Error(`${label}: build exit ${code}`));
      }
    });
  });
}

async function withServer(
  handler: (
    req: import('node:http').IncomingMessage,
    res: import('node:http').ServerResponse,
  ) => void,
  fn: (port: number) => Promise<void>,
) {
  const server = createServer(handler);
  await new Promise<void>((r) => server.listen(0, '127.0.0.1', () => r()));
  const port = (server.address() as { port: number }).port;
  try {
    await fn(port);
  } finally {
    await new Promise<void>((r) => server.close(() => r()));
  }
}

async function main() {
  await runBuild('(a) WEBSITE_UPDATE_MANIFEST_URL unset', null);
  await runBuild('(b) empty manifest URL', '');

  await withServer((_req, res) => {
    res.statusCode = 404;
    res.end('not found');
  }, async (port) => {
    await runBuild('(c) manifest 404', `http://127.0.0.1:${port}/version.json`);
  });

  await withServer((_req, res) => {
    res.statusCode = 500;
    res.end('error');
  }, async (port) => {
    await runBuild('(d) manifest 500', `http://127.0.0.1:${port}/version.json`);
  });

  console.log('All automated build-resilience cases passed.');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
