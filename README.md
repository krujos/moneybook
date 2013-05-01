Moneybook
=========

Easy interface to add lines to our money book. Our moneybook is a google spreadsheet that my wife and I use to keep track of the checking account. 

Getting Started
===============
    git clone https://github.com/krujos/moneybook.git
	bundle install
	bundle package
	echo CLIENT_ID="<google client id>" >>.env
	echo CLIENT_SECRET="<google client secret>" >> .env
	SHEET_KEY="<your spreadsheet key>" >> .env
	rackup

Spreadsheet keys are part of the url when you look at the spreadsheet in drive (key parameter).
	https://docs.google.com/spreadsheet/ccc?key=0AqHWdZFeQl3edFBmajRnUnl6bVZKN0JkYS1xTVNGSFE#gid=0	
