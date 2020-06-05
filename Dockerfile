FROM ubuntu:18.04

# PHP
RUN apt-get update -y \
	&& apt-get install software-properties-common -y \
	&& add-apt-repository ppa:ondrej/php -y \
	&& apt-get update -y \
	&& apt-get install php7.4-fpm -y

# Extensions
RUN apt-get update -y \
	&& apt-get install curl -y \
	&& apt-get install wget -y \
	&& apt-get install zip -y \
	&& apt-get install mysql-client -y \
	&& apt-get install php-mysql -y \
	&& apt-get install libpng-dev -y \
	&& apt-get install automake -y

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install WP-CLI
RUN apt-get update -y \
	&& curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp

# Neovim & tmux
RUN	apt-get update -y \
	&& add-apt-repository ppa:neovim-ppa/stable -y \
	&& apt-get update -y \
	&& apt-get install neovim -y \
	&& apt-get install python-dev python-pip python3-dev python3-pip -y \
	&& update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60 \
	&& pip3 install neovim \
	&& apt-get install tmux -y

# Other CLIs
RUN apt-get update -y \
	&& apt-get install nano -y \
	&& apt-get install git -y \
	&& apt-get install rsync -y \
	&& apt-get install pv -y \
	&& curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.35.2/install.sh | bash \
	&& export NVM_DIR="$HOME/.nvm" \
	&& [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
	&& [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" \
	&& nvm install node \
	&& nvm install v12.18.0 \
	&& nvm alias default v12.18.0 \
	&& npm install gulp -g \
	&& npm install eslint -g \
	&& npm install prettier -g \
	&& npm install stylelint -g

# ZSH
RUN apt-get update -y \
	&& apt-get install zsh -y \
	&& bash -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" \
	&& rm /root/.zshrc

# PHPCS
RUN	apt-get update -y \
	&& apt-get install php-xml -y \
	&& composer global require "squizlabs/php_codesniffer=3.*" \
	&& mkdir /utilities \
	&& cd /utilities \
	&& git clone https://github.com/PHPCompatibility/PHPCompatibility.git \
	&& cd PHPCompatibility \
	&& git checkout tags/9.3.5 \
	&& cd /utilities \
	&& git clone https://github.com/WordPress-Coding-Standards/WordPress-Coding-Standards.git \
	&& cd WordPress-Coding-Standards \
	&& git checkout tags/2.3.0

RUN /root/.composer/vendor/bin/phpcs --config-set installed_paths /utilities/WordPress-Coding-Standards,/utilities/PHPCompatibility
COPY custom-scripts/global-scripts.zsh /root/custom-scripts/global-scripts.zsh
COPY custom-scripts/setup-scripts.zsh /root/custom-scripts/setup-scripts.zsh
COPY custom-scripts/init.vim /root/.config/nvim/init.vim
COPY custom-scripts/.tmux.conf /root/.tmux.conf
COPY custom-scripts/.zshrc /root/.zshrc

RUN ln -s /root/.nvm/versions/node/v12.18.0/bin/node /usr/bin/node \
	&& ln -s /root/.nvm/versions/node/v12.18.0/bin/npm /usr/bin/npm \
	&& ln -s /root/.nvm/versions/node/v12.18.0/bin/yarn /usr/bin/yarn \
	&& ln -s /root/.nvm/versions/node/v12.18.0/bin/gulp /usr/bin/gulp \
	&& ln -s /root/.nvm/versions/node/v12.18.0/bin/grunt /usr/bin/grunt \
	&& ln -s /usr/local/bin/wp /usr/bin/wp-cli

# Misc.
RUN apt-get --purge autoremove -y

WORKDIR /var/www/public_html
