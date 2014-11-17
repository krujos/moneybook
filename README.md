Moneybook
=========

Easy interface to add lines to our money book. Our moneybook is a google spreadsheet that my wife and I use to keep track of the checking account. 

##Getting Started
    git clone https://github.com/krujos/moneybook.git
	bundle install
	bundle package

Now edit the manifest to use your sheet key (see below). Also download client_secrets.json from the google developer console and copy it into the repo. Ensure that you have the correct callback uri's and java script origins in the developer console for your deployment. 

Now that you've done all that you can test locally (make sure localhost:9292 is an authroized callback URL). 

	rackup
	
I've deployed this to CloudFoundry and OpenShift with no problem. I suggest CloudFoundry as the manifest is there and ready for you.

##Notes

Spreadsheet keys are part of the url when you look at the spreadsheet in drive (key parameter).
	https://docs.google.com/spreadsheet/ccc?key=0AqHWdZFeQl3edFBmajRnUnl6bVZKN0JkYS1xTVNGSFE#gid=0	

