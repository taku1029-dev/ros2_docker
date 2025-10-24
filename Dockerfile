FROM osrf/ros:humble-desktop

# System Update
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    vim \
    neovim \
    byobu \
    net-tools \
    libgtk-3-0 \
    mesa-utils \
    dbus-x11

# User settings
ARG USERNAME=taku_ros
ARG HOST_USER_ID=1000
ARG HOST_GROUP_ID=$HOST_USER_ID

RUN groupadd --gid $HOST_GROUP_ID $USERNAME && \
    useradd --uid $HOST_USER_ID --gid $HOST_GROUP_ID -m $USERNAME && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME && \
    chown $HOST_USER_ID:$HOST_GROUP_ID /home/${USERNAME}

WORKDIR /home/$USERNAME
RUN mkdir -p ros2_ws/src && \
    chown $HOST_USER_ID:$HOST_USER_ID ros2_ws

USER $USERNAME

# Environment Setup
RUN . /opt/ros/humble/setup.bash

CMD ["/bin/bash"]
