# SuiteCRM_vagrant
A vagrant setup for testing SuiteCRM based off Ubuntu Xenial (16.04)
Install VirtualBox and Vagrant 1st
```
vagrant up
```
to run the unit tests
```
vagrant ssh
cd /vagrant
./vendor/bin/robo tests:unit
```
See https://docs.suitecrm.com/developer/automatedtesting/ for more info on testing SuiteCRM
