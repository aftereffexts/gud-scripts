#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Gimme some root access"
  exit 1
fi

# HINT: You nodes should be all installed the same and be able to communicate with each other
# In my case, I have 3 nodes, installed on Debian 12 Bookworm
# setting ur variables for 3 nodes and the script goes whoo
NODE1="10.200.0.4"
NODE2="10.200.0.2"
NODE3="10.200.0.3"
CLUSTERNAME="XXXX-APP-Cluster"
#Gateway
NETGW="10.200.0.1"
NETMASK="255.255.255.0"
#primary DNS, secondary DNS
NETDNS="10.200.0.11,8.8.8.8"


NODE1_HOSTNAME="srv-vm-node1-db01"
NODE2_HOSTNAME="srv-vm-node2-db01"
NODE3_HOSTNAME="srv-vm-node3-db01"

# change Variables to your own passwords
USERPW="URUSERPW"
ROOTPW="URROOTPW"


echo "Changing passwords from default"
    chpasswd <<<"administrator:$USERPW"
    chpasswd <<<"root:$ROOTPW"



echo "disable ipv6"

echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
sysctl -p


if [ "$HOSTNAME" = "$NODE1_HOSTNAME" ]; then
printf '%s\n' "on the right host ($HOSTNAME)"
    rm /etc/network/interfaces

    cat <<EOF > /etc/network/interfaces
    source /etc/network/interfaces.d/*

    #loopback interface
    auto lo
    iface lo inet loopback

    allow-hotplug ens192
    iface ens192 inet static
            address $NODE1
            netmask $NETMASK
            gateway $NETGW
    dns-nameservers $NETDNS
EOF

elif [ "$HOSTNAME" = "$NODE2_HOSTNAME" ]; then
printf '%s\n' "on the right host ($HOSTNAME)"
    rm /etc/network/interfaces

    cat <<EOF > /etc/network/interfaces
    source /etc/network/interfaces.d/*

    #loopback interface
    auto lo
    iface lo inet loopback

    allow-hotplug ens192
    iface ens192 inet static
            address $NODE2
            netmask $NETMASK
            gateway $NETGW
    dns-nameservers $NETDNS
EOF

elif [ "$HOSTNAME" = "$NODE3_HOSTNAME" ]; then
printf '%s\n' "on the right host ($HOSTNAME)"
    rm /etc/network/interfaces

    cat <<EOF > /etc/network/interfaces
    source /etc/network/interfaces.d/*

    #loopback interface
    auto lo
    iface lo inet loopback

    allow-hotplug ens192
    iface ens192 inet static
        address $NODE3
        netmask $NETMASK
        gateway $NETGW
    dns-nameservers $NETDNS
EOF

else
    printf '%s\n' "uh-oh, wrong host ($HOSTNAME)"
fi

apt update && apt upgrade -y

echo "Installing some essential packages"

apt install net-tools curl -y

curl -LsS -O https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
sudo bash mariadb_repo_setup --mariadb-server-version=10.11.6

apt install mariadb-server mariadb-client
Y 
printf "\r\n"

echo "setting mysql_secure_installation up"
echo "Y" | mysql_secure_installation <<EOF

printf "\r\n"
Y
printf "\r\n"
N
Y
Y
Y
Y
EOF

if [ "$HOSTNAME" = "$NODE1_HOSTNAME" ]; then
    printf '%s\n' "on the right host ($HOSTNAME)"
    rm /etc/mysql/mariadb.conf.d/50-server.cnf
    cat <<EOF > /etc/mysql/mariadb.conf.d/50-server.cnf
[server]
[mysqld]
pid-file                = /run/mysqld/mysqld.pid
basedir                 = /usr
#bind-address            = 127.0.0.1
expire_logs_days        = 10
character-set-server  = utf8mb4
collation-server      = utf8mb4_general_ci
[embedded]
[mariadb]
[mariadb-10.11]
[galera]
wsrep_on=ON
wsrep_provider=/usr/lib/galera/libgalera_smm.so
wsrep_cluster_address=gcomm://
binlog_format=row
default_storage_engine=InnoDB
innodb_autoinc_lock_mode=2
bind-address=0.0.0.0
wsrep_cluster_name="ITCares-APP-Cluster"
wsrep_node_address="$NODE1"
EOF
    elif [ "$HOSTNAME" = "$NODE2_HOSTNAME" ]; then
        printf '%s\n' "on the right host ($HOSTNAME)"
        rm /etc/mysql/mariadb.conf.d/50-server.cnf
        cat <<EOF > /etc/mysql/mariadb.conf.d/50-server.cnf
[server]
[mysqld]
pid-file                = /run/mysqld/mysqld.pid
basedir                 = /usr
#bind-address            = 127.0.0.1
expire_logs_days        = 10       
character-set-server  = utf8mb4
collation-server      = utf8mb4_general_ci
[embedded]
[mariadb]
[mariadb-10.11]
[galera]
wsrep_on=ON
wsrep_provider=/usr/lib/galera/libgalera_smm.so
# Specify cluster nodes
wsrep_cluster_address="gcomm://$NODE1,$NODE2,$NODE3"
binlog_format=row
default_storage_engine=InnoDB
innodb_autoinc_lock_mode=2
bind-address=0.0.0.0
wsrep_cluster_name="$CLUSTERNAME"
wsrep_node_address="$NODE2"
EOF
elif [ "$HOSTNAME" = "$NODE3_HOSTNAME" ]; then
    printf '%s\n' "on the right host ($HOSTNAME)"
    rm /etc/mysql/mariadb.conf.d/50-server.cnf
    cat <<EOF > /etc/mysql/mariadb.conf.d/50-server.cnf
[server]

[mysqld]

pid-file                = /run/mysqld/mysqld.pid
basedir                 = /usr

#bind-address            = 127.0.0.1


expire_logs_days        = 10

character-set-server  = utf8mb4
collation-server      = utf8mb4_general_ci


[embedded]

[mariadb]

[mariadb-10.11]

[galera]
wsrep_on=ON
wsrep_provider=/usr/lib/galera/libgalera_smm.so
# Specify cluster nodes
wsrep_cluster_address="gcomm://$NODE1,$NODE2,$NODE3"
binlog_format=row
default_storage_engine=InnoDB
innodb_autoinc_lock_mode=2
bind-address=0.0.0.0
wsrep_cluster_name="$CLUSTERNAME"
wsrep_node_address="$NODE3"
EOF
else
    printf '%s\n' "uh-oh, wrong host ($HOSTNAME)"
fi

systemctl restart networking

if [ "$HOSTNAME" = "$NODE1_HOSTNAME" ]; then
galera_new_cluster
elif [ "$HOSTNAME" = "$NODE2_HOSTNAME" ]; then
systemctl start mariadb
elif [ "$HOSTNAME" = "$NODE3_HOSTNAME" ]; then
systemctl start mariadb
else
    printf '%s\n' "uh-oh, wrong host ($HOSTNAME)"
fi



echo "MariaDB Galera 10.11.6 installed successfully"

echo "Show SQL integrity & status"
mysql -e "SHOW GLOBAL STATUS LIKE 'wsrep_cluster_size'"
mysql -e "SHOW GLOBAL STATUS LIKE 'wsrep_%';"

echo "Well done Script Created by git/aftereffexts"