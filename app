#!/bin/sh
# version 1.0  License: GPL 2.0
# author: chenwumail@gmail.com 2018

if [ "x${APP_DIR}" == "x" ]; then
  APP_DIR=${HOME}/app #default svc dir is /home/{work}/app
fi


read_ini () {
  file=$1;section=$2;item=$3;
  val=$(awk -F '=' '/\['${section}'\]/{a=1} (a==1 && "'${item}'"==$1){print}' ${file}) 
  echo ${val#*=}
}
usage() {
  echo "APP_DIR=${APP_DIR}"
  echo "usage: app <r|run|start>|<k|kill|stop>|<re|restart> <service-name>"
  echo "       app <run-all>|<kill-all>"
  echo "       app <s|status> [<service-name>]"
  echo "       app <e|enable>|<d|disable> <service-name>"
  echo "       app <l|list>"
  echo "       app <init>"
  echo "application manager (app) manual:"
  echo "  \${APP_DIR}/user/ -- *.service files, defined by user"
  echo "  \${APP_DIR}/work/ -- symbol link of *.service, it created or deleted by <enable> and <disable> command",
  echo "                    prohibit manually work in this dir for will be removed automaticlly."
  echo "  \${APP_DIR}/pid/ -- *.pid files, auto generated"
  echo "  \${APP_DIR}/log/ -- *.log files, auto generated"
  echo "  service file format:"
  echo "    [Service]"
  echo "    ExecStart=<command> [arguments]  -- ONLY ABSOLUTE PATH SUPPORTED."
}

############### svc main ##################
app_cmd=$1
app_name=$2
if [ "x${app_cmd}" == "x" ]; then
  usage
  exit 1
fi
case $app_cmd in
  # one initilize command, careful for APP_DIR, default is ${HOME}/app
  init)
    echo "APP_DIR=${APP_DIR}"
    test -d ${APP_DIR}/user || mkdir -p ${APP_DIR}/user
    test -d ${APP_DIR}/work || mkdir -p ${APP_DIR}/work
    test -d ${APP_DIR}/pid  || mkdir -p ${APP_DIR}/pid
    test -d ${APP_DIR}/log  || mkdir -p ${APP_DIR}/log
    ;;  
  # two command for app service in user directory
  l)
    applist=$(ls ${APP_DIR}/user/)
    for app in $applist
    do
      name=${app%%.*}
      /bin/echo -n "$name "
    done
    echo ""
    ;;
  list)
    applist=$(ls ${APP_DIR}/user/)
    for app in $applist
    do
      name=${app%%.*}
      daemon=$(read_ini ${APP_DIR}/user/${name}.service Service ExecStart)
      echo "$name -- $daemon"
    done
    ;;
  # two command to create or remove symbol link from user directory to work directory
  e|enable)
    if [ -f ${APP_DIR}/user/${app_name}.service ]; then
      ln -sf ${APP_DIR}/user/${app_name}.service ${APP_DIR}/work/${app_name}.service
    else
      echo "warning, ${app_name} not found."
      exit 1
    fi
    ;;
  d|disable)
    if [ -f ${APP_DIR}/work/${app_name}.service ]; then
      rm ${APP_DIR}/work/${app_name}.service
    else
      echo "warning, ${app_name} not found."
      exit 1
    fi
    ;;    
  # two all commands, batch do something
  run-all)
    applist=$(ls ${APP_DIR}/work/)
    for app in $applist
    do
      name=${app%%.*}
      app start $name
    done
    ;;
  kill-all)
    applist=$(ls ${APP_DIR}/work/)
    for app in $applist
    do
      name=${app%%.*}
      app stop $name
    done
    ;;
  r|run|start)
    if [ "x${app_name}" == "x" ]; then
      usage
      exit 1
    fi
    last_pid=`test -f ${APP_DIR}/pid/${app_name}.pid && cat ${APP_DIR}/pid/${app_name}.pid` || last_pid=-1
    ps -p $last_pid > /dev/null 2>&1
    status=$?
    if [ $status -eq 0 ]; then
      echo "\033[32m active (running) \033[0m  $app_name"
      ps -f -p $last_pid
      echo "\033[33m warning \033[0m $app_name already running."
      exit 0
    fi    
    echo "start $app_name ..."
    daemon=$(read_ini ${APP_DIR}/work/${app_name}.service Service ExecStart) 
    echo $daemon
    $daemon > ${APP_DIR}/log/${app_name}.log 2>&1 &
    pid=$!
    echo $pid > ${APP_DIR}/pid/${app_name}.pid
    echo "started, pid = ${pid}."
    ;;
  re|restart)
    app stop $app_name
    sleep 3
    app start $app_name
    ;;     
  k|kill|stop)
    if [ "x${app_name}" == "x" ]; then
      usage
      exit 1
    fi
    last_pid=`test -f ${APP_DIR}/pid/${app_name}.pid && cat ${APP_DIR}/pid/${app_name}.pid` || exit 2
    ps -p $last_pid > /dev/null 2>&1
    status=$?
    if [ $status -ne 0 ]; then
      echo "(pid=${last_pid}) No such process"
      test -f ${APP_DIR}/pid/${app_name}.pid && rm ${APP_DIR}/pid/${app_name}.pid
      exit 3
    fi
    echo "stop $app_name (pid=${last_pid}) ... "
    if [ $last_pid -gt 0 ]; then
      kill -9 $last_pid && rm ${APP_DIR}/pid/${app_name}.pid
    else
      echo "unknow error to stop"
      exit 4
    fi
    ;;
  s|status)
    if [ "x${app_name}" == "x" ]; then
      applist=$(ls ${APP_DIR}/work/)
      for app in $applist
      do
        name=${app%%.*}
        app status $name
      done
      exit 0
    fi
    last_pid=`test -f ${APP_DIR}/pid/${app_name}.pid && cat ${APP_DIR}/pid/${app_name}.pid` || last_pid=-1
    ps -p $last_pid > /dev/null 2>&1
    status=$?
    if [ $status -eq 0 ]; then
      line=`ps -f -p $last_pid | tail -n 1`
      echo "\033[32m active (running) \033[0m [$app_name] -- $last_pid /${line#*/}"
    else
      daemon=$(read_ini ${APP_DIR}/work/${app_name}.service Service ExecStart)
      echo "\033[31m inactive \033[0m [$app_name]  --  $daemon"
    fi
    ;;
  log)
    if [ "x${app_name}" == "x" ]; then
      usage
      exit 1
    fi
    if [ -f ${APP_DIR}/log/${app_name}.log ]; then
      tail -n 100 ${APP_DIR}/log/${app_name}.log
    else
      echo "log file ${APP_DIR}/log/${app_name}.log not found."
      exit 9
    fi
    ;;   
  *)
    echo "unknown command: $app_cmd"
    usage
    ;;
esac

############### svc main end ################