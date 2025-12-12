# Go Web Application

This is a simple website written in Golang. It uses the `net/http` package to serve HTTP requests.

## Running the server

To run the server, execute the following command:

```bash
go run main.go
```

The server will start on port 8080. You can access it by navigating to `http://localhost:8080/courses` in your web browser.

## Looks like this

![Website](static/images/golang-website.png)

## go.mod

// dependencies file for go applications
// RUN go mod download -- to download dependencies

## DockerFile notes

// Create a distroless image, copy the artifacts from previous build stage and place it in default directory(.) nothing but current directory or new directory

  // COPY --from=build /app/artifacts .

// We need to copy static files also from previous stages, since this application has html files which are static content, we need to copy them into image because static content are not part of binaries

  // COPY --from=build /app/static ./static
---------------------------------------------------

## Docker commands

// build the docker image with docker hub repo name, current build directory path(.)
## docker build -t chockalingammuthukumar/go-web-app .

// spin up docker container with image created in detached mode
## docker run -d -p 8080:8080 --rm  --name go-web-app-con chockalingammuthukumar/go-web-app:latest

// list all images
## docker images

// show all containers including stopped and running
## docker ps -a 

//show only running containers
## docker ps 

// push the docker image from local to docker hub repository
## docker push chockalingammuthukumar/go-web-app

------------------------------------------

## Kubernetes

// Service Discovery --> happens through labels and selectors

// Run below command to amke the deployment file created, copy paste into our file and edit
## kubectl create deployment go-web-app-deployment --replicas=2 --image=chockalingammuthukumar/go-web-app:latest --dry-run=client --output='yaml' > go-web-app-deployment.yaml

--------------------------------------

## Ingress

// Ingress class name is basically for the ingress resource to be identified by the ingress controller
// Ingress class is used to control the ingress controllers
// Big organisations use different ingress controllers like nginx, aws load balancers, kong, trafik
// SO ingress resources within the kubernetes clusters need to be identified by those ingress controllers i.e) nginx resources inside kubernetes cluster needs to be identified by nginx ingress controllers so that it can route based on the rules written inside nginx resource file that is yaml file, so ingress class name called nginx tells nginx ingress controllers to look into nginx resources file for routing the traffic to backend services

Two types of ingress objects:
---------------------------------------
1. resources --> routing rules (written based on path or host based routing)
2. controllers --> routes the traffic based on resoureces rules
3. class --> manges and sends instructions to controllers

// ingress class --> manages the respective ingress controllers
// ingress controllers --> route the trafffic based on written ingress resources rules 
// ingress resources --> routing rules defined based on host based or path based routing

Traffic flow:
-------------------
nginx ingress class --> nginx ingress controller --> nginx resources file

---------------------------

## AWS EKS

Prerequisites:
----------------------
1. Kubectl --> to interact with kubernetes clusters
2. eksctl --> to interact with eks clusters
3. AWS CLI --> to interact with aws services

--------------------------

## Install eksctl
1. brew tap aws/tap
2. brew install aws/tap/eksctl
3. eksctl version

## AWS CLI
1. aws --version
2. aws configure
   // create IAM user with eks cluster and ec2 full access policy
   // create a access key id and secret access key, download csv file
3. aws sts get-caller-identity --> to get userid, account details

{
    "UserId": "AIDAQE3ROTL75TTY6TLJN",
    "Account": "010438482687",
    "Arn": "arn:aws:iam::010438482687:user/chocka_eks_user"
}