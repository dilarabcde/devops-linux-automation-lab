# Linux Troubleshooting and Log Analysis Lab

## Objective

This lab demonstrates a basic troubleshooting workflow for investigating application problems using Linux command-line tools.

## Log Analysis

A sample application log was created with different log levels:

INFO Application started
INFO Database connected
WARNING Disk usage high
ERROR Database connection failed
INFO Request completed

### Filtering Logs with grep

Specific log entries were searched using:

grep "ERROR" app.log
grep "INFO" app.log
grep "failed" app.log

`grep` makes it possible to search large log files for relevant errors, warnings, or keywords.

## Inspecting Recent Logs

The latest log entries were viewed using:

tail app.log

A specific number of lines can be displayed with:

tail -n 2 app.log

## Live Log Monitoring

The log file was monitored in real time using:

tail -f app.log

From another terminal, a new log entry was added:

echo "ERROR Server timeout" >> app.log

The new entry appeared immediately in the terminal running `tail -f`.

This simulates monitoring logs while an application is running.

## Disk Troubleshooting

Filesystem usage was checked with:

df -h

Directory usage was inspected with:

du -sh /opt/myapp
du -h --max-depth=1 /opt/myapp

This helps answer two different questions:

- `df` → Is the filesystem running out of disk space?
- `du` → Which directory is consuming the space?

## Memory Troubleshooting

Memory usage was checked with:

free -h

Important values include:

- total
- used
- available

## Troubleshooting Workflow

A basic investigation can follow this sequence:

Application problem
→ Inspect logs
→ Search for errors
→ Monitor new logs
→ Check disk usage
→ Locate large directories
→ Check available memory

## Key Takeaway

Troubleshooting should be evidence-based.

Instead of immediately restarting an application, first inspect logs and system resources to identify the likely cause of the problem.
