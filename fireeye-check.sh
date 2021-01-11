#!/bin/sh

targetVersion="v32.30.0"

#Ncat: Network is unreachable.

echo " "
echo $HOSTNAME
if [ -n "$(uname -a | grep el7)" ]; then
        OS_RELEASE_VERS="7"
	if [[ -f "/opt/fireeye/bin/xagt" ]]; then
	        VERSION="$(/opt/fireeye/bin/xagt -v)"
		echo $VERSION
        	if [ $targetVersion == $VERSION ]; then
				
                	activeStatus="$(systemctl is-active xagt)"
                	enabledStatus="$(systemctl is-enabled xagt)"
                	failedStatus="$(systemctl is-failed xagt)"
                	if [ $activeStatus == "active" ]; then
                	        echo $activeStatus
                	        if [ $enabledStatus == "enabled" ]; then
                	                echo "enabled"
                	                connectStatus="$(nc -z wva-fe-hxd00.csp.noaa.gov 443 | grep connected)"
                	                if [[ $connectStatus == *"Network is unreachable"* ]]; then 
						echo "connection error. Do something"
					else
						echo "Connection good"
					fi
                	        fi
                	elif [ $failedStatus == "failed" ]; then
				echo "failed launch"
				echo "Restarting services"
                	        stat /krug
			else
				echo $activeStatus
				echo "Restarting service"
				systemctl restart xagt
				previousPid=$!
                	        wait $previousPid
				activeStatus="$(systemctl is-active xagt)"
				if [ $activeStatus == "active" ]; then
					echo "active"
				else
					echo "Stopping service"
					systemctl stop xagt
					previousPid=$!
	                	        wait $previousPid
					fireeyeRpm="$(rpm -qa | grep -i xagt)"
					echo $fireeyeRpm
					rpm -e ${fireeyeRpm}
					previousPid=$!
        	                        wait $previousPid
					echo "rpm removed"				
					echo "Removing client"
					opt/fireeye/bin/uninstall.sh #yum -y remove xagt
					previousPid=$!
                	                wait $previousPid
					
					echo "Installing client"
                			yum -y install xagt --nogpgcheck
                			previousPid=$!
                			wait $previousPid
                			echo "Configuring client"
                			/opt/fireeye/bin/xagt -i /repos/localrepofiles/xagt-32/agent_config.json
                			previousPid=$!
                			wait $previousPid
                			chmod +r /usr/lib/systemd/system/xagt.service
                			chmod -x /usr/lib/systemd/system/xagt.service
                			systemctl enable xagt
                			previousPid=$!
                			wait $previousPid
                			systemctl restart xagt
                			previousPid=$!
                			wait $previousPid
                			activeStatus="$(systemctl is-active xagt)"
                			enabledStatus="$(systemctl is-enabled xagt)"
                			failedStatus="$(systemctl is-failed xagt)"
                			if [ $activeStatus == "active" ]; then
              					echo "Installed client is "$activeStatus
                			else
                    				echo "Error"
			                fi


					#yum -y install xagt --nogpgcheck
					#previousPid=$!
                        	        #wait $previousPid
					#echo "Configuring client"
					#/opt/fireeye/bin/xagt -i /repos/localrepofiles/xagt-32/agent_config.json
					#previousPid=$!
					#wait $previousPid
					#chmod +r /usr/lib/systemd/system/xagt.service
					#chmod -x /usr/lib/systemd/system/xagt.service	
					#systemctl enable xagt
					#previousPid=$!
                                	#wait $previousPid
			        	#systemctl restart xagt
					#previousPid=$!
                        	        #wait $previousPid
					#activeStatus="$(systemctl is-active xagt)"
		        	        #enabledStatus="$(systemctl is-enabled xagt)"
                			#failedStatus="$(systemctl is-failed xagt)"
					#if [ $activeStatus == "active" ]; then
					#	echo "Reinstalled client is " $activeStatus
					#else
					#	echo "still bad"
					#fi		
	
				fi
                	fi
        	else
        	    	echo $VERSION "Wrong version"
        	        echo "Updating client"
        	        stat /krug
        	fi
	else
		echo "Client not installed"
		echo "Installing client"
		yum -y install xagt --nogpgcheck
		previousPid=$!
		wait $previousPid
		echo "Configuring client"
                /opt/fireeye/bin/xagt -i /repos/localrepofiles/xagt-32/agent_config.json
                previousPid=$!
                wait $previousPid
		chmod +r /usr/lib/systemd/system/xagt.service
                chmod -x /usr/lib/systemd/system/xagt.service
                systemctl enable xagt
                previousPid=$!
                wait $previousPid
                systemctl restart xagt
                previousPid=$!
                wait $previousPid
                activeStatus="$(systemctl is-active xagt)"
                enabledStatus="$(systemctl is-enabled xagt)"
                failedStatus="$(systemctl is-failed xagt)"
                if [ $activeStatus == "active" ]; then
                	echo "Installed client is "$activeStatus
                else
                	echo "Error"
                fi
	fi
elif [ -n "$(uname -a | grep el6)" ]; then
        OS_RELEASE_VERS="6"
        VERSION="$(/opt/fireeye/bin/xagt -v)"
        if [ "v32.30.0" == $VERSION ]; then
                echo $VERSION "Good"
        else
            	echo $VERSION "Bad"
                stat /krug
        fi
elif [ -n "$(uname -a | grep el8)" ]; then
        OS_RELEASE_VERS="8"
        VERSION="$(/opt/fireeye/bin/xagt -v)"
        if [ "v32.30.0" == $VERSION ]; then
                echo $VERSION "Good"
        else
            	echo $VERSION "Bad"
                stat /krug
        fi
else
    	OS_RELEASE_VERS="0"
fih
