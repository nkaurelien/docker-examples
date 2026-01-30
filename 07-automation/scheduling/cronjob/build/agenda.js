const Agenda = require("agenda");

const mongoConnectionString = "mongodb://mongodb:27017/agenda";

// Initialize Agenda with MongoDB connection string
const agenda = new Agenda({ db: { address: mongoConnectionString } });

// Define job1 with concurrency limit
agenda.define("job1", { concurrency: 1 }, () => {
  console.log('Executing Agenda job1');
});

const main = async () => {
  try {
    // Start Agenda
    await agenda.start();

    // Schedule job1 to run every 15 seconds
    await agenda.every("*/5 * * * * *", "job1");

    console.log('Agenda is set up successfully and job1 is scheduled.');
  } catch (error) {
    console.error('Error setting up Agenda or scheduling job1:', error);
  }
};

// Run the main function
main();
