#!/bin/bash

# Download and install chef-server
echo "Installing wget"
sudo yum install wget -y &> /dev/null

echo "Downloading chef-server-core"
wget https://packagecloud.io/chef/stable/packages/el/6/chef-server-core-12.3.1-1.el6.x86_64.rpm/download -O /tmp/chef-server-core-12.3.1-1.el6.x86_64.rpm &> /dev/null

echo "Installing chef-server-core via rpm"
sudo rpm -Uvh /tmp/chef-server-core-12.3.1-1.el6.x86_64.rpm &> /dev/null


# Replace {chef_server_fqdn} with the hostname
echo "Configuring chef-server.rb"
sudo su -c "sed -i \"s/server_name = .*\$/server_name = \'${chef_server_fqdn}\'/g\" /tmp/chef-server.rb"

# Move chef-server.rb to correct location
echo "Copying /tmp/chef-server.rb to /etc/opscode/chef-server.rb"
sudo cp /tmp/chef-server.rb /etc/opscode/chef-server.rb


# Configure Hostname
sudo hostname ${chef_server_fqdn}
sudo sed -i "s/HOSTNAME=.*$/HOSTNAME=${chef_server_fqdn}/" /etc/sysconfig/network


# Update /etc/hosts
echo "Updating /etc/hosts"
echo $(/sbin/ifconfig eth0 | /bin/awk '/inet addr:/ {print $2}' | /bin/grep -o [0-9.]*) ${chef_server_fqdn} | sudo tee -a /etc/hosts &> /dev/null


# Start server
echo "Starting chef-server"
sudo chef-server-ctl reconfigure > /tmp/chef-server.log
sudo chef-server-ctl status

if [ $? -ne 0 ]; then
    echo "Failed to start chef-server"
    exit 1
fi

# Optional - install Chef Management Console
#sudo chef-server-ctl install opscode-manage
#sudo chef-server-ctl reconfigure
#sudo opscode-manage-ctl reconfigure


# Optional - install Chef Reporting
#sudo chef-server-ctl install opscode-reporting
#sudo chef-server-ctl reconfigure
#sudo opscode-reporting-ctl reconfigure


# Create the admin account
sudo chef-server-ctl user-create ${admin_user_name} ${admin_first_name} ${admin_last_name} ${admin_email} ${admin_password} --filename ${admin_user_name}.pem


# Create the organization
sudo chef-server-ctl org-create ${org_short_name} "${org_full_name}" --association_user ${admin_user_name} --filename ${org_short_name}-validator.pem

# Disable iptables - TODO Add entry for port 443
sudo service iptables stop

# Clean up
rm -f /tmp/chef-server-core-*
#rm -f /tmp/chef-server.rb
#rm -f /tmp/chef-server.log
