# Field Report from November 2017

## View

### Plumber 

**Plumber** is one opportunity which works for all models very well but has to be implemented by oneself. Thus, the transformation from JSON to a list which can used for the prediction and the transformation from the result from the prediction to a number have to be implemented by hand. Besides, there exists no authorization. It will be possible but one have to implement it. Thus, it is not so user-friendly and would take some time to get all started.

### OpenCPU
**OpenCPU** is one opportunity which works for all models, too. Here is the challenge that it takes some time to run some requests. You can set a password if needed. Besides, OpenCPU has a good documentation but mostly for the OpenCPU cloud server which runs only on Ubuntu 16.04. Furthermore, one have no information about what OpenCPU makes in the Docker container in detail. This is not useful for detecting running problems or want to change the output. Performing a POST request results in a function call where the request arguments are mapped to the function call. Thus, the returned status is "201 Created" and the response body contains the locations of the output data which will change in every single call. There is one exception to this rule: in the special case, if the output should be a JSON. Thus, it is user friendly, if one only use it and it works but one will not know everything in detail.

### ML Server standard

### ML Server live

### VM in general

### Docker 
**Docker** is a great way to run applications on any machine. The environment will always be the same and there exists no trouble in using different systems. There occurred never a problem by using the Dockerfile or -image on the virtual machine if it worked locally. Furthermore, it is possible to start a Dockerimage which is on Docker hub without having the Dockerfile explicitly. This makes sharing and running applications much easier.

### Table of results
 Characteristics   | Plumber              | OpenCPU    | ML Server | Virtual Machine
| -------------    |-------------         | -----      |---------- | -------
| source           | [R package (CRAN)](https://cran.r-project.org/web/packages/plumber/plumber.pdf)    | [Jeroen Ooms (jeroen@berkeley.edu)](https://github.com/jeroen) | Microsoft | [Microsoft Azure](https://azure.microsoft.com/en-gb/)
| needed tools     | R, VM                | R, Docker        | R, VM | -
| open source      | Yes                  | Yes        | No | No
| test version     |  -                   | -          | Yes (190 CHF) |  Yes (190 CHF)
| authorization    | self implemented     | Yes        | Yes | Yes
| user-friendly    | Yes (take some time) |  Yes (but you do not what happening exactly)   | Yes (but it does not always works how it is should) | Yes (sometimes there occurs problems)

## Notes

1. Best way to work together is to make a [github](https://github.com/) or the Zühlke [bitbucket](https://bitbucket.zuehlke.com) repository to make all users the code available and see changes directly. Besides comment always your code and write it as plain as possible. If the files are to large for pushing it to github, try the [Git Large File Storage (LFS)](https://git-lfs.github.com/)!

2. Our results if it does not work:
* Test always step by step!
* First test REST APIs by using simple commands like "print"!
* Make tests by using first GET and then POST requests!
* Test the request first locally on your own computer then locally in the docker container on the virtual machine (VM) and finally by making a request from outside to the virtual machine.
* If the virtual machine (VM) does not work, check:
   1. Are you connected to the VPN. The virtual machine works only if there is no connection to the VPN.  
   2. Are all needed ports on the VM open. If you make a request to port 80, port 80 should be opened for all user on the VM.
* If docker is not available:
   1. Is docker running?
   2. Are you connected to the internet via WLAN or LAN-cable? Docker does work if you have connection via LAN-cable.
   3. On the VM: Have you set "sudo" before the docker command? To run docker on the Linux-VM you should act as administrator and use the "sudo" command.
* If you get the error response that "predict.randomForest" is not available after a request, your initial service has not the package "randomForest" installed.
* If plumber does work locally and within the docker container but not by requesting from outside, you should check if "host=('0,0,0,0')" is set in *install_and_runport.R*.

3. Working together in different computer languages

* Make sure everyone know what input and output parameters are used.
* Docker makes it easy to run code which needs specific systems and/or programming languages.

4. Documentation
* If your are working on a task which is relevant for others to know, it is useful to create markdowns which describe what and why you are doing things.

5. Virtual machine (VM)
* We used the test version in [Azure](https://azure.microsoft.com/en-gb/services/virtual-machines/) for getting a Linux-VM. This is a great way to try your program out.
