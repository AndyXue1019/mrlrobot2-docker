FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all

ENV ROS_DISTRO=jazzy
ENV COLCON_WORKSPACE=colcon_ws

ENV USER_NAME=ros
ENV USER_ID=1000
ENV GROUP_ID=1000

WORKDIR /opt/${COLCON_WORKSPACE}/src

RUN sed -i 's|http://archive.ubuntu.com/ubuntu/|http://tw.archive.ubuntu.com/ubuntu/|g' /etc/apt/sources.list.d/ubuntu.sources && \
    apt-get update && apt-get install -y \
    build-essential ca-certificates curl git sudo gnupg2 lsb-release locales \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8

RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

RUN apt-get update && apt-get install --no-install-recommends -y ros-$ROS_DISTRO-desktop \
  ros-$ROS_DISTRO-joy ros-$ROS_DISTRO-teleop-twist-joy \
  ros-$ROS_DISTRO-teleop-twist-keyboard ros-$ROS_DISTRO-laser-proc \
  ros-$ROS_DISTRO-urdf ros-$ROS_DISTRO-xacro ros-$ROS_DISTRO-rqt* \
  ros-$ROS_DISTRO-compressed-image-transport ros-$ROS_DISTRO-rviz2 \
  ros-$ROS_DISTRO-navigation2 ros-$ROS_DISTRO-slam-toolbox \
  ros-$ROS_DISTRO-interactive-markers ros-$ROS_DISTRO-dynamixel-sdk \
  ros-$ROS_DISTRO-cartographer ros-$ROS_DISTRO-cartographer-ros \
  ros-$ROS_DISTRO-nav2-bringup ros-$ROS_DISTRO-ros-gz \
  ros-$ROS_DISTRO-turtlesim python3-argcomplete python3-rosdep \
  python3-colcon-common-extensions python3-vcstool && \
  rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 -b jazzy https://github.com/NcuMathRoboticsLab/mrlrobot_sample_code.git \
    && rm -rf /opt/${COLCON_WORKSPACE}/src/mrlrobot_sample_code/.git

RUN mkdir -p /opt/${COLCON_WORKSPACE}/src/turtlebot \
    && cd /opt/${COLCON_WORKSPACE}/src/turtlebot \
    && git clone --depth 1 -b jazzy https://github.com/ROBOTIS-GIT/DynamixelSDK.git \
    && git clone --depth 1 -b jazzy https://github.com/ROBOTIS-GIT/turtlebot3_msgs.git \
    && git clone --depth 1 -b jazzy https://github.com/ROBOTIS-GIT/turtlebot3.git \
    && git clone --depth 1 -b jazzy https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git \
    && find /opt/${COLCON_WORKSPACE}/src/turtlebot -name .git -type d -prune -exec rm -rf {} +

COPY init.sh /usr/local/bin/init.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/init.sh /usr/local/bin/entrypoint.sh

WORKDIR /home/${USER_NAME}
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]
