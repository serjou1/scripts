sudo apt update
sudo apt install git curl -y
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
\. "$HOME/.nvm/nvm.sh"
nvm install 22
npm i -g pm2 pnpm
pm2 install pm2-logrotate
pm2 ls
pm2 set pm2-logrotate:max_size 100M
pm2 set pm2-logrotate:rotateInterval '0 0 * * *'
pm2 set pm2-logrotate:dateFormat 'YYYY-MM-DD'
pm2 set pm2-logrotate:retain 14
