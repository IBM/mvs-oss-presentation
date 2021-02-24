# sysdig



## Install
[Detailed Guide](https://github.com/draios/sysdig/wiki/How-to-Install-Sysdig-for-Linux#user-content-manual-installation)


### Run
```
sysdig
sysdig --help
sysdig -s4096 -A -c stdout proc.name=cat
sysdig -c topscalls_time
sysdig -p"%evt.arg.path" "evt.type=chdir and user.name=root"
sysdig -pc -c topconns
sysdig -w all.dump
sysdig -c fdcount_by proc.name "fd.type=file" -r all.dump
csysdig -vcontainers
```
