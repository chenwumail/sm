# Service Manager (sm)

Management user service like systemd.

## Tech Notes
 * use ```$ExecStarCommand > ${SM_DIR}/log/${SERVICE_NAME}.log  2>&1 &``` command to execute user defined command, stdout and stderr redirected to log file.
 * use SERVICE_NAME to management service instead of type long command line,
    the command line saved in ${SM_DIR}/user/*.service file, such as foo.service, SERVICE_NAME is "foo".
 * use pid to monitor the status of service,
    use kill -9 <pid> to stop the service.

## Install and example
 * (1) copy "sm" command to /usr/bin
 * (2) "sm init" to create ${HOME}/sm directory and sub directory.
 * (3) put some service file to ${HOME}/sm/user directory, such as:
```
cat > ${HOME}/sm/user/foo.service <<EOF
[Service]
ExecStart=/usr/bin/tail -f /var/log/system.log
EOF
```
 * (4) "sm enable foo" to enable foo service.
 * (5) "sm run foo" to run foo service.
> start foo ...
> /usr/bin/tail -f /var/log/system.log
> started, pid = 14648.
 * (6) "sm status foo" to show status of foo service.
> active (running)  [foo] -- 14648 /usr/bin/tail -f /var/log/system.log
 * (7) "sm kill foo" to stop foo service.
> stop foo (pid=14648) ...

## Usage
```
usage: sm <r|run|start>|<k|kill|stop>|<re|restart> <service-name>
       sm <run-all>|<kill-all>
       sm <s|status> [<service-name>]
       sm <e|enable>|<d|disable> <service-name>
       sm <l|list>
       sm exec <service-name>  # forgrand run service without in ${SM_DIR}/user directory
       sm <init>
```
## Manual
  `$SM_DIR` default is `$HOME/sm`， type `sm` without arguments will show it.
```  
  ${SM_DIR}/user/ -- *.service files, defined by user
  ${SM_DIR}/work/ -- symbol link of *.service, it created or deleted by <enable> and <disable> command,
                    prohibit manually work in this dir for will be removed automaticlly.
  ${SM_DIR}/pid/ -- *.pid files, auto generated
  ${SM_DIR}/log/ -- *.log files, auto generated
  service file format:
    [Service]
    ExecStart=<command> [arguments]  -- ONLY ABSOLUTE PATH SUPPORTED.
    WorkingDirectory=/home/user/sm -- OPTIONAL, default is ${SM_DIR} when not set
    Restart=never -- OPTIONAL, default is never, set always will be restart when sm-monitor is running  
  Auto Restart service when crash: 
  (1) sm enable sm-monitor  # sm init will generate $HOME/sm/user/sm-monitor.service and enable it
  (2) sm run sm-monitor
  (3) add Restart=always to foo.service
  if foo crash, sm-monitor while restart it, checked every 5 minutes.
  don't worry about sm kill <service-name>, it will not be restart automaticlly.  
```