#!/bin/bash 
# Fonction permettant d'installer et de créer un server Apache
installApacheServer(){
    apt-get update
    apt install wget apache2 php php-mysql php-xml mariadb-server -y
    echo "Installation terminée"
}

function site()
{
    echo "Où souhaitez-vous créer votre site :
╔═══════════════════════╗
║ 1) dans /var/www/html ║  
║ 2) autre              ║
╚═══════════════════════╝"

	read -r choixsite

	if [[ $choixsite == 1 ]]
	then
		echo "saisir le nom du site avec son extention (ex: .html , .php)"
		read -r site
		echo "$site" > /var/www/html/"$site"

	elif [[ $choixsite == 2 ]]
	then
		echo "saisir le chemin absolue de l'emplacement du futur site (ex : /r1/r2/.../...) "
		read -r chemin_site
		mkdir -p "$chemin_site"
		echo "saisir le nom du site avec son extention (ex: .html , .php)"
		read -r site
		echo "$site" > "$chemin_site"/"$site"
		echo "voulez vous changer l'ip ou le port d'acces au site ?
		1) oui
		2) non"
		read -r rep
		if [[ $rep == 1 ]]
		then
			echo "que voulez vous faire ?
			1)changer l'ip
			2)changer l'ip et le port"
			read -r decision
			if [[ $decision == 1 ]]
			then
				port=""
				portlien=":80"
				echo "saisir l'adresse voulu"
				read -r chemin_ip
				echo "
auto enp0s3
iface enp0s3 inet static
	address $chemin_ip
	netmask 255.255.255.0" >> /etc/network/interfaces
				service networking restart

			elif [[ $decision == 2 ]]
			then
				port=""
				portlien=:
				echo "saisir l'adresse voulu"
				read -r chemin_ip
				echo "saisir port voulu"
				read -r chemin_port
				port+="Listen $chemin_port"
				portlien+=$chemin_port
				echo "
auto enp0s3
iface enp0s3 inet static
	address $chemin_ip
	netmask 255.255.255.0" >> /etc/network/interfaces
				service networking restart
			fi
		elif [[ $rep == 2 ]]
		then
			chemin_ip="*"
			port=""
			portlien=:80
		fi
		echo "voulez vous ajouter un alias ?
		1) oui
		2) non"
		read -r rep2
		if [[ $rep2 == 1 ]]
		then
			alias="Alias "
			echo "saisir l'alias voulu (ex: /monsite)"
			read -r repalias
			alias+="$repalias $chemin_site"
			echo "voulez vous ajouter l'acces au site à un certain utilisateur ?
			1) oui
			2) non"
			read -r rep3
			if [[ $rep3 == 1 ]]
			then
				echo "saisir le nom de l'utilisateur"
				read -r utilisateur
				echo "saisir le MDP de l'utilisateur"
				read -r mdp
				touch /etc/apache2/mes.mdp
				apt install whois -y
				echo "$utilisateur":"$(mkpasswd "$mdp")" >> /etc/apache2/mes.mdp
				echo "$port
<VirtualHost $chemin_ip$portlien>
        
		$alias
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html
		<Directory $chemin_site>
			DirectoryIndex $site
			AuthName TexteDansLaFenetre
			AuthType Basic
			AuthUserFile /etc/apache2/mes.mdp
			Require valid-user
		</Directory>
		

       

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        
</VirtualHost>" > /etc/apache2/sites-available/"$site".conf
				a2ensite "$site".conf
				a2dissite 000-default.conf
				service apache2 restart
				elif [[ $rep3 == 2 ]]
				then
					echo "$port
<VirtualHost $chemin_ip$portlien>
        
		$alias
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html
		<Directory $chemin_site>
			DirectoryIndex $site
		</Directory>
		

       

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        
</VirtualHost>" > /etc/apache2/sites-available/"$site".conf
				a2ensite "$site".conf
				a2dissite 000-default.conf
				service apache2 restart
		fi
		elif [[ $rep2 == 2 ]]
		then
			alias=""
			echo "voulez vous ajouter l'acces au site à un certain utilisateur ?
			1) oui
			2) non"
			read rep3
			if [[ $rep3 == 1 ]]
			then
				echo "saisir le nom de l'utilisateur"
				read utilisateur
				echo "saisir le MDP de l'utilisateur"
				read mdp
				touch /etc/apache2/mes.mdp
				apt install whois -y
				echo "$utilisateur":"$(mkpasswd "$mdp")" >> /etc/apache2/mes.mdp
				echo "$port
<VirtualHost $chemin_ip$portlien>
        
		$alias
        ServerAdmin webmaster@localhost
        DocumentRoot $chemin_site
		<Directory $chemin_site>
			DirectoryIndex $site
			AuthName TexteDansLaFenetre
			AuthType Basic
			AuthUserFile /etc/apache2/mes.mdp
			Require valid-user
		</Directory>
		

       

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        
</VirtualHost>" > /etc/apache2/sites-available/"$site".conf
				a2ensite "$site".conf
				a2dissite 000-default.conf
				service apache2 restart
			elif [[ $rep3 == 2 ]]
			then
				echo "$port
<VirtualHost $chemin_ip$portlien>
        
		$alias
        ServerAdmin webmaster@localhost
        DocumentRoot $chemin_site
		<Directory $chemin_site>
			DirectoryIndex $site
		</Directory>
		

       

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        
</VirtualHost>" > /etc/apache2/sites-available/"$site".conf
				a2ensite "$site".conf
				a2dissite 000-default.conf
				service apache2 restart
			fi
		fi
		
		echo "Création du site terminer"
	fi
	echo "Voulez-vous créer un autre site ?
		1)Oui
		------
		2)Non"
	read -r new_site
	if [[ $new_site == 1 ]]
    then
        site
    elif [[ $new_site == 2 ]]
    then
        acceuil
    else
        acceuil
    fi
}

ipSet(){
    echo "Que voulez vous faire : 
1 - Installer IpSet
2 - Création d'une liste ipSet
3 - Ajout d'une ip à votre liste
4 - Retirer une ip de votre liste
5 - Informations sur une liste précise
IPTABLES :
    6 - Ajouter une règle pour ICMP/TCP/all :
    7 - Blocage des trames ssh
    8 - Blocage des trames sur un port choisi
    9 - Blocage des trames sur un intervalle
    10 - Supprimer une règle"
    read -r choice
    if [[ $choice == 1 ]]
    then
        apt-get install ipset iptables -y
        mkdir /dossierDesZones
        echo "for S in \$(cat /dossierDesZones/be.zone)
    do
    ipset add maliste $S
    done" > /scriptDesZones.sh
    echo "Installation terminée :
    ╔══════════════════════════════════════╗
    ║ - Dossier /dossierDesZones créé à la ║
    ║ racine.                              ║
    ║ - scriptDesZones.sh créé à la racine ║
    ╚══════════════════════════════════════╝"
    elif [[ $choice == 2 ]]
    then
        echo "Voici vos listes :"
        ipset list -n
        echo "Quel est le nom de votre liste ?" 
        read -r nomListe
        ipset create "$nomListe" hash:net
    elif [[ $choice == 3 ]]
    then
        echo "Voici vos listes :"
        ipset list -n
        echo "Quel est le nom de votre liste ?" 
        read -r nomListe
        echo "Quelle ip voulez-vous ajouter ?" 
        read -r ipAdd
        ipset add "$nomListe" "$ipAdd"
    elif [[ $choice == 4 ]]
    then
        echo "Voici vos listes :"
        ipset list -n
        echo "Quel est le nom de votre liste ?" 
        read -r nomListe
        ipset list "$nomListe"
        echo "Quelle ip voulez-vous retirer ?" 
        read -r ipDel
        ipset del "$nomListe" "$ipDel"
    elif [[ $choice == 5 ]]
    then
        echo "Voici vos listes :"
        ipset list -n
        echo "Quelle liste voulez-vous voir ?"
        read -r nomListe
        ipset list "$nomListe"
    elif [[ $choice == 6 ]]
    then
        echo "Voici vos listes :"
        ipset list -n
        echo "A quelle liste voulez-vous ajouter une règle ?"
        read -r nomListe
        echo "Veuillez choisir le protocole : ICMP/tcp/all"
        read -r protocole
        echo "Souhaitez-vous bloquer toutes les trames sauf pour la liste (1)
    ou bloquer toutes les trames (2)"
        read -r choice
        if [[ $choice == 1 ]]
        then
            iptables -A INPUT -p "$protocole" -m set ! --match-set maliste src -j DROP
            echo "Voici les règles actives sur votre liste $nomListe"
            iptables -L --line-numbers | grep "$nomListe"
        elif [[ $choice == 2 ]]
        then
            iptables -A INPUT -p "$protocole" -m set --match-set maliste src -j DROP
            echo "Voici les règles actives sur votre liste $nomListe"
            iptables -L --line-numbers | grep "$nomListe"
        else
            echo "Erreur de saisie"
        fi
    elif [[ $choice == 7 ]]
    then
        echo "Voici vos listes :"
        ipset list -n
        echo "A quelle liste voulez-vous ajouter cet règle ?"
        read -r nomListe
        iptables -A INPUT -p tcp --dport ssh -m set --match-set "$nomListe" src -j DROP
        echo "Voici les règles actives sur votre liste $nomListe"
        iptables -L --line-numbers | grep "$nomListe"
    elif [[ $choice == 8 ]]
    then
        echo "Voici vos listes :"
        ipset list -n
        echo "A quelle liste voulez-vous ajouter cet règle ?"
        read -r nomListe
        echo "Sur quel port activer cette règle ?"
        read -r numPort
        iptables -A INPUT -p tcp --dport "$numPort" -m set --match-set "$nomListe" src -j DROP
        echo "Voici les règles actives sur votre liste $nomListe"
        iptables -L --line-numbers | grep "$nomListe"
    elif [[ $choice == 9 ]]
    then
        echo "Voici vos listes :"
        ipset list -n
        echo "A quelle liste voulez-vous ajouter cet règle ?"
        read -r nomListe
        echo "Quel intervalle souhaitez-vous ? (debut:fin)"
        read -r intervalle
        iptables -A INPUT -p tcp --dport "$intervalle" -m set --match-set "$nomListe" src -j DROP
        echo "Voici les règles actives sur votre liste $nomListe"
        iptables -L --line-numbers | grep "$nomListe"
    elif [[ $choice == 10 ]]
    then
        echo "Voici vos listes :"
        ipset list -n
        echo "A quelle liste voulez-vous supprimer une règle ?"
        read -r nomListe
        echo "Voici les règles actives sur votre liste $nomListe"
        iptables -L --line-numbers | grep "$nomListe"
        echo "Quelle règle dois être supprimée ?"
        read -r numRegle
        iptables -D INPUT "$numRegle"
        echo "Règle N° $numRegle supprimée"
    else
        echo "Erreur de saisie"
    fi
}

function CMS()
{
    echo "Quel CMS souhaitez-vous installer ?
╔══════════════════╗
║ 1 - Dokuwiki     ║
║ 2 - Mediawiki    ║
║ 3 - GLPI         ║
║ 4 - Joomla       ║
║ 5 - Wordpress    ║
║ 6 - PhpBB 3.3.5  ║
║ 7 - PhpBB 3.3.10 ║
║ 8 - GnuSocial    ║
║ 9 - Drupal       ║
║ 10 - Prestashop  ║
║ Autre - Fin      ║
╚══════════════════╝"
	
	read -r choixapp
	
	if [[ $choixapp == 1 ]]
	then
		apt update
		apt install wget php -y
		cd /var/www/html
		wget  --user eleve --password educator https://www.pedagogeek.fr/cours/srvweb/Ressources/appliweb/dokuwiki-a6b3119b5d16cfdee29a855275c5759f.tgz 
		tar -xzf /var/www/html/dokuwiki-a6b3119b5d16cfdee29a855275c5759f.tgz
		rm -r /var/www/html/dokuwiki-a6b3119b5d16cfdee29a855275c5759f.tgz
		chown www-data:www-data -R /var/www/html/dokuwiki
		echo "<VirtualHost *:80>
        

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html/dokuwiki
		DirectoryIndex doku.php

       

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        
</VirtualHost>" > /etc/apache2/sites-available/dokuwiki.conf
		a2ensite dokuwiki.conf
		a2dissite 000-default.conf
		service apache2 restart
		echo "
╔═══════════════════════════════════╗
║ Installation de Dokuwiki terminée ║
╚═══════════════════════════════════╝"
	elif [[ $choixapp == 2 ]]
	then
		apt update
		apt install wget php-mbstring php-intl mariadb-server php php-xmlrpc php-mysql php-xml unzip -y
		cd /var/www/html
		wget  --user eleve --password educator https://pedagogeek.fr/cours/srvweb/Ressources/appliweb/mediawiki-1.39.2.zip 
		unzip /var/www/html/mediawiki-1.39.2.zip
		mv /var/www/html/mediawiki-1.39.2 /var/www/html/mediawiki
		rm -r /var/www/html/mediawiki-1.39.2.zip
		chown www-data:www-data -R /var/www/html/mediawiki
		mysql -e "create database bddMW;create user \"admin\"@\"localhost\" IDENTIFIED BY \"btsinfo\";grant all privileges on bddMW.* to \"admin\"@\"localhost\";"
		echo "<VirtualHost *:80>
        

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html/mediawiki
		

       

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        
</VirtualHost>" > /etc/apache2/sites-available/mediawiki.conf
		a2ensite mediawiki.conf
		a2dissite 000-default.conf
		service apache2 restart
		echo "
╔════════════════════════════════════╗
║ Installation de Mediawiki terminée ╚═════════════════════════════════════════╗
║ Le nom de l'utilisateur est 'admin', le MDP est 'btsinfo', la BDD : 'bddMW'  ║
╚══════════════════════════════════════════════════════════════════════════════╝"
	elif [[ $choixapp == 3 ]]
	then
		apt update
		apt install wget php php-mysqli php-mbstring php-curl php-gd php-simplexml php-intl php-ldap php-apcu php-xmlrpc php-zip php-bz2 mariadb-server -y
		cd /var/www/html
		wget --user eleve --password educator https://pedagogeek.fr/cours/srvweb/Ressources/appliweb/glpi-10.0.6.tgz 
		tar -xzf /var/www/html/glpi-10.0.6.tgz
		rm -r /var/www/html/glpi-10.0.6.tgz
		chown www-data:www-data -R /var/www/html/glpi
		mysql -e "create database bddGLPI;create user \"admin\"@\"localhost\" IDENTIFIED BY \"btsinfo\";grant all privileges on bddGLPI.* to \"admin\"@\"localhost\";"
		echo "<VirtualHost *:80>
        

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html/glpi
		

       

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        
</VirtualHost>" > /etc/apache2/sites-available/glpi.conf
		a2ensite glpi.conf
		a2dissite 000-default.conf
		service apache2 restart
		echo "
╔═══════════════════════════════╗
║ Installation de GLPI terminée ╚═══════════════════════════════════════════════╗
║ Le nom de l'utilisateur est 'admin', le MDP est 'btsinfo', la BDD : 'bddGLPI' ║
╚═══════════════════════════════════════════════════════════════════════════════╝"
	elif [[ $choixapp == 4 ]]
	then
		apt update
		apt install wget php php-mysqli php-intl php-curl mariadb-server unzip php-xml -y
		mkdir /var/www/html/joomla
		cd /var/www/html/joomla
		wget --user eleve --password educator https://pedagogeek.fr/cours/srvweb/Ressources/appliweb/Joomla_4.2.9-Stable-Full_Package.zip 
		unzip /var/www/html/joomla/Joomla_4.2.9-Stable-Full_Package.zip
		rm -r /var/www/html/joomla/Joomla_4.2.9-Stable-Full_Package.zip
		chown www-data:www-data -R /var/www/html/joomla
		mysql -e "create database bddJoomla;create user \"admin\"@\"localhost\" IDENTIFIED BY \"btsinfo\";grant all privileges on bddJoomla.* to \"admin\"@\"localhost\";"
		echo "<VirtualHost *:80>
        

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html/joomla
		

       

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        
</VirtualHost>" > /etc/apache2/sites-available/joomla.conf
		a2ensite joomla.conf
		a2dissite 000-default.conf
		service apache2 restart
		echo "
╔═════════════════════════════════╗
║ Installation de Joomla terminée ╚══════════════════════════════════════════════╗
║ Le nom de l'utilisateur est 'admin', le MDP est 'btsinfo', la BDD : 'bddJoomla'║
╚════════════════════════════════════════════════════════════════════════════════╝"
	elif [[ $choixapp == 5 ]]
	then
		apt update
		apt install wget php php-mysqli mariadb-server unzip -y
		cd /var/www/html
		wget -P /var/www/html/ --user eleve --password educator https://pedagogeek.fr/cours/srvweb/Ressources/appliweb/wordpress-6.1.1-fr_FR.zip 
		unzip /var/www/html/wordpress-6.1.1-fr_FR.zip
		rm -r /var/www/html/wordpress-6.1.1-fr_FR.zip
		chown www-data:www-data -R /var/www/html/wordpress
		mysql -e "create database bddWP;create user \"admin\"@\"localhost\" IDENTIFIED BY \"btsinfo\";grant all privileges on bddWP.* to \"admin\"@\"localhost\";"
		echo "<VirtualHost *:80>
        

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html/wordpress
		

       

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        
</VirtualHost>" > /etc/apache2/sites-available/wordpress.conf
		a2ensite wordpress.conf
		a2dissite 000-default.conf
		service apache2 restart
		echo "
╔════════════════════════════════════╗
║ Installation de WordPress terminée ╚═════════════════════════════════════════╗
║ Le nom de l'utilisateur est 'admin', le MDP est 'btsinfo', la BDD : 'bddWP ' ║
╚══════════════════════════════════════════════════════════════════════════════╝"
	elif [[ $choixapp == 6 ]]
	then
		apt update
		apt install wget php php-mysqli mariadb-server php-mbstring unzip php-xml -y
		cd /var/www/html
		wget --user eleve --password educator https://pedagogeek.fr/cours/srvweb/Ressources/appliweb/phpBB-3.3.5.zip 
		unzip /var/www/html/phpBB-3.3.5.zip
		rm -r /var/www/html/phpBB-3.3.5.zip
		chown www-data:www-data -R /var/www/html/phpBB3
		mysql -e "create database bddPhpBB335;create user \"admin\"@\"localhost\" IDENTIFIED BY \"btsinfo\";grant all privileges on bddPhpBB335.* to \"admin\"@\"localhost\";"
		echo "<VirtualHost *:80>
        

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html/phpBB3
		

       

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        
</VirtualHost>" > /etc/apache2/sites-available/phpbb.conf
		a2ensite phpbb.conf
		a2dissite 000-default.conf
		service apache2 restart
		echo "
╔══════════════════════════════════════╗
║ Installation de PhpBB_3.3.5 terminée ╚════════════════════════════════════════════╗
║ Le nom de l'utilisateur est 'admin', le MDP est 'btsinfo', la BDD : 'bddPhpBB335' ║
╚═══════════════════════════════════════════════════════════════════════════════════╝"
	elif [[ $choixapp == 7 ]]
	then
		apt update
        apt install wget php php-mysqli mariadb-server php-mbstring unzip php-xml -y
		cd /var/www/html
		wget --user eleve --password educator https://pedagogeek.fr/cours/srvweb/Ressources/appliweb/phpBB-3.3.10_FR.zip
		unzip /var/www/html/phpBB-3.3.10_FR.zip
		rm -r /var/www/html/phpBB-3.3.10_FR.zip
		chown www-data:www-data -R /var/www/html/phpBB3
		mysql -e "create database bddPhpBB3310;create user \"admin\"@\"localhost\" IDENTIFIED BY \"btsinfo\";grant all privileges on bddPhpBB3310.* to \"admin\"@\"localhost\";"
		echo "<VirtualHost *:80>
        

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html/gnu-social/public
		

       

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        
</VirtualHost>" > /etc/apache2/sites-available/gnu.conf
		a2ensite gnu.conf
		a2dissite 000-default.conf
		service apache2 restart
		echo "
╔═══════════════════════════════════════╗
║ Installation de PhpBB_3.3.10 terminée ╚════════════════════════════════════════════╗
║ Le nom de l'utilisateur est 'admin', le MDP est 'btsinfo', la BDD : 'bddPhpBB3310' ║
╚════════════════════════════════════════════════════════════════════════════════════╝"
	elif [[ $choixapp == 8 ]]
	then
		apt update
		apt install wget php mariadb-server openssl php-curl php-exif php-gd php-intl php-json php-mbstring php-mysql php-gmp php-bcmath php-opcache php-readline php-xml -y
		cd /var/www/html
		wget --user eleve --password educator https://pedagogeek.fr/cours/srvweb/Ressources/appliweb/gnu-social-master.tar.gz
		tar -xzf /var/www/html/gnu-social-master.tar.gz
		rm -r /var/www/html/gnu-social-master.tar.gz
		chown www-data:www-data -R /var/www/html/gnu-social
        chmod -R 777 /var/www/html/gnu-social
		mysql -e "create database bddGnuS;create user \"admin\"@\"localhost\" IDENTIFIED BY \"btsinfo\";grant all privileges on bddGnuS.* to \"admin\"@\"localhost\";"
		echo "<VirtualHost *:80>
        

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html/gnu-social/public
		

       

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        
</VirtualHost>" > /etc/apache2/sites-available/gnu.conf
		a2ensite gnu.conf
		a2dissite 000-default.conf
		service apache2 restart
		echo "
╔════════════════════════════════════╗
║ Installation de GnuSocial terminée ╚══════════════════════════════════════════╗
║ Le nom de l'utilisateur est 'admin', le MDP est 'btsinfo', la BDD : 'bddGnuS' ║
╚═══════════════════════════════════════════════════════════════════════════════╝"
	elif [[ $choixapp == 9 ]]
	then
		apt install wget mariadb-server mariadb-client php libapache2-mod-php php-cli php-fpm php-json php-common php-mysql php-zip php-gd php-intl php-mbstring php-curl php-xml php-pear php-tidy php-soap php-bcmath php-xmlrpc  -y
		cd /var/www/html
		wget --user eleve --password educator https://pedagogeek.fr/cours/srvweb/Ressources/appliweb/drupal-10.0.7.tar.gz
		tar -xzf /var/www/html/drupal-10.0.7.tar.gz
		rm -r /var/www/html/drupal-10.0.7.tar.gz
		chown www-data:www-data -R /var/www/html/drupal-10.0.7
		mysql -e "create database bddDrupal;create user \"admin\"@\"localhost\" IDENTIFIED BY \"btsinfo\";grant all privileges on bddDrupal.* to \"admin\"@\"localhost\";"
		echo "<VirtualHost *:80>
        

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html/drupal-10.0.7/public
		

       

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        
</VirtualHost>" > /etc/apache2/sites-available/drupal.conf
		a2ensite drupal.conf
		a2dissite 000-default.conf
		service apache2 restart
		echo "
╔═════════════════════════════════╗
║ Installation de Drupal terminée ╚═══════════════════════════════════════════════╗
║ Le nom de l'utilisateur est 'admin', le MDP est 'btsinfo', la BDD : 'bddDrupal' ║
╚═════════════════════════════════════════════════════════════════════════════════╝"
	elif [[ $choixapp == 10 ]]
	then
		apt update
		apt install wget mysql-server mysql-client php libapache2-mod-php php-mysql php-curl php-gd php-intl php-mbstring php-soap php-xml php-zip unzip -y
        mkdir /var/www/html/prestashop
        cd /var/www/html/prestashop
		wget --user eleve --password educator https://pedagogeek.fr/cours/srvweb/Ressources/appliweb/prestashop_edition_basic_version_8.0.1.zip
		unzip /var/www/html/prestashop/prestashop_edition_basic_version_8.0.1.zip
		rm -r /var/www/html/prestashop/prestashop_edition_basic_version_8.0.1.zip
		chown www-data:www-data -R /var/www/html/prestashop
		mysql -e "create database bddPresta;create user \"admin\"@\"localhost\" IDENTIFIED BY \"btsinfo\";grant all privileges on bddPresta.* to \"admin\"@\"localhost\";"
		echo "<VirtualHost *:80>
        

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html/prestashop/public
		

       

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        
</VirtualHost>" > /etc/apache2/sites-available/prestashop.conf
		a2ensite prestashop.conf
		a2dissite 000-default.conf
		service apache2 restart
		echo "
╔═════════════════════════════════════╗
║ Installation de Prestashop terminée ╚═══════════════════════════════════════════╗
║ Le nom de l'utilisateur est 'admin', le MDP est 'btsinfo', la BDD : 'bddPresta' ║
╚═════════════════════════════════════════════════════════════════════════════════╝"
    else
        acceuil
    fi
    echo "Voulez-vous installer un autre CMS ?
        1) Oui
        -------
        2)Non"
    read -r new_cms
    if [[ $new_cms == 1 ]]
    then
        CMS
    elif [[ $new_cms == 2 ]]
    then
        echo "Fin d'installation de CMS"
        exit
    else
        exit
    fi
}

function fail2ban()
{
	apt update
	apt install fail2ban iptables -y
	echo "
que voulez-vous faire ?
	
    1)     avoir l'etat des prisons
    ------------------------------------
    2)     avoir l'etat d'une prisons
    ------------------------------------
    3)     Créer une prison
	------------------------------------
    4)    bannir une ip dans une prison
	------------------------------------
    5)    débanir une ip dans une prison
	------------------------------------
	6) initialiser ma.conf (a faire en 1er absolument)
	"
	read rep_fail2ban
    if [[ $rep_fail2ban == 1 ]]
    then
		fail2ban-client status
        iptables -L
    elif [[ $rep_fail2ban == 2 ]]
    then
		fail2ban-client status
        echo "saisir le nom de la prison voulu"
		read prison
		fail2ban-client status $prison
	elif [[ $rep_fail2ban == 3 ]]
    then
        echo "saisir le nom de la prison voulu"
		read nom_prison
		echo "saisir le nom de le bantime voulu"
		read bantime_prison
		echo "saisir le nom de le findtime voulu"
		read find_prison
		echo "saisir le nom de le maxretry voulu"
		read maxretry_prison
		echo "voulez vous rajouter une ip a ignorer ?
				1) oui
				2) non"
		read ipignor
		if [[ $rep_fail2ban == 1 ]]
    	then
			read ip
			echo "
[$nom_prison]
enabled = true
bantime = $bantime_prison
findtime = $find_prison
maxretry = $maxretry_prison
ignoreip = $ip
" >> /etc/fail2ban/jail.d/ma.conf
   		else
			echo "
[$nom_prison]
enabled = true
bantime = $bantime_prison
findtime = $find_prison
maxretry = $maxretry_prison
" >> /etc/fail2ban/jail.d/ma.conf
		fi
	elif [[ $rep_fail2ban == 4 ]]
    then
        echo "saisir le nom de la prison voulu"
		read prison
		echo "saisir l'ip a ban"
		read ip
		fail2ban-client set $prison banip $ip
	elif [[ $rep_fail2ban == 5 ]]
    then
        echo "saisir le nom de la prison voulu"
		read prison
		echo "saisir l'ip a unban"
		read ip
		fail2ban-client set $prison unbanip $ip
	elif [[ $rep_fail2ban == 6 ]]
	then
		echo "
[DEFAULT]
bantime = 3600
findtime = 1800
maxretry = 3
ignoreip = 127.0.0.1
" >> /etc/fail2ban/jail.d/ma.conf
    else
        echo "Voulez-vous encore utiliser fail2ban ?
        1) Oui
        -------
        2)Non"
		read more_ban
		if [[ $more_ban == 1 ]]
		then
			fail2ban
		elif [[ $more_ban == 2 ]]
		then
			acceuil
		else
			acceuil
		fi
    fi
	echo "Voulez-vous encore utiliser fail2ban ?
        1) Oui
        -------
        2)Non"
    read more_ban
    if [[ $more_ban == 1 ]]
    then
        fail2ban
    elif [[ $more_ban == 2 ]]
    then
        acceuil
    else
        acceuil
    fi
}

function pureftp()
{
	apt install pure-ftpd -y
	ln -s /etc/pure-ftpd/conf/PureDB /etc/pure-ftpd/auth/60puredb
	echo "1" > /etc/pure-ftpd/conf/CreateHomeDir
	echo  " 
Que voulez vous faire ?

    1)     créer utilisateur ftpuser (a faire en 1er)
    ------------------------------------
    2)     créer un utilisateur virtuel
    ------------------------------------
    3)     modifier paramette utilisateur virtuel
    ------------------------------------
	4)	   Vérification des propriétés de l'utilisateur
    "
    read choix
	if [[ $choix == 1 ]]
    then
        adduser ftpuser
		pureftp
    elif [[ $choix == 2 ]]
    then
        echo "saisir le nom"
		read nom
		pure-pw useradd $nom -u 1001 -g 1001 -d /home/FTPUSER/$nom -m
		pure-pw mkdb
		pureftp
	elif [[ $choix == 3 ]]
    then
        echo "liste des utilisateur virtuel"
		pure-pw list
		echo "saisir le nom de l'utilisateur voulu"
		read nom
		echo "que voulez vous faire ?
			1) limitation de la bande passante du téléchargement ;
			2) limitation de la bande passante de l'envoi ;
			3) quota en nombre de fichiers max ;
			4) quota en taille maximale utilisable ;
			5) autoriser un client ou une IP ;
			6) interdire un client ou une IP ;
			7) IP (ou noms d'hôtes) depuis lesquelles l'utilisateur est autorisé à se connecter ;
			8) IP (ou noms d'hôtes) depuis lesquels l'utilisateur n'est pas autorisé à se connecter ;
			9) limitation horaire pendant laquelle l'utilisateur peut se connecter ;
			10) nombre de sessions simultanées autorisées."
		 read choixmodif
		if [[ $choixmodif == 1 ]]
		then
			echo "saisir le poid de la limitation en kb"
			read poid
			pure-pw usermod $nom -t $poid
			pureftp
		elif [[ $choixmodif == 2 ]]
		then
			echo "saisir le poid de la limitation en kb"
			read poid
			pure-pw usermod $nom -T $poid
			pureftp
		elif [[ $choixmodif == 3 ]]
		then
			echo "saisir le nombre de fichier max"
			read nbmax
			pure-pw usermod $nom -n $nbmax
			pureftp
		elif [[ $choixmodif == 4 ]]
		then
			echo "saisir le poid de la limitation en mb"
			read poid
			pure-pw usermod $nom -N $poid
			pureftp
		elif [[ $choixmodif == 5 ]]
		then
			echo "saisir l'ip "
			read ip
			pure-pw usermod $nom -i $ip
			pureftp
		elif [[ $choixmodif == 6 ]]
		then
			echo "saisir l'ip "
			read ip
			pure-pw usermod $nom -I $ip
			pureftp
		elif [[ $choixmodif == 7 ]]
		then
			echo "saisir l'ip "
			read ip
			pure-pw usermod $nom -r $ip
			pureftp
		elif [[ $choixmodif == 8 ]]
		then
			echo "saisir l'ip "
			read ip
			pure-pw usermod $nom -R $ip
			pureftp
		elif [[ $choixmodif == 9 ]]
		then
			echo "saisir l'heure (0000-0000) "
			read heure
			pure-pw usermod $nom -z $heure
			pureftp
		elif [[ $choixmodif == 10 ]]
		then
			echo "saisir le nombre de session max"
			read nbmax
			pure-pw usermod $nom -y $nbmax
			pureftp
		else
			pureftp
		fi
	elif [[ $choix == 4 ]]
	then
		 echo "liste des utilisateur virtuel"
		pure-pw list
		echo "saisir le nom de l'utilisateur voulu"
		read nom
		pure-pw show $nom
		pureftp
    else
        echo "Voulez-vous encore utiliser pureftp ?
        1) Oui
        -------
        2)Non"
		read more_ftp
		if [[ $more_ftp == 1 ]]
		then
			pureftp
		elif [[ $more_ftp == 2 ]]
		then
			pureftp
		else
			acceuil
		fi
    fi
}

# Menu principal
PS3='Veuillez sélectionner une option : '
options=("Installation d'apache" "Création d'un site Apache" "Installation de CMS" "Ipset" "fail2ban" "pureftp" "Quitter")

select opt in "${options[@]}"
do
    case $opt in
        "Installation d'apache")
            installApacheServer
            ;;
        "Création d'un site Apache")
            site
            ;;
        "Installation de CMS")
            CMS
            ;;
        "Ipset")
            ipSet
            ;;
		"fail2ban")
            fail2ban
            ;;
		"pureftp")
            pureftp
            ;;
        "Quitter")
            break
            ;;
        *) # Si l'utilisateur entre une option invalide
            echo "Option invalide"
            ;;
    esac
done

