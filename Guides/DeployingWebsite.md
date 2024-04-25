# Cobb Connect Deployment Guide

## Building the project (Optional)
Building the project is only necessary if you do not have the flutter website's HTML/CSS/JAVASCRIPT files already available.
<br>
Within the context of our project these files would be stored in `gcisl-fullstackapp/build/web`.

#### Requirements
If you do not have Flutter installed you will not be able to build the project.
<br>
Follow instructions `https://docs.flutter.dev/get-started/install` to install Flutter. 

#### Step 1 - Cloning

In an empty directory run
`git clone https://github.com/WSUCptSCapstone-F23-S24/gcisl-fullstackapp`
<br>
This will clone the directory onto your machine. 
<br>

If you have permissions issues with cloning this directory, reach out to the head of the CS Capstone course for help. <br>At the time of writing this document, the head is Ananth Jillepalli who can be reached at ananth.jillepalli@wsu.edu

#### Step 2 - Building
After cloning the project `cd` into the directory via `cd gcisl-fullstackapp`
<br>
Run the command `flutter build web`
<br>
The project should take a little over a minute to build

#### Step 3 - Retrieving Files
All files for the website will be stored in `gcisl-fullstackapp/build/web`
<br>
Copy this folder to any platform you want to deploy the website on

## Deploying the Project
There are many ways to deploy a web based application. Below I will suggest one method. 
<br>
For our web based app, if the project has already been built, all you need to deploy from the project are the files stored in `gcisl-fullstackapp/build/web`
<br>
#### Requirements
You need to have python installed

#### Step 1 - Correct Directory
`cd` into the root of the web files.
<br>
If you are doing this from the `gcisl-fullstackapp` directory you need to run `cd gcisl-fullstackapp/build/web`

#### Step 2 - Serving Content
After successfully `cd`ing into the web folder, all you need to do is run the command
`python -m http.server <PORT#>`
<br>
If you want to host it locally for debugging, you can choose a port number like 8000. In this case you would run
<br>
`python -m http.server 8000`
<br>
Then to access the website you could visit `http://localhost:8000`
<br>
If you wanted to host the website so others could access it you should host it on http, which is port `80`
<br>
`python -m http.server 80`