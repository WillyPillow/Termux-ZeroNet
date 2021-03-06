#!/data/data/com.termux/files/usr/bin/bash

if [[ -z "$ZERONET_HOME" ]]; then
	echo "--- Installing ZeroNet ---"
	termux-setup-storage
	apt-get -y update && apt-get -y upgrade 
	apt-get install -y curl make python2-dev git clang grep c-ares-dev libev-dev openssl-tool gnupg gnupg-curl
	export LIBEV_EMBED=false
	export CARES_EMBED=false
	export CONFIG_SHELL=$PREFIX/bin/sh
	export TMPDIR=$PREFIX/tmp
	EMBED=0 pip2 install gevent msgpack-python

	if [[ ! -d ~/ZeroNet ]]; then
		cd ~
		git clone https://github.com/HelloZeroNet/ZeroNet.git
		cd ZeroNet
		gpg --keyserver keys.gnupg.net --recv-keys 960FFF2D6C145AA613E8491B5B63BAE6CB9613AE
		COMMIT=`git log --oneline | head -n 1 | cut -f 1 -d ' '`
		git verify-commit "$COMMIT"
		if [ "$?" -eq 0 ]; then
			git checkout "$COMMIT"
		else 
			>&2 echo "Signature verification failed"
			exit 1
		fi

	fi

	echo 'export ZERONET_HOME=~/ZeroNet' >> ~/.bashrc
	echo "alias zn=\"bash ~/zn.sh\"" >> ~/.bashrc
	source ~/.bashrc

fi

if [[ "$1" == "update" ]]; then
	echo "--- Updating ZeroNet ---"
	pushd $ZERONET_HOME
	git pull
	COMMIT=`git log --oneline | head -n 1 | cut -f 1 -d ' '`
	git verify-commit "$COMMIT"
	if [ "$?" -eq 0 ]; then
		git checkout "$COMMIT"
	else 
		>&2 echo "Signature verification failed"
		exit 1
	fi
	popd
else
	pushd $ZERONET_HOME
	python2 zeronet.py $@
	popd
fi
