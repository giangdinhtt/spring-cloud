#!/bin/bash

# usage: ./esb.sh
#     [-s|--service service]
#     [-t|--type service type]
#     [-p|--port service port]
#     [-f|--profile profile: uat|prod]
#     [-b|--branch checkout branch: uat,master...]
#     [-z|--size memory size: light|normal|heavy]
#     [additional parameters]
##### Constants
# "$@" contains all remain arguments
SOURCE_DIR=/opt/microservice/scripts/integration
LIB_DIR=/opt/microservice
action=$1
service=
ext='jar'
service_file= # $service.$ext
port=
size='normal'
profile=''
branch=
executable_file= # $LIB_DIR/$service_file

##### Functions
function show_help
(
  echo >&2 \
  "usage: $0 deploy|start|stop|restart|help [-s|--service service] [-t|--type type] [-p|--port port] [-f|--profile profile:uat|prod] [-b|--branch branch: uat,master...] [-z|--size memory size: light|normal|heavy] [parameter ...]"
  echo ""
)

function deploy_service
{
  # Check required option
  if [ -z $branch ]; then
    echo >&2 \
    "ERROR: Source code branch is empty."
    exit 1
  fi

  echo "========== Deploying service: $service_file =========="
  # Git authorization must be cached up or via ssh
  cd $SOURCE_DIR
  echo "========== Update source for branch: $branch =========="
  git reset --hard
  eval "git checkout $branch"
  git pull

  echo "========== Build source with profile: $profile =========="
  eval "mvn clean -P$profile install -Dmaven.test.skip=true"

  echo "========== Copy build file $service_file to $executable_file =========="
  eval "cp $SOURCE_DIR/$service/target/$service_file $executable_file"

  echo "========== Starting service $service_file =========="
  restart_service
}

function stop_service
{
  if [ ! -z $port ]; then
    echo "========== Stopping service: $service_file:$port =========="
    PID=`ps -ef | grep java | grep $service_file | grep $port | grep -v grep |  awk '{print $2}'`
    echo "Killing PID  $PID"
    kill -9 $PID
  else
    echo "========== Stopping service: $service_file =========="
    PID=`ps -ef | grep java | grep $service_file | grep -v grep | awk '{print $2}'`
    echo "Killing PID $PID"
    kill -9 $PID
  fi
  echo "========== Service $service_file has been stopped. =========="
}

function start_service
{
    if [ ! -z $port ]; then
        echo "========== Starting service: $service_file:$port =========="
        nohup java -Duser.timezone=ICT -jar -Xmx128m -Xss256k $executable_file --server.port=$port --spring.profiles.active=$profile >/dev/null 2>&1 &
    else
        echo "========== Starting service: $service_file =========="
        nohup java -Duser.timezone=ICT -jar -Xmx128m -Xss256k $executable_file --spring.profiles.active=$profile >/dev/null 2>&1 &
    fi
    echo "Service $service_file has been started."
}

function restart_service
{
    stop_service
    start_service
    if [ ! -z $port ]; then
        echo "========== Restart service $service_file:$port completed =========="
    else
        echo "========== Restart service $service_file completed =========="
    fi
}

##### MAIN #####
if [ ! -z $action ]; then
  case $action in
    -h|-\?|--help|help)   # Call a "show_help" function to display a synopsis, then exit.
      show_help
      exit
      ;;
    deploy|start|stop|restart)
      ;;
    *)
      echo >&2 \
      "ERROR: Following actions are supported: deploy|start|stop|restart|help"
      exit 1
      ;;
  esac
  shift
else
  show_help
  exit 1
fi

while :; do
    case $1 in
        -h|-\?|--help)   # Call a "show_help" function to display a synopsis, then exit.
            show_help
            exit
            ;;
        -s|--service)       # Takes an option argument, ensuring it has been specified.
            if [ -n "$2" ]; then
                service=$2
                shift
            else
                echo >&2 \
                "ERROR: $1 requires service name"
                exit 1
            fi
            ;;
        -t|--type)       # Takes an option argument, ensuring it has been specified.
            if [ -n "$2" ]; then
                ext=$2
                shift
            else
                echo >&2 \
                "ERROR: $1 requires type of service. e.g: jar, war"
                exit 1
            fi
            ;;
        -f|--profile)       # Takes an option argument, ensuring it has been specified.
            if [ -n "$2" ]; then
                profile=$2
                case "$profile" in
                  uat|prod)
                    ;;
                  *)
                    echo >&2 \
                    "ERROR: $1 requires profile name: uat|prod"
                    exit 1
                    ;;
                esac
                shift
            else
                echo >&2 \
                "ERROR: $1 requires profile name: uat|prod"
                exit 1
            fi
            ;;
        -p|--port)       # Takes an option argument, ensuring it has been specified.
            if [ -n "$2" ]; then
                port=$2
                shift
            else
                echo >&2 \
                "ERROR: $1 requires port for the service"
                exit 1
            fi
            ;;
        -b|--branch)       # Takes an option argument, ensuring it has been specified.
            if [ -n "$2" ]; then
                branch=$2
                shift
            else
                echo >&2 \
                "ERROR: $1 requires source code branch"
                exit 1
            fi
            ;;
        -z|--size)       # Takes an option argument, ensuring it has been specified.
            if [ -n "$2" ]; then
                size=$2
                case "$size" in
                  light|normal|heavy)
                    ;;
                  *)
                    echo >&2 \
                    "ERROR: $1 requires preset size of memory will be allocated for the service: light|normal|heavy"
                    exit 1
                    ;;
                esac
                shift
            else
                echo >&2 \
                "ERROR: $1 requires preset size of memory will be allocated for the service: light|normal|heavy"
                exit 1
            fi
            ;;
        --)              # End of all options.
            shift
            break
            ;;
        -?*)
            echo >&2 \
            "WARN: Unknown option (ignored): $1"
            exit 1
            ;;
        *)               # Default case: If no more options then break out of the loop.
            break
    esac
    shift
done

service_file="$service.$ext"
executable_file="$LIB_DIR/$service_file"
# Check required option
if [ -z $service ]; then
  echo >&2 \
  "ERROR: Service name is empty."
  exit 1
fi

case "$action" in
  "deploy")
      deploy_service
      ;;
  "start")
      start_service
      ;;
  "stop")
      stop_service
      ;;
  "restart")
      restart_service
      ;;
esac

exit
