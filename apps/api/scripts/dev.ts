import { spawn } from 'node:child_process';
import path from 'node:path';
import { config as loadEnv } from 'dotenv';

loadEnv({ path: path.resolve(import.meta.dir, '../.env'), override: true });

const port = Number(process.env.PORT ?? 3000);

async function findListeningPids(targetPort: number): Promise<number[]> {
  if (process.platform === 'win32') {
    const proc = Bun.spawn(['netstat', '-ano'], { stdout: 'pipe' });
    const text = await new Response(proc.stdout).text();
    const pids = new Set<number>();

    for (const line of text.split('\n')) {
      if (!line.includes(`:${targetPort}`) || !line.includes('LISTENING')) {
        continue;
      }

      const pid = Number(line.trim().split(/\s+/).at(-1));
      if (Number.isFinite(pid) && pid > 0) {
        pids.add(pid);
      }
    }

    return [...pids];
  }

  const proc = Bun.spawn(['lsof', '-ti', `:${targetPort}`], {
    stdout: 'pipe',
    stderr: 'ignore',
  });
  const text = (await new Response(proc.stdout).text()).trim();
  if (!text) {
    return [];
  }

  return text
    .split('\n')
    .map((value) => Number(value))
    .filter((pid) => Number.isFinite(pid) && pid > 0);
}

async function isBunProcess(pid: number): Promise<boolean> {
  if (process.platform === 'win32') {
    const proc = Bun.spawn(
      ['tasklist', '/FI', `PID eq ${pid}`, '/FO', 'CSV', '/NH'],
      {
        stdout: 'pipe',
        stderr: 'ignore',
      },
    );
    const text = (await new Response(proc.stdout).text()).toLowerCase();
    return text.includes('bun.exe');
  }

  const proc = Bun.spawn(['ps', '-p', String(pid), '-o', 'comm='], {
    stdout: 'pipe',
    stderr: 'ignore',
  });
  const text = (await new Response(proc.stdout).text()).trim().toLowerCase();
  return text.includes('bun');
}

async function killStaleDevServer(): Promise<void> {
  const pids = await findListeningPids(port);

  for (const pid of pids) {
    if (!(await isBunProcess(pid))) {
      continue;
    }

    console.log(`Stopping stale dev server on port ${port} (PID ${pid})`);

    if (process.platform === 'win32') {
      Bun.spawn(['taskkill', '/F', '/PID', String(pid)], {
        stdout: 'ignore',
        stderr: 'ignore',
      });
      continue;
    }

    process.kill(pid, 'SIGTERM');
  }

  if (pids.length > 0) {
    await Bun.sleep(300);
  }
}

await killStaleDevServer();

const child = spawn('bun', ['--watch', 'src/server.ts'], {
  cwd: path.resolve(import.meta.dir, '..'),
  stdio: 'inherit',
  shell: true,
});

child.on('exit', (code, signal) => {
  if (signal) {
    process.kill(process.pid, signal);
    return;
  }

  process.exit(code ?? 0);
});
