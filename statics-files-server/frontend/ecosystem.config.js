module.exports = {
  apps: [{
    name: "asone-patient-webapp",
    script: "serve",
    watch: true,
    cwd: "./app/",
    env: {
      PM2_SERVE_PATH: '.',
      PM2_SERVE_PORT: 8080,
      PM2_SERVE_SPA: 'true',
      // PM2_SERVE_HOMEPAGE: './index.html'
    }
  }]
};
