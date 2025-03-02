sudo apt update
sudo apt install git curl -y
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
\. "$HOME/.nvm/nvm.sh"
nvm install 22
npm i -g pm2 pnpm
