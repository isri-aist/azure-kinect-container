# Azure Kinect container

This repository describes how to set up the Azure Kinect with ROS 2 inside a Docker container for Ubuntu Jammy and Noble.

## Host setup

Before using the Azure Kinect in a Docker container, you must configure **udev rules** on your host machine.

```bash
sudo apt-get install udev
sudo tee /etc/udev/rules.d/99-k4a.rules > /dev/null <<EOF
# Azure Kinect udev rules
ATTRS{idVendor}=="045e", ATTRS{idProduct}=="097a", MODE="0666", GROUP="plugdev"
ATTRS{idVendor}=="045e", ATTRS{idProduct}=="097b", MODE="0666", GROUP="plugdev"
ATTRS{idVendor}=="045e", ATTRS{idProduct}=="097c", MODE="0666", GROUP="plugdev"
ATTRS{idVendor}=="045e", ATTRS{idProduct}=="097d", MODE="0666", GROUP="plugdev"
ATTRS{idVendor}=="045e", ATTRS{idProduct}=="097e", MODE="0666", GROUP="plugdev"
EOF

sudo udevadm control --reload-rules
sudo udevadm trigger
```
## Docker setup

In order to pull images you need to run one of the following command :

```bash
docker pull ghcr.io/isri-aist/azure-kinect-container:humble 
# or 
docker pull ghcr.io/isri-aist/azure-kinect-container:jazzy 
```
This command install Azure Kinect SDK and ROS2 driver.

## How to run 

Once the container is built and your camera is plugged in, run the following command to launch the container:

```bash
docker run -it --rm  -e DISPLAY=$DISPLAY -e ROS_DOMAIN_ID=10 -v /tmp/.X11-unix:/tmp/.X11-unix --net=host --ipc=host --privileged --shm-size=2g ghcr.io/isri-aist/azure-kinect-container:humble
#or (To be run in the current folder)
docker compose up 

rqt # can be used to visualize current image
```

> ℹ️ --privileged is required to access USB devices. X11 display is passed to allow GUI applications like RViz to render (if used). 

> 💻 If you want to use your host gpu, you will need to install NVIDIA Container Toolkit and add the following content to the run command : `-e NVIDIA_DRIVER_CAPABILITIES=all --runtime=nvidia --gpus=all`

## Custom run 

If you want to use your own launch file, you need to mount launch file's directory and specify which launch file should be ran. 

Please check the following entries in `docker-compose.yml` :
* volumes
* working_dir
* command

You can then run the container by executing the following command in the current directory :

```bash
docker compose up 
```

## Advance 

### Running in the background

If you detach your docker run you can use `-d` option either for `docker run` or `docker compose` command. 

#### Useful links

https://medium.com/@asandy520/how-to-use-python-to-run-kinect-azure-dk-on-ubuntu-22-04-7c323442c84b