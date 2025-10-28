FROM osrf/ros:humble-desktop

# System Update
RUN apt-get update && \
    apt-get install -y \
    sudo \
    wget \
    curl \
    software-properties-common && \
    apt-get autoremove -y

# User Settings
ARG USERNAME=taku_ros
ARG HOST_USER_ID=1000
ARG HOST_GROUP_ID=$HOST_USER_ID

## User Creation (UID/GID: 1000)
RUN groupadd --gid $HOST_GROUP_ID $USERNAME && \
    useradd --uid $HOST_USER_ID --gid $HOST_GROUP_ID -m $USERNAME && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME && \
    chown $HOST_USER_ID:$HOST_GROUP_ID /home/$USERNAME

## Oh My Zsh Setup
USER $USERNAME
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.1/zsh-in-docker.sh)" -- \
    -t eastwood \
    -p git \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-syntax-highlighting \
    -a "source /opt/ros/humble/setup.zsh"
# Nvim settings
## Vim build
WORKDIR /tmp
RUN sudo apt-get install -y \
    git \
    make \
    clang \
    libtool-bin
RUN git clone https://github.com/vim/vim.git && \
    cd vim/src && \
    make && \
    sudo make install
## Nvim Build Tools
RUN sudo apt-get install -y \
    ninja-build \
    gettext \
    cmake \
    curl
## Nvim Build Process
### Neovim
WORKDIR /tmp
RUN mkdir src && cd src
RUN git clone https://github.com/neovim/neovim && \
    cd neovim && \
    make CMAKE_BUILD_TYPE=RelWithDebInfo && \
    sudo make install
## Plugin Dependencies
RUN sudo apt-get install -y \
    luarocks
### node/npm installation
RUN curl -fsSL https://deb.nodesource.com/setup_current.x -o nodesource_setup.sh && \
    sudo -E bash nodesource_setup.sh && \
    sudo apt install -y nodejs
    
# Environment Settings
## Workspace
RUN mkdir -p /home/$USERNAME/ros2_ws/src && \
    chown $HOST_USER_ID:$HOST_USER_ID /home/$USERNAME/ros2_ws
## Login Shell
RUN echo "sudo chown -R 1000:1000 /home/$USERNAME/.config" >> /home/$USERNAME/.zshrc
# Entrypoint settings
WORKDIR /home/$USERNAME
ENTRYPOINT [ "/bin/zsh" ]
CMD ["-l"]
