#!/bin/bash

export PORT=5300
export MIX_ENV=prod
export GIT_PATH=/home/task_tracker2/src/task_tracker2 

PWD=`pwd`
if [ $PWD != $GIT_PATH ]; then
	echo "Error: Must check out git repo to $GIT_PATH"
	echo "  Current directory is $PWD"
	exit 1
fi

if [ $USER != "task_tracker2" ]; then
	echo "Error: must run as user 'task_tracker2'"
	echo "  Current user is $USER"
	exit 2
fi

mix deps.get
(cd assets && npm install)
(cd assets && ./node_modules/brunch/bin/brunch b -p)
mix phx.digest
mix release --env=prod

mkdir -p ~/www
mkdir -p ~/old

NOW=`date +%s`
if [ -d ~/www/task_tracker ]; then
	echo mv ~/www/task_tracker ~/old/$NOW
	mv ~/www/task_tracker ~/old/$NOW
fi

mkdir -p ~/www/task_tracker
REL_TAR=~/src/task_tracker2/_build/prod/rel/task_tracker/releases/0.0.1/task_tracker.tar.gz
(cd ~/www/task_tracker && tar xzvf $REL_TAR)

crontab - <<CRONTAB
@reboot bash /home/task_tracker2/src/task_tracker2/start.sh
CRONTAB

#. start.sh
