module.exports = {
  apps: [{
    name: "asone-backend-webapi",
    watch: true,
    interpreter: "python3",
    script: "uvicorn",
    cwd: "./",
    watch_delay: 1000,
    ignore_watch: ["*cache*", "uploads", "node_modules", "\\.venv", "\\.git", "*.log"],
    args: 'main:app --log-level error --host 0.0.0.0 --port 9000',
  }]
};
