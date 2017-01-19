#Ips
##Salt-Master
Le salt master doit avoir l'ip ```192.168.56.101```

##Haproxy
Le haproxy doit avoir l'ip ```192.168.56.101```

##NEW DB##

##########################################################
##Machine : Modifier hostname, ip, salt-minion/minion_id##
##########################################################
vi /etc/network/interfaces
#Modifier l'ip eth1
echo 'minion-galera-NUMERO' > /etc/hostname

reboot

sed -ie 's/#master: salt/master: 192.168.56.101/g' /etc/salt/minion
cat /etc/hostname > /etc/salt/minion_id
/etc/init.d/salt-minion restart

################################################################
##salt-master : Rajouter l'IP, rajouter grain, conf la machine##
################################################################
vi /srv/pillar/galera/init.sls
#Ajouter le node

salt-key -A

salt 'minion-galera-NUMERO' grains.setval roles ['mariadb_slave']
salt 'minion-galera-NUMERO' state.sls galera -l debug


###########################
##haproxy : Rajouter l'IP##
###########################
vi /etc/haproxy/haproxy.cfg
#ajouter l'ip
/etc/init.d/haproxy reload





##NEW FRONT##
##########################################################
##Machine : Modifier hostname, ip, salt-minion/minion_id##
##########################################################
vi /etc/network/interfaces
#Modifier l'ip eth1
echo 'server-app-NUMERO' > /etc/hostname

reboot

sed -ie 's/#master: salt/master: 192.168.56.101/g' /etc/salt/minion
cat /etc/hostname > /etc/salt/minion_id
/etc/init.d/salt-minion restart

################################################################
##salt-master : conf la machine##
################################################################
salt-key -A

salt 'server-app-*' state.sls server-app -l debug

###########################
##haproxy : Rajouter l'IP##
###########################
vi /etc/haproxy/haproxy.cfg
#ajouter l'ip
/etc/init.d/haproxy reload








#POUR RESTART TOUT LES CLUSTERS
cat /var/lib/mysql/grastate.dat
#sur celui avec le plus gros uuid
vi /var/lib/mysql/grastate.dat
#remplacer safe_to_bootstrap: 0 par safe_to_bootstrap: 1

/etc/init.d/mysql start --wsrep-new-cluster





#Check safe to bootstrap
mysqld_safe --wsrep-recover
cat /var/lib/mysql/grastate.dat

sed -ie 's/safe_to_bootstrap: 0/safe_to_bootstrap: 1/g' /var/lib/mysql/grastate.dat
