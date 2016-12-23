#!/bin/bash

##### Constants
PROFILE=uat
SCRIPT_DIR=/opt/microservice/scripts
LIB_DIR=/opt/microservice
ACTION=$1
SERVICE=$2
EXT=$3
PORT=$4
SERVICE_DES=$SERVICE.$EXT
EXECUTABLE_FILE="$LIB_DIR/$SERVICE.$EXT"

if [ ! -z $PORT ]; then
    SERVICE_DES=$SERVICE.$EXT:$PORT
fi

##### Functions
function usage
{
    if [ ! -z $1 ]; then
        echo "usage: $0 $1 <service_name> <service_extension> [service port]"
    else
		echo "usage: $0 deploy|start|stop|restart <service_name> <service_extension> [service port]"
	    fi
    echo ""
    exit 1
}

function deploy_service
{
    echo "Deploying service: $1.$2"
}

function stop_service
{
    echo "Stopping service: $SERVICE_DES"
    if [ ! -z $PORT ]; then
        PID=`ps -ef | grep java | grep $SERVICE.$EXT | grep $PORT | grep -v grep |  awk '{print $2}'`
        echo "Killing PID  $PID"
        kill -9 $PID
    else
        PID=`ps -ef | grep java | grep $SERVICE.$EXT | grep -v grep | awk '{print $2}'`
        echo "Killing PID $PID"
        kill -9 $PID
    fi
    cho "Service $SERVICE_DES has been stopped."
}

function start_service
{
    if [ ! -z $3 ]; then
        echo "Starting service: $1.$2:$3"
        nohup java -jar -Xmx128m -Xss256k $EXECUTABLE_FILE --server.port=$PORT --spring.profiles.active=$PROFILE >/dev/null 2>&1 &
    else
        echo "Starting service: $1.$2"
        nohup java -jar -Xmx128m -Xss256k $EXECUTABLE_FILE --spring.profiles.active=$PROFILE >/dev/null 2>&1 &
    fi
}

function restart_service
{
    stop_service $1 $2 $3
    start_service $1 $2 $3
    if [ ! -z $3 ]; then
        echo "Restart service: $1.$2:$3 completed"
    else
        echo "Restart service: $1.$2 completed"
    fi
}

if [ $# -ge 3 ]; then
    case "$ACTION" in
      "deploy")
          deploy_service $SERVICE $EXT
          ;;
      "start")
          start_service $SERVICE $EXT $PORT
          ;;
      "stop")
          stop_service $SERVICE $EXT $PORT
          ;;
      "restart")
          restart_service $SERVICE $EXT $PORT
          ;;
      *)
          usage
          ;;
    esac
elif [ $# -eq 1 ]; then
    echo "Please input service name and extension."
    usage $ACTION
else
    echo "Please input an action."
    usage
fi

exit 0
