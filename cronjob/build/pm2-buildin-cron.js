// pm2 instance name
const processName = process.env.name || 'pm2-buildin-cronjob-primary';


console.log(`${processName} cron job: Current hours is ${new Date().getHours()}, running.`);
