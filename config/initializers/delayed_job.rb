# Set to false to leave jobs in DB after they have exceed max_attempts
Delayed::Worker.destroy_failed_jobs = true

# Number of times to try a failed job before giving up. 15 attempts should spread the
# attempts over approx 1.5 days.
Delayed::Worker.max_attempts = 15

# Timeout after which we presume that a worker has died, and another computer may pick
# up its jobs. The worker is responsible for ensuring it take less time than this.
# In the case of ShareIdeaJob, we wrap the worker in a Timeout::timeout.
Delayed::Worker.max_run_time = 3.minutes

# Time to sleep before querying for new jobs when work queue is empty.
Delayed::Worker.sleep_delay  = 8
