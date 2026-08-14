const cron = require('node-cron');

// pm2 instance name
const processName = process.env.name || 'pm2-node-cronjob-primary';

// Only schedule cronjob job if it´s the primary pm2 instance
if (processName === 'pm2-node-cronjob-primary') {
    // schedule cronjob job
    cron.schedule('*/5 * * * * *', () => {
        console.log(`Process ${processName} cron job: Current hours is ${new Date().getHours()}, running.`);
    });
}