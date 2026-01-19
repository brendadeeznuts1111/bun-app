import { test, expect } from 'bun:test';
import path from 'path';

// Basic test to ensure testing framework works
test('basic - project structure exists', async () => {
  // Check VERSION file exists
  const versionFile = path.join(process.cwd(), 'VERSION');
  const versionExists = await Bun.file(versionFile).exists();
  expect(versionExists).toBe(true);
  
  // Check package.json exists
  const packageFile = path.join(process.cwd(), 'package.json');
  const packageExists = await Bun.file(packageFile).exists();
  expect(packageExists).toBe(true);
  
  // Check README exists
  const readmeFile = path.join(process.cwd(), 'README.md');
  const readmeExists = await Bun.file(readmeFile).exists();
  expect(readmeExists).toBe(true);
});

test('basic - version format is valid', async () => {
  const versionFile = path.join(process.cwd(), 'VERSION');
  const version = await Bun.file(versionFile).text();
  expect(version.trim()).toMatch(/^\d+\.\d+\.\d+$/);
});

test('basic - package.json has required fields', async () => {
  const packageFile = path.join(process.cwd(), 'package.json');
  const packageContent = await Bun.file(packageFile).text();
  const packageJson = JSON.parse(packageContent);
  
  expect(packageJson.name).toBe('@brendadeeznuts1111/bun-app');
  expect(packageJson.version).toMatch(/^\d+\.\d+\.\d+$/);
  expect(packageJson.description).toBeTruthy();
  expect(packageJson.scripts).toBeTruthy();
});

test('basic - main scripts exist', async () => {
  const scripts = [
    'scripts/version-manager.sh',
    'showcase/enhanced-demo.sh',
    'security/auth-manager.sh',
    'collaboration/collab-server.sh',
    'analytics/ai-dashboard.sh',
    'plugins/marketplace.sh'
  ];
  
  for (const script of scripts) {
    const scriptPath = path.join(process.cwd(), script);
    const scriptExists = await Bun.file(scriptPath).exists();
    expect(scriptExists).toBe(true);
  }
});
