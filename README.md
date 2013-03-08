bastion.sh
==========

An easily extensible bash script for secure different Linux distributions.

Introduction
------------

bastion.sh is designed to be easily extensible by consolidating all system checks within the `tasks/` directory.
Additional steps can be dropped in to the directory with a number preceding the check's name to indicate where the check should fall in sequence of the other steps.

For detailed usage, consult `./bastion.sh -h`.
