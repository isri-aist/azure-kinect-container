ARG ROS_DISTRO="humble"
ARG IMAGE_SOURCE_REPO="isri-aist/azure-kinect-container"

FROM osrf/ros:${ROS_DISTRO}-desktop
ARG IMAGE_SOURCE_REPO

LABEL org.opencontainers.image.source="https://github.com/${IMAGE_SOURCE_REPO}"
LABEL org.opencontainers.image.description="Development environment for $IMAGE_SOURCE_REPO (ros $ROS_DISTRO)"

# Install dependencies
# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    gnupg \
    git \
    software-properties-common \
    lsb-release \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://packages.microsoft.com/ubuntu/18.04/prod/pool/main/k/k4a-tools/k4a-tools_1.4.2_amd64.deb
RUN wget https://packages.microsoft.com/ubuntu/18.04/prod/pool/main/libk/libk4a1.4-dev/libk4a1.4-dev_1.4.2_amd64.deb
RUN wget https://packages.microsoft.com/ubuntu/18.04/prod/pool/main/libk/libk4a1.4/libk4a1.4_1.4.2_amd64.deb

RUN apt-add-repository -y -n 'deb http://archive.ubuntu.com/ubuntu focal main'
RUN apt-add-repository -y 'deb http://archive.ubuntu.com/ubuntu focal universe'
RUN apt-get install -y libsoundio1 libsoundio-dev
RUN apt-add-repository -r -y -n 'deb http://archive.ubuntu.com/ubuntu focal universe'
RUN apt-add-repository -r -y 'deb http://archive.ubuntu.com/ubuntu focal main'

# Add Microsoft package repository for Azure Kinect
RUN curl -sSL https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/ubuntu/20.04/prod focal main"

# Install Azure Kinect Sensor SDK
RUN ACCEPT_EULA=Y apt install ./libk4a1.4_1.4.2_amd64.deb -y && rm libk4a1.4_1.4.2_amd64.deb
RUN ACCEPT_EULA=Y apt install ./libk4a1.4-dev_1.4.2_amd64.deb -y && rm libk4a1.4-dev_1.4.2_amd64.deb
RUN ACCEPT_EULA=Y apt install ./k4a-tools_1.4.2_amd64.deb -y && rm k4a-tools_1.4.2_amd64.deb

# Set environment variables
ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu

# Create and build the workspace
WORKDIR /azure_ws

# Install ROS dependencies
RUN apt-get install ros-${ROS_DISTRO}-xacro ros-${ROS_DISTRO}-joint-state-publisher

# Clone the Azure Kinect ROS 2 Driver
RUN mkdir -p src && \
    cd src && \
    git clone https://github.com/isri-aist/Azure_Kinect_ROS_Driver.git -b ${ROS_DISTRO}

# Source ROS and build the package
RUN /bin/bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash && \
    cd /azure_ws && \
    colcon build --packages-select azure_kinect_ros_driver"

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set entrypoint to source environments before running anything
ENTRYPOINT ["/entrypoint.sh"]

# Run driver on docker run
CMD ["ros2", "launch", "azure_kinect_ros_driver", "driver.launch.py"]