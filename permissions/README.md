# Linux Users, Groups and Permissions Lab

## Objective

This lab demonstrates how Linux users, groups, ownership, and file permissions can be used to control access to application directories.

## Lab Environment

The following application structure was created:

/opt/myapp/
├── config/
├── logs/
└── scripts/

Two users and one group were used:

- appuser: application owner
- tester: test user
- devops: shared group

## User and Group Management

A dedicated application user and a DevOps group were created.

Commands used:

useradd -m appuser
groupadd devops
usermod -aG devops appuser
useradd -m tester
usermod -aG devops tester

Group membership was verified with:

groups appuser
groups tester

## Ownership and Permissions

The config directory was assigned to appuser and the devops group:

chown appuser:devops /opt/myapp/config
chmod 750 /opt/myapp/config

Permission 750 means:

- Owner: read, write, execute
- Group: read and execute
- Others: no access

## Permission Test

The tester user was able to enter the config directory because tester belongs to the devops group.

However, creating a file failed:

touch test.txt

Result:

Permission denied

This happened because the group had read and execute permissions but no write permission.

## Key Takeaway

Linux access control depends on the combination of:

- User identity
- Group membership
- File or directory ownership
- Permission bits

Permissions should be tested using the actual user that will access the resource instead of assuming that the configuration is correct.
