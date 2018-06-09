application manager (app): management user application like systemd

There have 3 solution behind tools:
(1) use ```$ExecStarCommand > ${APP_DIR}/log/${APP_NAME}.log  2>&1 &&``` command to execute user define command,
    screen output redirected to log file.
(2) use APP_NAME to management service or application instead of input long command line,
    the command line save in ${APP_DIR}/user/*.service file, such as foo.service, APP_NAME is "foo".
(3) use pid to monitor the status of service or application,
    use kill -9 <pid> to stop the service or application.

It very install on shell based os:
(1) copy "app" file to /usr/bin
(2) "app init" to create ${HOME}/app directory and sub directory.
(3) put some service file to ${HOME}/app/user directory, such as:
echo << EOF
[Service]
ExecStart=/usr/bin/tail -f /var/log/system.log
EOF > ${HOME}/app/user/foo.service
(4) "app enable foo" to enable foo service.
(5) "app run foo" to run foo service.
(6) "app status foo" to show status of foo service.
(7) "app kill foo" to stop foo service.



usage: app <r|run|start>|<k|kill|stop>|<re|restart> <service-name>
       app <run-all>|<kill-all>
       app <s|status> [<service-name>]
       app <e|enable>|<d|disable> <service-name>
       app <l|list>
       app <init>
application manager (app) manual:
  ${APP_DIR}/user/ -- *.service files, defined by user
  ${APP_DIR}/work/ -- symbol link of *.service, it created or deleted by <enable> and <disable> command,
                    prohibit manually work in this dir for will be removed automaticlly.
  ${APP_DIR}/pid/ -- *.pid files, auto generated
  ${APP_DIR}/log/ -- *.log files, auto generated
  service file format:
    [Service]
    ExecStart=<command> [arguments]  -- ONLY ABSOLUTE PATH SUPPORTED.
