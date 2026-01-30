sudo apt update
sudo apt upgrade -y

sudo apt install redis-server -y

sudo systemctl enable redis-server
sudo systemctl start redis-server
sudo systemctl status redis-server
