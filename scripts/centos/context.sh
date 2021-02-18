# Install opennebula context package
rpm -Uvh /mnt/one-context*rpm

# Remove NetworkManager
yum remove -y NetworkManager

# Install growpart and upgrade util-linux, used for filesystem resizing
yum install -y epel-release --nogpgcheck
yum install -y cloud-utils-growpart --nogpgcheck
yum upgrade -y util-linux --nogpgcheck

# Install ruby for onegate tool
yum install -y ruby