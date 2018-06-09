# Application Manager (app)

management user application like systemd.

## Tech Notes
> * use ```$ExecStarCommand > ${APP_DIR}/log/${APP_NAME}.log  2>&1 &&``` command to execute user define command,
    screen output redirected to log file.
> * use APP_NAME to management service or application instead of input long command line,
    the command line save in ${APP_DIR}/user/*.service file, such as foo.service, APP_NAME is "foo".
> * use pid to monitor the status of service or application,
    use kill -9 <pid> to stop the service or application.

## Install and example
> * (1) copy "app" file to /usr/bin
> * (2) "app init" to create ${HOME}/app directory and sub directory.
> * (3) put some service file to ${HOME}/app/user directory, such as:
```
cat > ${HOME}/app/user/foo.service <<EOF
[Service]
ExecStart=/usr/bin/tail -f /var/log/system.log
EOF
```
> * (4) "app enable foo" to enable foo service.
> * (5) "app run foo" to run foo service.
start foo ...
/usr/bin/tail -f /var/log/system.log
started, pid = 14648.
> * (6) "app status foo" to show status of foo service.
 active (running)  [foo] -- 14648 /usr/bin/tail -f /var/log/system.log
> * (7) "app kill foo" to stop foo service.
stop foo (pid=14648) ...

## Usage
```
usage: app <r|run|start>|<k|kill|stop>|<re|restart> <service-name>
       app <run-all>|<kill-all>
       app <s|status> [<service-name>]
       app <e|enable>|<d|disable> <service-name>
       app <l|list>
       app <init>
```
## Manual
```
  ${APP_DIR}/user/ -- *.service files, defined by user
  ${APP_DIR}/work/ -- symbol link of *.service, it created or deleted by <enable> and <disable> command,
                    prohibit manually work in this dir for will be removed automaticlly.
  ${APP_DIR}/pid/ -- *.pid files, auto generated
  ${APP_DIR}/log/ -- *.log files, auto generated
  service file format:
    [Service]
    ExecStart=<command> [arguments]  -- ONLY ABSOLUTE PATH SUPPORTED.
```