sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository universe -y
sudo apt install -y curl gnupg2 lsb-release
export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F'"' '{print $4}')
curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb"
sudo dpkg -i /tmp/ros2-apt-source.deb
sudo apt update
sudo apt install -y libpython3-dev python3-pip ros-dev-tools ros-rolling-desktop ros-rolling-turtlebot3* ros-rolling-tf* ros-dev-tools python3-rosdep python3-colcon-common-extensions ros-rolling-ros-gz
sudo pip3 install transforms3d
sudo pip3 install -U argcomplete
grep -q -F 'source /opt/ros/rolling/setup.bash' ~/.bashrc || echo "source /opt/ros/rolling/setup.bash" >> ~/.bashrc
source ~/.bashrc
sudo rosdep init
rosdep update