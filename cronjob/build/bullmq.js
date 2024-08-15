const IORedis = require('ioredis');
const { Queue, Worker } = require("bullmq");

// Initialize redis connection with maxRetriesPerRequest set to null for BullMQ compatibility
const connection = new IORedis('redis://redis:6379', {
  maxRetriesPerRequest: null,
});

// Create a BullMQ queue using the Redis connection
const queue = new Queue("cron", { connection });

const main = async () => {
  try {
    // Add a cronjob job to the queue that repeats every 5 seconds, with a limit of 1
    await queue.add('job1', { cronNumber: 1 }, {
      repeat: {
        // Repeat job once every day at 3:15 (am)
        // pattern: '0 15 3 * * *',
        // limit: 1,
        // Repeat job every 5 seconds but no more than 100 times
        every: 5000,
        limit: 100,
      },
    });

    // Create a worker to process the jobs in the "cronjob" queue
    new Worker("cron", async (job) => {
      console.log(`Executing job: ${job.name}, data:`, job.data);
    }, { connection });

    console.log('Worker and queue are set up successfully.');
  } catch (error) {
    console.error('Error setting up the queue or worker:', error);
  }
};

// Run the main function
main();
