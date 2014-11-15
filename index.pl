#!/usr/bin/perl

use CGI qw(:cgi-lib :standard);

#Declare variables and set them to form inputs if available
$quizinputs = param("quizinputs");
$testinputs = param("testinputs");
@quizgrades = param("quizgrades");
@testgrades = param("testgrades");

##Create a small default-setting subroutine, takes (input variable, default settings)
# It returns the value if input isn't undef, and the default if it is.
##Then use it to give variables their default settings
sub default{
	if(@_[0]==undef){return @_[1];}
	else{return @_[0];}
}
$quizinputs = default($quizinputs,5);
$testinputs = default($testinputs,5);

##Subroutine to start the file, with everything else contained in a div named "mainforms".
sub startfile{
print<<ENDPRINT; 
Content-type: text/html

<html>
<head>
	<meta charset="UTF-8" />
	<title>Perl Template</title>
	<link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
	<div id="mainforms">
ENDPRINT
}

##Subroutine to end the content div and printed HTML file.
sub endfile{
print<<ENDPRINT;
	</div>
</body>
</html>
ENDPRINT
}

##The logo, name form, and input amount changer are in a seperate div
# This subroutine creates that div
sub auxforms{
	print<<ENDPRINT;
	<div id="auxforms">
		<a href="index.pl">
			<img src = "images/logo.png" />
		</a>
		<div class="centered">
			<input type=text name="username" placeholder="Your name"/>
			<form method=post action="index.pl">
				<fieldset id="inputchangers">
					<legend>Change the amount of grades</legend>
					<input type=number name="quizinputs" value="$quizinputs"/>
					<input type=number name="testinputs" value="$testinputs"/>
					<input type=submit value="Change" />
				</fieldset>
			</form>
		</div>
	</div>
ENDPRINT
}
##This is the subroutine to create the forms
# Takes amount of inputs for (Quiz form, Test form)
# Between the print statements, other routines are called to create the Quiz and Test formspans seperately
sub mainforms{
	print<<ENDPRINT;
	<form method=post action="index.pl">
		<div class="mainforms">
ENDPRINT

	makequizform(@_[0]);
	maketestform(@_[1]);

	print<<ENDPRINT;
			<input type=submit value="Submit">
		</div>
	</form>
ENDPRINT
}

##Make Quiz Form
# Takes a number and generates a quiz form with that many inputs.
sub makequizform{
	print<<ENDPRINT;
	<fieldset id="quizzes">
		<legend>Quizzes</legend>
ENDPRINT

	#loop to print out x amount of Quiz grade inputs
	for($i=1;$i<=@_[0];$i++){
		print("\t\t");#Tabs to make the HTML look nice
		textinput("quizgrades","Quiz Grade $i");
	}

	print<<ENDPRINT
	</fieldset>
ENDPRINT
}

##Make Test Form
# Identical to Make Quiz Form, but for the Test form
sub maketestform{
	print<<ENDPRINT;
	<fieldset id="tests">
		<legend>Tests</legend> 
ENDPRINT

	#ditto for tests
	for($i=1;$i<=@_[0];$i++){
		print("\t\t");#Tabs to make the HTML look nice
		textinput("testgrades","Test Grade $i");
	}

	print<<ENDPRINT;
	</fieldset>
</div>
ENDPRINT
}

##Generic text input tag creator
# Takes (name, placeholder)
sub textinput{
	printf("<input type='text' name='%s' placeholder='%s' />\n", @_[0], @_[1]);
}


##Main section
# Print the page
startfile();

mainforms($quizinputs,$testinputs);
auxforms();

endfile();
