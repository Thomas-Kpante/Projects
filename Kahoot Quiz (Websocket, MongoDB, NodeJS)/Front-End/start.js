const findFreePort = require('find-free-port');
const { exec } = require('child_process');

const DEFAULT_PORT = 3000;

// Find the next available port
findFreePort(DEFAULT_PORT, (err, freePort) => {
  if (err) {
    console.error('Error finding a free port:', err);
    return;
  }

  console.log(`Starting React on port ${freePort}`);

  // Set the PORT environment variable and run the React app
  const startScript = process.platform === 'win32' ? 'set PORT=' + freePort + '&& npm run start-react' : 'PORT=' + freePort + ' npm run start-react';

  const child = exec(startScript);

  child.stdout.pipe(process.stdout);
  child.stderr.pipe(process.stderr);
});
