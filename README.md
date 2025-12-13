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

## Resources Used:
---------------------------------
1. Containerizing -- Docker
2. Minikube       -- Kubernetes
3. EKS,IAM user   -- AWS
4. Ingress        -- Kubernetes
5. Helm           -- Kubernetes
6. CI             -- Github Actions

## go.mod
------------------------
// dependencies file for go applications
// RUN go mod download -- to download dependencies

## DockerFile notes
-----------------------------
// Distroless image --> no shell, no package managers, no OS level attack surface, reduces image size, secure

// Create a distroless image, copy the artifacts from previous build stage and place it in default directory(.) nothing but current directory or new directory

  // COPY --from=build /app/artifacts .

// We need to copy static files also from previous stages, since this application has html files which are static content, we need to copy them into image because static content are not part of binaries

  // COPY --from=build /app/static ./static

## Docker commands
--------------------------------
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

## Kubernetes
------------------------------------------

// Service Discovery --> happens through labels and selectors

// Run below command to make the deployment file created, copy paste into our file and edit
## kubectl create deployment go-web-app-deployment --replicas=2 --image=chockalingammuthukumar/go-web-app:latest --dry-run=client --output='yaml' > go-web-app-deployment.yaml

## Ingress
--------------------------------------

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
// ingress controllers --> route the trafffic based on written ingress resources rules, runs as a pod inside ingress-nginx namespace after installation
// ingress resources --> routing rules defined based on host based or path based routing

Traffic flow:
-------------------
nginx ingress class --> nginx ingress controller --> nginx resources file

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


## GIT
-------------------------
// remove the already existing origin
## git remote remove origin 

// add the new remote repo from github
## git remote add origin https://github.com/ChockalingamMuthukumar/go-web-app.git

// push the changes after adding and committing into remote repo
## git push -u origin main 
// git add .
// git commit -m "commit-message" --> commits to local repo
// git push --> push to remote repo from local repo
// -u --> upstream
// origin --> remote repo head
// main --> local repo head (git branch)

## Podman + CRI-O 
----------------------------------------
// dont use node port service in above combination as,
// NodePort is unreliable in Podman machine because:
    --> CRI-O doesn’t open host ports
    --> VM networking is isolated
    --> No system firewall to configure
    --> No automatic interface binding

## Kubernetes service object
-------------------------------------
// After creating service object, check two things,
    1. kubectl get endpoints go-web-app-nodeport-service
        --> to check whether the service points to the right pods behind that is selector name in service.yaml file matches with pod name labels
    2. kubectl describe svc/<service-name>
        --> to check the endpoints, it should not be empty, if empty then it is not having right selector labels

## Port Forwarding
------------------------
// Exposing a service from its service port(mostly 80) on to our local host port --> http://localhost:<localhost-port>

// kubectl port-forward svc/go-web-app-nodeport-service 9999:80 
    --> mapping local host port 9999 to service port of node port that is 80(mentioned in YAML file)
    local host port: 9999
    service port: 80

## ingress-nginx namespace
-----------------------------------
Nginx Ingress Controller YAML --> has nginx ingress class name
Ingress Resource object YAML --> has nginx ingress class name

// kubectl apply -f kubernetes/manifests/ingress.yaml -n ingress-nginx
// kubectl get pods -n ingress-nginx
// kubectl edit pod <pod-name> -n ingress-nginx
// kubectl get all,ingress -n ingress-nginx --> get all resources and ingress resource inside ingress-nginx namespace

## /etc/hosts
---------------------------
// sudo vim /etc/hosts
// Press i for insert mode
// edit the file by adding entry: 
     127.0.0.1  go-web-app.local
// to save --> :wq
    w --> write/save
    q --> quit

## Traffic flow
----------------------------------

// Address shown by "kubectl get ing" should be mapped to host name given in ing YAML file, then only when we hit in browser DNS resolving happens and routing is done based on routing rules

// Failed flow:
    // "kubectl get ing" shows address as minikube-ip(192.168.49.2)
    // macos from localhost can't reach minikube-ip as it is inside podman private network
    // when mapped minikube-ip(192.168.49.2) to go-web-app.local in /etc/hosts --> macos localhost couldn't reach minikube-ip, so failed
    // so map go-web-app.local to reachable address(127.0.0.1) for macos inside /etc/hosts
    // once done, expose ingress controller service by port forward to the localhost port 9999
    // when go-web-app.local is hit in browser it is resolved to 127.0.0.1 by macos, then request flows to ingress controller when we add go-web-app.local/9999 as it is exposed in port 9999, then to backend service based on routing rules inside ing object, then to pods under that backend service

// go-web-app.local --> resolved to 127.0.0.1 --> ingress controller exposed to local host port 9999 by port-forward --> ingress controller watches ingress object rules --> routes the traffic to backend service --> then to pods

// kubectl port-forward svc/ingress-nginx-controller 9999:80 -n ingress-nginx

// http://go-web-app.local:9999/courses

## HELM
-----------------------------
Purpose: 
// to deploy the applcation in different environments like     Dev, QA, Prod
// say different environments use different image tags like dev for development, prod for production, then using helm it can be variabilised as paramter depending on environments
// Pass the tag name as variable using helm

// "helm version"
// create Helm folder
// "cd Helm"
// "helm create go-web-app-chart"

Helm Components:
-----------------------
chart.yaml --> provides chart metadata
templates --> remove this folder content initially, copy and paste our 3 manifests files into this folder
deployment.yaml --> Use "image: docker.io/chockalingammuthukumar/go-web-app:{{ .Values.image.tag }}"
    // Helm whenever executed look for tag from values.yaml file
    // Update the following in values.yaml as of now, tag will be overided through ci/cd pipelines triggers
    // image: repository: docker.io/chockalingammuthukumar/go-web-app
       tag: "latest"

Helm Verification:
----------------------------
1. Delete created deployment, service, ingress object for go-web-app as helm is  used to do all these now
    // kubectl get all
    // kubectl delete deployment/go-web-app-deployment
    // kubectl delete svc/go-web-app-service 
    // kubectl delete ing go-web-app-ingress
2. helm install [NAME] [CHART-PATH] [flags]
    // helm install go-web-app ./go-web-app-chart
    // Now all deleted resources are created using helm
    // when we ran above helm install command it created deployment by going into deployment.yaml and looked for image where we have mentioned {{ .Values.image.tag }} which internally looked for value of image.tag in values.yaml, taken the value "latest" from there and created the deployment
    // Verify using "kubectl describe deployment/go-web-app-deployment" and observe the image used and its tag
          Containers:
            go-web-app-containers:
                Image: docker.io/chockalingammuthukumar/go-web-app:latest
3. helm uninstall go-web-app
4. kubectl get all

## Configure gitlab with github repo code:
--------------------------------------------------

// Create a new project under a group in gitlab

//Check the remote available in our current setup
    git remote -v

// Add a new remote by copying gitlab project url
    git remote add gitlab https://gitlab.com/chockalingammuthukumar-group/go-web-app-project.git

// Again check the newly added remote using
    git remote -v

// Push the code from local repo to gitlab project repo
    git push -u gitlab main
    // gitlab --> new remote repo name added
    // main --> local repo name

//branch 'main' set up to track 'gitlab/main'

// Now we can push from local repo to two remote repo and -u is upstream
    1. git push -u origin main --> push to github repo
    2. git push -u gitlab main --> push to gitlab repo

## Continuous Integration:
-----------------------------------
//Github Actions

Purpose: For every developer commit, build the code, unit test the code, do static code analysis, build the docker image, push it to the docker hub registry with newer version, create helm chart(if not present) or if present update the helm charts with new docker image version from values.yaml

Jobs:
    1. Build and Unit test
    2. Static code analysis
    3. Create and push docker image
    4. Update helm chart with docker image created

Process:
    1. Create .github folder, under that workflows folder, under that ci.yaml file
    
## GitLab
---------------------------
workflows:
  rules:
    // pipeline rules, where pipeline will run only if commits are made in default branch(main)
    // commit branch --> branch where the commit will be made
    // default branch --> which is set to default value of main already
    // when this conditon becomes equal the pipeline runs
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

Stage0: static_code_analysis
Job0: lint
output: code quality report in json format

Stage1: build
Job1: build_code
output: artifacts
script:

    // Build my Go app so it runs safely inside a Linux Docker container
    // CGO_ENABLED=0 --> if not enabled, disables C bindings, keeps it fully static binary
    // GOOS=linux    --> making it linux specific
    // GOARCH=amd64  --> amd64 CPU architecture

    - CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o go-web-app-artifacts


Stage2: test
Job2: test-code
output: junit report in xml format
script:
    - echo "testing the code"
    // install go-junit-report dependency
    - go install github.com/jstemmer/go-junit-report/v2@latest
    // go-junit-report converst the etxt format code to xml format in the way gitlab can store
    // count=1 --> disables test caching, ensures fresh test runs in CI
    - go test ./... -v -count=1 | go-junit-report > report.xml

Stage3: build_image
Job3: build_docker_image
output: new build tagged docker image

build_docker_image:
  image: docker:24
  stage: build_image
  services:
    // To run docker build and docker tag commands insid conatiner, we need Docker CLI and docker daemon running
    // dind --> docker in docker

    // if no dind, then "cannot connect to docker daemon"
    - docker:24-dind

    // download the artifacts from build_code
    dependencies:
        - build_code

    script:
    // create image_name variable with docker image link as value

    // build the image with CI COMMIT SHA which create a new commit for new image built with random number, maintains a commit history of previous tag versions, so when deployment rollback is needed then helm rollback to previously tagged images

    - docker build -t $IMAGE_NAME:$CI_COMMIT_SHA .

    // tag the above image as latest
    - docker tag $IMAGE_NAME:$CI_COMMIT_SHA $IMAGE_NAME:latest

Stage4: push_image
Job4: push_docker_image
output: push the latest docker image to docker repo
script:
    // create a PAT with retention policy in Docker
    // Settings--> CI?CD --> variables --> Add docker username(masked) and docker password(PAT, masked and hidden)
    - docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD"

    (OR) use more safer option,
    - echo "DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

    // push both versions of image to docker hub registry
    // CI_COMMIT_SHA --> exact version control
    // latest --> easy dev usage
    - docker push $IMAGE_NAME:$CI_COMMIT_SHA
    - docker push $IMAGE_NAME:latest

Stage5: helm_upgrade
Job5: upgrade_deployment
output: upgrade exisitng deployment.yaml chart with latest build image
script:
    // upgrade go-web-app-chart deployment.yaml file with latest image tag
    // Helm updates Deployment using "--set image.tag=$CI_COMMIT_SHA"
    // Kubernetes sees new image tag
    // Kubernetes pulls the image --> kubernetes tells to CRI, then container runtime pulls the image from docker hub registry
    // Node
        ├─ kubelet
        ├─ container runtime (containerd / CRI-O)
        ├─ /var/lib/containerd
        └─ Pulled images stored here
    // Pods restart automatically

    - helm upgrade go-web-app ./go-web-app-chart --set image.tag=$CI_COMMIT_SHA


## Commands to verify before pipeline is triggered:
-----------------------------------------------------------

    // -v "$PWD:/app" --> This mounts your current project directory into the container
    // -w /app --> Sets the working directory inside container
    // --rm --> Deletes the container after run

    // running this ensures tests are running fine here, so it runs in CI also
    - docker run --rm -v "$PWD:/app" -w /app golang:1.22 go test ./...
        output: ok   github.com/your/app  0.234s

    - docker run --rm -v "$PWD:/app" -w /app golangci/golangci-lint:v1.56.2 golangci-lint run
        output : empty

## GIT Config
---------------------
// git config --list --> to get usrname and email details

## Continuous Delivery:
------------------------------------
//GitOps

Purpose: Argo-CD watches helm chart, whenever values.yaml is updated, pulls the helm chart , installs it on k8s cluster, if helm chart is already there, it just updates the helm chart in kubernetes cluster

ArgoCD --> pulls the helm chart from CI and deploy into kubernetes cluster

## Useful commands:
-----------------------------

// ls -R --> to find the folder structure of the project