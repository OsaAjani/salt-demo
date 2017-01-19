mdb_cluster:
  name: test_cluster
  nodes:
    minion-galera-1: 192.168.56.102
    minion-galera-2: 192.168.56.103
    minion-galera-3: 192.168.56.104
    minion-galera-4: 192.168.56.105
    minion-galera-5: 192.168.56.106

mdb_cfg_files:
 
  ubuntu_cluster: 
    path: /etc/mysql/conf.d/cluster.cnf
    source: salt://galera/config/cluster.cnf
  ubuntu_maintenance: 
    path: /etc/mysql/debian.cnf
    source: salt://galera/config/debian.cnf
  
{% if grains['cpuarch'] == 'x86_64' %}
  {% set arch = 'amd64' %}
{% else %}
  {% set arch = 'x86' %}
{% endif %}

mdb_config:
{% if arch == 'amd64' %}
  provider: /usr/lib64/galera/libgalera_smm.so
{% else %}
  provider: /usr/lib/galera/libgalera_smm.so
{% endif %}

mdb_repo:
    baseurl: http://ftp.igh.cnrs.fr/pub/mariadb/repo/10.0/debian
    keyserver: hkp://keyserver.ubuntu.com:80
    keyid: '0xcbcb082a1bb943db'
    file: /etc/apt/sources.list

  
