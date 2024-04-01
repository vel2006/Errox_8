# Errox_8

### What is Errox_8:
Errox_8 is a Bash script designed to function the same as Nmap (no offense do the Nmap devs, love yall's work). Errox_8 is not designed to replace Nmap completely but be an alternitive for those who would prefer something programed completely in Bash. It works by scanning ports using nc and filtering the output for what port is open and what service is running on said port.

### What you need:
1) A Linux flavor, Kali, Debian, Ubuntu if available
2) Errox_8.sh downloaded
3) Internet connection

### How to use:
Simply run Errox_8.sh to get promted for an ip address along with a port scan size or enter a port number. While running Errox_8 will display the port it is scanning. Errox_8.sh will display the information collected in the format: [port] [service]

### Under the hood:
Errox_8 is 100% programed in Bash. Designed to be user friendly and light-weight from using commands/tools built into many Linux flavors. Those being: echo, awk, grep, nc. Due to using Bash, the script has direct access to the commands and tools avalable from the Linux flavor, and that way it can be ran without the risk of compromising your system through malicious code in this script (a beginner can read and understand it)

### Have problems?
Report it at: github.com/vel2006/Errox_8

### Upcoming updates:
1) Larger port range
2) Service information gathering for more services
3) Faster scan time
4) Better front end
5) user ip masking
