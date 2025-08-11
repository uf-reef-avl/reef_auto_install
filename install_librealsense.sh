print_help() {
  echo "Usage: $0 [--dev]"
  echo "Options:"
  echo "  --dev   Install the development branch from the librealsense github repository"
  echo "  --release   Install the release packages from the librealsense apt repos"
}
develop=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dev)
      develop=true
      shift
      ;;
    --release)
      develop=false
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

if [ $# -eq 0 ]; then
	read -p "Would you like to install the release branch of librealsense? (n for development) [Y/n]: " yn
	case $yn in
		[Yy]* ) develop=false;;
		[Nn]* ) develop=true;;
		"" ) develop=false;;
		* ) develop=false;;
	esac
fi

if [[ "$develop" == "true" ]]; then
    cd ~
    sudo apt install -y libssl-dev libusb-1.0-0-dev libudev-dev pkg-config libgtk-3-dev git wget cmake build-essential libglfw3-dev libgl1-mesa-dev libglu1-mesa-dev at
    git clone https://github.com/IntelRealSense/librealsense.git
    cd librealsense
    git checkout development
    ./scripts/setup_udev_rules.sh
    ./scripts/patch-realsense-ubuntu-lts-hwe.sh
    mkdir build
    cd build
    cmake ../
    make -j 6
    sudo make install
    cd ~
    rm -rf ~/librealsense/
else
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE
    sudo add-apt-repository "deb https://librealsense.intel.com/Debian/apt-repo $(lsb_release -cs) main" -u -y
    sudo apt-get install librealsense2-dkms librealsense2-utils librealsense2-dev librealsense2-dbg -y
fi
