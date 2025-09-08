#!/bin/bash
set -e

# Source ROS 2 setup
source /opt/ros/${ROS_DISTRO}/setup.bash

# Source the Kinect ROS 2 driver workspace (pre-installed)
if [ -f "/azure_ws/install/setup.bash" ]; then
    source /azure_ws/install/setup.bash
fi

# Execute the command passed to the container
exec "$@"