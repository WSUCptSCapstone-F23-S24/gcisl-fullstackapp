# Firebase Maintenance

## General Info
For the purposes of consolidation we have moved all firebase and google maps api keys under the umbrella of one gmail account: `cobbconnectwsu@gmail.com`. The password for this account is `gocougs!`


## Prerequisites
To perform maintenance on firebase, logging in is required. Assume that for all instructions below you must be logged in. 
<br>
To login the following steps are necessary:
<ol>
<li>Navigate to https://firebase.google.com</li>
<li>Sign in using `cobbconnectwsu@gmail.com`</li>
</ol>


## Deleting User
If you want to delete a user's account, the following actions are necessary
<ol>
<li>From the homepage once you have logged into firebase open the "build" tab on the left bar</li>
<li>Click on "Authentication" option under the build tab</li>
<li>Hover over the user you want to delete, three dots should appear on the right side of their tab</li>
<li>Click on three dots, and select "delete"</li>
</ol>

## Deleting All Posts
Individual posts should be deleted from within the website on an admin account such as `admin@wsu.edu`
<br>
If you want to delete all user posts do the following: 
<ol>
<li>From the homepage once you have logged into firebase open the "build" tab on the left bar</li>
<li>Click on "Realtime Database" option under the build tab</li>
<li>On the new page you should see a card that says 'posts'</li>
<li>Hover over it and a trash can will appear to the right of it, press on that icon</li>
</ol>

## Clearing Database

#### Clearing Users
To clear the database you must manually delete all users. See the `Deleting User` section on how to delete a singular user. Apply those instructions except do it to every user on the site.

#### Clearing Data
If you want to delete all database data the following instructions:
<ol>
<li>From the homepage once you have logged into firebase open the "build" tab on the left bar</li>
<li>Click on "Realtime Database" option under the build tab</li>
<li>On the new page you should multiple cards nested under a url similar to "http://cobb-connect-ef4c7-default-rtdb.firebaseio.com"</li>
<li>For each card under that URL, you should hover over it and click the trash can icon that appears</li>
<li>When you are finished there should be no cards nested under the URL</li>
</ol>

#### Clearing Storage
If you want to delete all database data the following instructions:
<ol>
<li>From the homepage once you have logged into firebase open the "build" tab on the left bar</li>
<li>Click on "Storage" option under the build tab</li>
<li>You should see a list of files with a checkbox on the left side of each one</li>
<li>On the top bar of the menu containing all of these dropdowns there is a checkbox that will select all the files</li>
<li>Select all the files by checking the checkbox on the top bar, then press the delete button that appears on the top bar. </li>
</ol>

