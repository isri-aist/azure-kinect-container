#!/bin/bash
set -e

# Source ROS 2 and workspace setup
source /opt/ros/${ROS_DISTRO}/setup.bash
source /azure_ws/install/setup.bash

# Execute the passed command
exec "$@"