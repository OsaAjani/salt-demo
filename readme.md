Ips
===

Salt-Master
------

Le salt master doit avoir l'ip ```192.168.56.101```

Haproxy
------
Le haproxy doit avoir l'ip ```192.168.56.150```

DB
------
Les DB sont réparties sur la plage ```192.168.56.102-192.168.56.119```

Server App
----------

Les server-app sont réparties sur la place ```192.168.56.121-192.168.56.159```


Installer salt-master
===
Commencer par installer salt-master
```apt install salt-master```
Modifier le fichier /etc/salt/master pour configurer le pillars sur ```/srv/pillar/``` et le file_roots sur ```/srv/salt/```

Une fois fait, coller le contenu du dépot dans le dossier ```/srv/``` puis redémarrer salt-master.

Ajouter une machine DB
===

Sur la machine DB
------
Configurer une ip static sur eth1 dans la plage adaptée.

 1. Configurer le hostname selon le format suivant : ```echo 'minion-galera-<NUMERO>' > /etc/hostname && /etc/init.d/hostname.sh restart```
 2. Installer salt-minion : ```apt install salt-minion```
 3. Puis ajouter l'IP du master : ```sed -ie 's/#master: salt/master: 192.168.56.101/g' /etc/salt/minion```
 4. Redémarrer le salt-minion : ```/etc/init.d/salt-minion restart```

Sur le salt-master
------
 1. Modifier le fichier ```/srv/pillar/galera/init.sls``` et ajouter un nodes au format suivant :
```    minion-galera-<NUMERO>: 192.168.56.X``` (ou NUMERO = le numéro de cette machine et X = la bonne ip)
 2. Ajouter un grain sur la machine : ```salt 'minion-galera-<NUMERO>' grains.setval roles ['mariadb_slave']``` (si c'est la première machine, utiliser plutôt ```['mariadb_master']```).
 3. Configurer la machine : ```salt 'minion-galera-<NUMERO>' state.sls galera```
 4. Redémarrer la machine : ```salt 'minion-galera-<NUMERO>' cmd.run 'reboot'```
 
Sur le HAproxy
------
 4. Modifier le fichier ```/etc/haproxy/haproxy.cfg``` et ajouter une ligne au format suivant à la liste des IPs MySQL :
```server minion-galera-<NUMERO> 192.168.56.X:3306 check port 9200``` (ou NUMERO = le numéro de cette machine et X = la bonne ip)
 5. Re-charger le configuration de HAproxy : ```/etc/init.d/haproxy reload```

Ajouter une machine Server-App
===
Sur la machine Server-App
------
Configurer une ip static sur eth1 dans la plage adaptée.

 1. Configurer le hostname selon le format suivant : ```echo 'server-app-<NUMERO>' > /etc/hostname && /etc/init.d/hostname.sh restart```
 2. Installer salt-minion : ```apt install salt-minion```
 3. Puis ajouter l'IP du master : ```sed -ie 's/#master: salt/master: 192.168.56.101/g' /etc/salt/minion```
 4. Redémarrer le salt-minion : ```/etc/init.d/salt-minion restart```

Sur le salt-master
------
 1. Modifier le fichier ```/srv/pillar/galera/init.sls``` et ajouter un nodes au format suivant :
```    server-app-<NUMERO>: 192.168.56.X``` (ou NUMERO = le numéro de cette machine et X = la bonne ip)
 2. Configurer la nouvelle machine : ```salt 'server-app-*' state.sls server-app -l debug```
Sur le HAproxy
------
 1. Modifier le fichier ```/etc/haproxy/haproxy.cfg``` et ajouter une ligne au format suivant à la liste des IP server-app :
```server server-app-<NUMERO> 192.168.56.X:3306 check port 9200``` (ou NUMERO = le numéro de cette machine et X = la bonne ip) 
 2. Re-charger le configuration de HAproxy : ```/etc/init.d/haproxy reload```

Quelques cas particuliers
===
Démarrer le premier cluster
------
Pour démarrer le premier cluster, il faut lancer la commande ```/etc/init.d/mysql start --wsrep-new-cluster```.
Les autres se démarrent selon la commande normale.

Que faire quand tous les clusters tombent
------
Si tous les clusters tombent (genre panne de courant), il faut faire attention à ne pas perdre de transaction. 
Pour cela, il faut trouver le cluster ayant fait la dernière transaction. Pour cela, lancer sur chaque serveur la commande :
```cat /var/lib/mysql/grastate.dat```
Et trouver celui avec le plus grand UUID.

Une fois fait, lancez la commande suivante sur ce serveur : ```sed -ie 's/safe_to_bootstrap: 0/safe_to_bootstrap: 1/g' /var/lib/mysql/grastate.dat```
Puis redémarrer MySQL avec la commande ```/etc/init.d/mysql start --wsrep-new-cluster```.

Les autres serveurs peuvent maintenant être démarrés normalement.
