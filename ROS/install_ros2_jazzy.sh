sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository universe -y
sudo apt install -y curl gnupg2 lsb-release
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
sudo rm -f /etc/apt/trusted.gpg.d/osrf.gpg
apt-key export osrf | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/osrf.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
sudo apt update
sudo apt install -y libpython3-dev python3-pip ros-jazzy-desktop ros-jazzy-turtlebot3* ros-jazzy-tf* ros-dev-tools python3-rosdep python3-colcon-common-extensions ros-jazzy-ros-gz
sudo pip3 install transforms3d
sudo pip3 install -U argcomplete
grep -q -F 'source /opt/ros/jazzy/setup.bash' ~/.bashrc || echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc
source ~/.bashrc
sudo rosdep init
rosdep update
