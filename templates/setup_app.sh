#!/bin/bash

set -o errexit
set -o pipefail
set -x

cat <<-SYSTEMD_SERVICE > /etc/systemd/system/puma.service
[Unit]
Description=Puma HTTP Server
After=network.target

[Service]
Type=notify
WatchdogSec=10
User=${username}
WorkingDirectory=${app_path}
ExecStart=/usr/share/rvm/wrappers/ruby-${ruby_version}/puma -C ${app_path}/config/puma.rb
Restart=always

[Install]
WantedBy=multi-user.target
SYSTEMD_SERVICE

sudo -i -u "${username}" git clone ${app_repo} ${app_path}
sudo -i -u "${username}" /usr/share/rvm/wrappers/ruby-${ruby_version}/bundle install --gemfile=${app_path}/Gemfile --jobs=4
sudo -i -u "${username}" bash -c "cd ${app_path} && /usr/share/rvm/wrappers/ruby-${ruby_version}/rails tailwindcss:install"

systemctl daemon-reload
systemctl enable puma.service
systemctl start puma.service
