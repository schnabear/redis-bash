#!/bin/bash
#
# Simple Redis init.d script conceived to work on Linux systems
# as it does use of the /proc filesystem.

REDISPORT=6379
EXEC=/usr/local/bin/redis-server
CLIEXEC=/usr/local/bin/redis-cli

PIDFILE=/var/run/redis_${REDISPORT}.pid
CONF="/etc/redis/${REDISPORT}.conf"
LOG="/var/log/redis.log"
LOG_LEVEL=notice

case "$1" in
    start)
        if [ -f $PIDFILE ]
        then
            echo "$PIDFILE exists, process is already running or crashed"
        else
            echo "Starting Redis server..."

            if [ ! -f $PIDFILE ]
            then
                echo "Creating PIDFILE..."
                touch $PIDFILE
            fi

            if [ ! -d `dirname "$CONF"` ]
            then
                echo "Creating REDIS directory..."
                mkdir `dirname "$CONF"`
            fi

            if [ ! -f $CONF ]
            then
                echo "Creating CONF..."
                touch $CONF
                echo -e "daemonize yes\nloglevel ${LOG_LEVEL}\nlogfile ${LOG}" > $CONF
            fi

            $EXEC $CONF
        fi
        ;;
    stop)
        if [ ! -f $PIDFILE ]
        then
            echo "$PIDFILE does not exist, process is not running"
        else
            PID=$(cat $PIDFILE)
            echo "Stopping ..."
            $CLIEXEC -p $REDISPORT shutdown
            while [ -x /proc/${PID} ]
            do
                echo "Waiting for Redis to shutdown..."
                sleep 1
            done
            rm $PIDFILE
            echo "Redis stopped"
        fi
        ;;
    cli)
        echo "Starting CLI, type exit to close..."
        redis-cli -p $REDISPORT
        ;;
    *)
        echo "Please use start or stop or cli as first argument"
        ;;
esac