This is an app for collecting various statistics and pushing them into a leftronics dashboard.

It is run automatically via a heroku scheduler.
If you have access you can see the settings of the heroku app here:
https://dashboard.heroku.com/apps/leftronic-push

It can also be run locally. The easiest way to run it locally is with the foreman command.

Inorder to use foreman you need to:

- install the heroku toolbelt
  you should have been prompted to do that when signing up at heroku)
- copy the env.sample -> .env
  this is where to store local private information, on the server it is setup with heroku config
- edit .env to have a valid configuation 
- run it with `foreman collect_and_push`

To update the code on heroku:

- add a heroku remote to you checkout of this repository:
  `git remote add heroku git@heroku.com:leftronic-push.git`
- you will probably need to setup a ssh key pair if you haven't already
    - login to heroku: `heroku login`
    - this will ask you to select a ssh key if you don't have on in your account
- push the code to heroku `git push heroku master`

How the script is run

- the script is run using the scheduler:standard
- you can open the web configuration from the commandline with:
  `heroku addons:open scheduler:standard`
