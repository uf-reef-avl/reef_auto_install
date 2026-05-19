SCRIPT_DIR="$(dirname "$0")"
chmod -R 755 ./*.sh
os_release=$(lsb_release -rs)
major=$(echo "$os_release" | cut -d'.' -f1)
print_help() {
  echo "Usage: $0 [--ros] [--ros2] [--cuda] [--cudareboot]"
  echo "Options:"
  echo "  --ros   Install ROS1"
  echo "  --ros2  Install ROS2"
  echo "  --cuda  Install Cuda Toolkit only"
  echo "  --cudareboot  Install Cuda Toolkit and reboot to automatically install pyTorch & Tensorflow"
}
ros=false
ros2=false
cuda=false
reboot=false
if [ $# -eq 0 ]; then
 	read -p "Would you like to install ROS1? [y/N]: " yn
	case $yn in
		[Yy]* ) ros=true;;
		[Nn]* ) ros=false;;
		"" ) ros=false;;
		* ) ros=false;;
	esac
	if [ $major -ge 20 ];
		then
			read -p "Would you like to install ROS2? [Y/n]: " yn
			case $yn in
				[Yy]* ) ros2=true;;
				[Nn]* ) ros2=false;;
				"" ) ros2=true;;
				* ) ros2=false;;
			esac
		else
			ros2=false
		fi
		
	if lspci | grep -iq "nvidia"; then
		read -p "Would you like to install Cuda Toolkit? [Y/n]: " yn
		case $yn in
			[Yy]* ) cuda=true;;
			[Nn]* ) cuda=false;;
			"" ) cuda=true;;
			* ) cuda=false;;
		esac
	else
		cuda=false
	fi
fi
while [[ $# -gt 0 ]]; do
  case "$1" in
    --ros)
      ros=true
      shift
      ;;
    --ros2)
      ros2=true
      shift
      ;;
    --cuda)
      cuda=true
      shift
      ;;
    --cudareboot)
      cuda=true
      reboot=true
      shift
      ;;
    -h|--help)
      print_help
      exit 0
      ;;
    *)
      echo "Error: Invalid argument '$1'"
      print_help
      exit 1
      ;;
  esac
done

#Prevent ROS2 install on Ubuntu installs older than 20.04
if [ $major -lt 20 ];then
  ros2=false
fi
#Disable ipv6
sudo sh $SCRIPT_DIR/forceipv4_apt.sh
sh $SCRIPT_DIR/mDNSfix.sh
#Update System
sudo apt update -y
sudo apt dist-upgrade -y

#Add Repos
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list'
sudo apt update -y
sudo apt-key export D38B4796 | sudo gpg --dearmor -o /usr/share/keyrings/google.gpg
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list'
sudo add-apt-repository -y ppa:graphics-drivers
sudo apt-add-repository -y ppa:remmina-ppa-team/remmina-next
sudo apt install -y curl
curl -fsS -o- https://deb.packages.mattermost.com/setup-repo.sh | sudo bash
sudo curl -sSfL https://packages.openvpn.net/packages-repo.gpg >/etc/apt/keyrings/openvpn.asc
sudo apt update -y

#Apt install programs
sudo apt install -y git terminator openssh-server python3-pip net-tools remmina remmina-plugin-rdp remmina-plugin-secret remmina-plugin-spice libgmock-dev google-chrome-stable apt-transport-https gnome-shell-extension-manager network-manager-openconnect-gnome mattermost-desktop

if [[ $os_release == "26.04" ]]; then
	if $ros
        then
            sh $SCRIPT_DIR/ROS/install_ros_one.sh
        fi
	if $ros2
	then
	    sh $SCRIPT_DIR/ROS/install_ros2_rolling.sh
	fi
elif [[ $os_release == "24.04" ]]; then
	if $ros
        then
            sh $SCRIPT_DIR/ROS/install_ros_one.sh
        fi
	if $ros2
	then
	    sh $SCRIPT_DIR/ROS/install_ros2_jazzy.sh
	fi
elif [[ $os_release == "22.04" ]]; then
	sudo apt install -y nm-connection-editor
	if $ros
        then
            sh $SCRIPT_DIR/ROS/install_ros_one.sh
        fi
	if $ros2
	then
	    sh $SCRIPT_DIR/ROS/install_ros2_humble.sh
	fi
elif [[ $os_release == "20.04" ]]; then
	sh $SCRIPT_DIR/install_2004_utils.sh
	sudo apt install -y exfat-utils
	if $ros
        then
            sh $SCRIPT_DIR/ROS/install_ros_noetic.sh
            sudo apt install -y python3-catkin*
        fi
	if $ros2
	then
	    sh $SCRIPT_DIR/ROS/install_ros2_foxy.sh
	fi
elif [[ $os_release == "18.04" ]]; then
	sudo apt install -y exfat-utils
	sudo apt install python-pip -y
	if $ros
	then
	    sh $SCRIPT_DIR/ROS/install_ros_melodic.sh
	    sudo apt install -y python-catkin-tools
	fi
elif [[ $os_release == "16.04" ]]; then
	sudo apt install -y exfat-utils
	sudo apt install python-pip -y
	if $ros
	then
	    sh $SCRIPT_DIR/ROS/install_ros_kinetic.sh
	    sudo apt install -y python-catkin-tools
	fi
else
	echo "Non-compatible version"
fi

#Apt install deb files
arch=$(uname -m | sed 's/x86_64/amd64/')
wget "https://zoom.us/client/latest/zoom_$arch.deb"
sudo apt install -y "./zoom_$arch.deb"

#Snap install programs
sudo snap install pycharm-community --classic
sudo snap install gitkraken --classic
sudo snap install code --classic

sudo apt autoremove -y
if $cuda; then
	if $reboot; then
		sh $SCRIPT_DIR/install_cuda.sh --reboot
	else
		sh $SCRIPT_DIR/install_cuda.sh
	fi
fi
