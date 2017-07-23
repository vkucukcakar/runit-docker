#!/bin/bash

###
# vkucukcakar/runit
# runit Docker image for service supervision and zombie reaping
# Copyright (c) 2017 Volkan Kucukcakar
# 
# This file is part of vkucukcakar/runit.
# 
# vkucukcakar/runit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# vkucukcakar/runit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# 
# This copyright notice and license must be retained in all files and derivative works.
###

# Execute another entrypoint or CMD if there is one
if [[ "$@" ]]; then
	echo "Executing $@"
	$@
	EXITCODE=$?
	if [[ $EXITCODE > 0 ]]; then 
		echo "Error: $@ finished with exit code: $EXITCODE"
		exit $EXITCODE
	fi
fi

# TERM signal callback
stop() {	
	# Wait until services stopped
	echo "Stopping runit services"
	sv -w 5 force-stop /etc/service/*
		
	# Send runsvdir HUP signal to make it send TERM signal to each runsv process it is monitoring and exit
	echo "Killing runsvdir"
	kill -HUP $RUNSVDIRPID
	wait $RUNSVDIRPID
	sleep 0.3
	
	# Cleanup the remaining processes, if there are any
	# Get all remaining PIDs excluding PID 1, current script and grep pipe itself!
	echo "Sending TERM signal to remaining processes"
	PROCESSES=$(pgrep . | grep -v "^1$\|^${BASHPID}$\|$$");
	# Send TERM signal to remaining processes
	for PID in $PROCESSES; do
		kill $PID >/dev/null 2>&1
	done
	# Dirty way of timeout without using bash wait and gnu parallel
	for i in {1..8}
	do
		LOOP=0
		for PID in $PROCESSES; do
			kill -0 $PID > /dev/null 2>&1 && LOOP=1
		done
		sleep 0.5
		[ "$LOOP" == 0 ] && break
	done
	# Send KILL signal to remaining processes
	echo "Sending KILL signal to remaining processes"
	for PID in $PROCESSES; do
		kill -9 $PID >/dev/null 2>&1
	done
	#Note: Total timeout should be a reasonable value as Docker's default stop timeout is 10 seconds
	exit	
}

# Trap Docker's default signal, SIGTERM and call stop
trap stop SIGTERM

# Execute runsvdir and wait
echo "Executing runsvdir"
exec /sbin/runsvdir -P /etc/service &
RUNSVDIRPID=$!
wait $RUNSVDIRPID
stop
