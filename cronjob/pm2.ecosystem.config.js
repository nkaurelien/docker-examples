module.exports = {
    /**
     * Application configuration section
     * http://pm2.keymetrics.io/docs/usage/application-declaration/
     */
    apps: [

        {
            script: "./build/pm2-node-cronjob.js",
            instances: "1",
            exec_mode: "cluster",
            name: "pm2-node-cronjob-primary",
            env: {
                NODE_ENV: "development",
            },
            env_integration: {
                NODE_ENV: "integration",
            },
            env_production: {
                NODE_ENV: "production",
            },
        },
        {
            name: 'pm2-buildin-cronjob-primary',
            script: "./build/pm2-buildin-cronjob.js",
            instances: 1,
            exec_mode: 'fork',
            cron_restart: "*/8 * * * * *",
            watch: false,
            autorestart: false
        }
    ]
};