# Field Report

1. Best way to work together is to make a [github](https://github.com/) or the Zühlke [bitbucket](https://bitbucket.zuehlke.com) repository to make all users the code available and see changes directly. Besides comment always your code and write it as plain as possible.

2. Our results if it does not work:
* Test always step by step!
* First test REST APIs by using simple commands like "print"!
* Make tests by using first GET and then POST requests!
* Test the request first locally on your own computer then locally in the docker container on the virtual machine (VM) and finally by making a request from outside to the virtual machine.
* If the virtual machine (VM) does not work, check:
   1. Are you connected to the VPN. The virtual machine works only if there is no connection to the VPN.  
   2. Are all needed ports on the VM open. If you make a request to port 80, port 80 should be opened for all user on the VM.
* If docker is not available:
   a. Is docker running?
   b. Are you connected to the internet via WLAN or LAN-cable? Docker does work if you have connection via LAN-cable.
   c. On the VM: Have you set "sudo" before the docker command? To run docker on the Linux-VM you should act as administrator and use the "sudo" command.
* If you get the error response that "predict.randomForest" is not available after a request, your initial service has not the package "randomForest" installed.
* If plumber does work locally and within the docker container but not by requesting from outside, you should check if "host=('0,0,0,0')" is set in *install_and_runport.R*.
* 
3. Working together in different computer languages

* Make sure everyone know what input and output parameters are used.
* Docker makes it easy to run code which needs specific systems and/or programming languages.
* 

4. Documentation
* If your are working on a task which is relevant for others to know, it is useful to create markdowns which describe what and why you are doing things.
* 
5. Virtual machine (VM)
* We used the test version in [Azure](https://azure.microsoft.com/en-gb/services/virtual-machines/) for getting a Linux-VM. This is a great way to try your program out.
* 
6. 