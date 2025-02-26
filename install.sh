#!/bin/bash
if [ $# -lt 1 ]
then
	echo "----------------------------------------"
	        echo "usage: $me <ssh|puppet|deployer|nodejs>"
		echo "----------------------------------------"
		        exit
		fi

puppet(){
cd /tmp && curl -O http://apt.puppetlabs.com/puppet-release-bionic.deb \
	&& dpkg -i puppet-release-bionic.deb \
	&& apt-get update \
	&& apt-get -y install wget awscli  puppet git  curl acl mysql-client unzip software-properties-common \
	&& gem install r10k
}


puppetfile(){
cat << PUPPETFILE > /etc/puppet/manifests/Puppetfile
forge 'http://forge.puppetlabs.com'
moduledir '/etc/puppet/modules'
mod 'desertkun-supervisor', '2.0.0'
mod 'willdurand-composer', '1.2.9'
mod 'puppet-php', '7.1.0'
mod 'darin-zypprepo', '1.0.2'
mod 'puppet-yum', '4.3.0'
mod 'example42-puppi', '2.2.11'
mod 'puppet-archive', '5.0.0'
mod 'puppetlabs-apt', '8.0.2'
mod 'puppetlabs-inifile', '5.0.1'
mod 'puppetlabs-stdlib', '7.1.0'
mod 'puppetlabs-apache', '6.1.0'
mod 'puppetlabs-concat', '7.0.1'
mod 'puppetlabs-vcsrepo', '4.0.1'
mod 'puppet-nodejs', '9.0.0'
mod 'mjhas-postfix', '1.0.0'
PUPPETFILE

r10k puppetfile install --puppetfile /etc/puppet/manifests/Puppetfile -v
}


set -e

papply(){
	me="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"

	touch /var/run/$me.pid

	mypidfile=/var/run/$me.pid


	set -e
	pid=$$

	for pid in $(pidof -x $me); do
	    if [ $pid != $$ ]; then
	        echo "[$(date)] : $me : Process is already running with PID $pid"
	        exit 1
	    fi

	echo $$ > /var/run/$mypidfile".pid"
	puppet resource service apache2 ensure=running 2>/dev/null
	puppet resource service postfix ensure=running 2>/dev/null
	puppet resource service ssh ensure=running 2>/dev/null
	exit
	echo $$ > "$mypidfile"
	done

}

case "$1" in
puppet)
	puppet
    ;;
puppet)
	papply
	;;
puppetfile)
	puppetfile
	;;
--help)
	help
	;;
*)	echo "no ingreso opcion"
	echo "ejecute $me --help "
	;;
esac
