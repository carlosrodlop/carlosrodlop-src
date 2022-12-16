@echo off
REM List task and find a particular one
tasklist | FIND "agent.jar"
REM get host IP
ipconfig
REM Equivalent to "curl URL and get the output in a file" in linux
Invoke-WebRequest -Uri 'http://x.x.x.x:xxxx/computer/NPERMG382/slave-agent.jnlp?encrypt=true' -OutFile c:\temp\jnlp.txt
REM Equivalent to "cat a file passed as variable" in linux
type %THEFILE%
REM Kill Java Process
wmic process where "name='java.exe'" get ProcessID, Commandline /format:list
Taskkill /F /PID <idproceso>
REM Add Program as System Service
"C:\Program Files (x86)\Apache Software Foundation\Apache2.2_jsf2\bin\httpd.exe" -k install -n "Apache2.2_jsf2"
REM Env Variables Permanent Changes
REM Panel de Control > Sistema y Seguridad > Sistema > Configuración Avanzada > Variables del entorno
REM Env Variables for a Terminal Session
setx set MAVEN_OPTS "-Xms256m -Xmx512m"
REM Microsoft Management Console. See https://msdn.microsoft.com/en-us/library/bb742441.aspx
mmc
