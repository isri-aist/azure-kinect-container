ARG ROS_DISTRO="humble"
ARG IMAGE_SOURCE_REPO="isri-aist/azure-kinect-container"

FROM nvcr.io/nvidia/l4t-cuda:12.6.11-runtime
ARG IMAGE_SOURCE_REPO
ARG ROS_DISTRO
ARG DEBIAN_FRONTEND=noninteractive

LABEL org.opencontainers.image.source="https://github.com/${IMAGE_SOURCE_REPO}"
LABEL org.opencontainers.image.description="Development environment for $IMAGE_SOURCE_REPO (ros $ROS_DISTRO)"

WORKDIR /root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common \
    build-essential \
    lsb-release \
    nano \
    curl \
    wget \
    git \
    libgl1-mesa-dev \
    libsoundio-dev \
    libvulkan-dev \
    libx11-dev \
    libxcursor-dev \
    libxinerama-dev \
    libxrandr-dev \
    libusb-1.0-0-dev \
    libssl-dev \
    libudev-dev \
    mesa-common-dev \
    uuid-dev

## install ROS2
# Set locale
RUN apt-get install -y locales && \
    locale-gen en_US en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8 

# Setup Sources
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository universe && \
    apt-get update && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Install ROS 2 packages 
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y ros-${ROS_DISTRO}-ros-base python3-colcon-common-extensions ros-${ROS_DISTRO}-xacro ros-${ROS_DISTRO}-joint-state-publisher

# Add Microsoft package key and repository
RUN curl -sSL -O https://packages.microsoft.com/keys/microsoft.asc && \
    curl -sSL -O https://packages.microsoft.com/config/ubuntu/18.04/multiarch/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update

RUN wget https://packages.microsoft.com/ubuntu/18.04/multiarch/prod/pool/main/k/k4a-tools/k4a-tools_1.4.2_arm64.deb
RUN wget https://packages.microsoft.com/ubuntu/18.04/multiarch/prod/pool/main/libk/libk4a1.4-dev/libk4a1.4-dev_1.4.2_arm64.deb
RUN wget https://packages.microsoft.com/ubuntu/18.04/multiarch/prod/pool/main/libk/libk4a1.4/libk4a1.4_1.4.2_arm64.deb

RUN apt-get update && \
    cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
    printf "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports focal main universe\n" > /etc/apt/sources.list && \
    printf "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports focal-backports universe\n" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y libsoundio1 && \
    mv /etc/apt/sources.list.bak /etc/apt/sources.list && \
    apt-get update && \
    apt-get clean 

## The EULA acceptance is done using Debconf
## you can manually set entries in the debconf database to accept the EULA before installing the debian package.
## Refernce : https://github.com/microsoft/Azure-Kinect-Sensor-SDK/issues/1190
RUN ACCEPT_EULA=Y apt install ./libk4a1.4_1.4.2_arm64.deb -y && rm libk4a1.4_1.4.2_arm64.deb
RUN ACCEPT_EULA=Y apt install ./libk4a1.4-dev_1.4.2_arm64.deb -y && rm libk4a1.4-dev_1.4.2_arm64.deb
RUN ACCEPT_EULA=Y apt install ./k4a-tools_1.4.2_arm64.deb -y && rm k4a-tools_1.4.2_arm64.deb

    
# Set environment variables
ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu

# Create and build the workspace
WORKDIR /azure_ws

# Install ROS2 Dependencies
#RUN apt-get install -y ros-humble-image-transport ros-humble-cv-bridge ros-humble-angles

RUN apt install -y python3-rosdep

RUN rosdep init && \
    rosdep update

# Clone the Azure Kinect ROS 2 Driver
RUN mkdir -p src && \
    cd src && \
    git clone https://github.com/isri-aist/Azure_Kinect_ROS_Driver.git -b ${ROS_DISTRO}

# Source ROS and build the package
RUN /bin/bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash && \
    cd /azure_ws && \
    rosdep install -r -y -i --from-paths src && \
    colcon build --packages-select azure_kinect_ros_driver"

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set entrypoint to source environments before running anything
ENTRYPOINT ["/entrypoint.sh"]

# Run driver on docker run
CMD ["ros2", "launch", "azure_kinect_ros_driver", "driver.launch.py"]
