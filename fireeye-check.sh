#!/bin/sh

_target_version="v32.30.0"

check_hostname () {
	_host="$(echo $HOSTNAME)"
	echo $_host
}

check_os_version () {
	_uname_results="$(uname -a)"
	echo $_uname_results
}

check_if_active () {
	_active_status="$(systemctl is-active xagt)"
	echo $_active_status
}

check_if_enabled () {
	_enabled_status="$(systemctl is-enabled xagt)"
	echo $_enabled_status
}

check_if_failed () {
	_failed_status="$(systemctl is-failed xagt)"
	echo $_failed_status
}

check_fireeye_connection () {
	_connect_status="$(nc -z wva-fe-hxd00.csp.noaa.gov 443 | grep connected)"
	echo $_connecttion_status
}

install_fireeye () {
	yum -y install xagt --nogpgcheck
	_previous_pid=$!
	wait $_previous_pid
	echo "Configuring client"
	/opt/fireeye/bin/xagt -i /repos/localrepofiles/xagt-32/agent_config.json
	_previous_pid=$!
	wait $_previous_pid
	chmod +r /usr/lib/systemd/system/xagt.service
	chmod -x /usr/lib/systemd/system/xagt.service
	systemctl enable xagt
	_previous_pid=$!
	wait $_previous_pid
	systemctl restart xagt
	_previous_pid=$!
	wait $_previous_pid
}

remove_fireeye () {
	echo "Stopping service"
	systemctl stop xagt
	_previous_pid=$!
	wait $_previous_pid
	fireeyeRpm="$(rpm -qa | grep -i xagt)"
	echo $fireeyeRpm
	rpm -e ${fireeyeRpm}
	_previous_pid=$!
	wait $_previous_pid
	echo "rpm removed"
	echo "Removing client"
	opt/fireeye/bin/uninstall.sh #yum -y remove xagt
	_previous_pid=$!
	wait $_previous_pid
}

check_hostname
check_os_version

if [[ $_uname_results == *"el7"* ]]; then
	if [[ -f "/opt/fireye/bin/xagt" ]]; then
		_installed_version="$(/opt/fireeye/bin/xagt -v)"
		if [[ $_target_version == $_installed_version  ]]; then
			if [[ $_active_status == "active"  ]]; then
				echo "Version is active"
				echo "Checking connection status"
				check_fireeye_connection
				if [[ $_connection_status == *"Network is unreachable"* ]]; then
					echo "Connection problem"
					echo "Identify error"
				else
					echo "Connection good"
				fi
			else
				echo "Version is not operating as expected"
				echo "Remomving install"
				echo "Installing target version"
			fi
		else
			echo "Not target version"
			echo "Removing install"
			echo "Installing target version"
		fi
	else
		echo "Fireye not installed"
		echo "Installing target version"

	fi
fi
