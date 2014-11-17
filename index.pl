#!"C:\xampp\perl\bin\perl.exe"

use CGI qw(:cgi-lib :standard);
use warnings; use strict;

#### PAGE CONSTRUCTION
##

##Start File and End File
# Used first and last to form the boilerplate of the HTML page.
sub startFile{ print<<ENDPRINT; 
Content-type: text/html

<html>
<head>
	<meta charset="UTF-8" />
	<title>Graderbot 9023</title>
	<link rel="stylesheet" type="text/css" href="style.css">
</head>
ENDPRINT
printScript();
print<<ENDPRINT;
<body>
ENDPRINT
}

sub endFile{ print<<ENDPRINT; 
</body>
</html>
ENDPRINT
}

##Make Sidebar and Make Content
# Create the bulk of the page.
sub makeSidebar{ print<<ENDPRINT;
	<div id="auxforms">
		<a href="index.pl">
			<img src = "images/logo.png" />
		</a>
		<div class="centered">
			<form method=post action="index.pl">
				<fieldset id="inputchangers">

				</fieldset>
			</form>
		</div>
	</div>
ENDPRINT
}
sub makeContent{ print<<ENDPRINT;
	<form method=post action="index.pl">
		<div class="mainforms">
			<div class="container centered">
				<label for="username">Username: </label><input type=text name="username" id="username"/>
			</div>
			<div class="container centered" id="quizzesandtests">
ENDPRINT
	printAllSets();
	print<<ENDPRINT;
			</div>
			<input type=submit value="Submit">
		</div>
	</form>
ENDPRINT
}

## Print Script: Prints the javascript for changing the form amounts.
#
sub printScript{print<<ENDPRINT;
<script>
	function addInput(){
		var form = parent.children[1].cloneNode(true);
		prompt(form);
	}
</script>
ENDPRINT
}

#### DYNAMIC FORMS
##

## Form definitions: Four arrays of the same length containing the properties of the forms.
#  Names is strings, Lengths is integers, Weights is floats, and Data is arrays of integers
#  There's also a variable that is incremented every time the setter is called to keep track of the amount of definitions.
my @catNames;
my @catLengths;
my @catWeights;
my @catData;
my $catCount = 0;

## New Category: Appends a new form definition to the form quartet, the appends the count.
#  This should always be used as opposed to directly modifying the arrays.
#  Syntax: (name,length,weight)
sub newCat{
	push(@catNames,$_[0]);
	push(@catLengths,$_[1]);
	push(@catWeights,$_[2]);
	push(@catData,[]);
	$catCount++;
}

## Text Input
#  Returns the string of a text input tag
#  Syntax is textInput(name)
sub textInput{return sprintf("<input type=text name='$_[0]' />\n")}

## Print Set: Print out a fieldset given a name, length, and legend.
#  Syntax is printSet(name, length, legend)
sub printSet{ print<<ENDPRINT;
	<fieldset class="category">
		<legend>$_[2]</legend>
ENDPRINT

	for(my $i = 0; $i < $_[1]; $i++){
		print("\t\t", textInput($_[0]));
	}

print<<ENDPRINT;
		<button type="button" class="addButtons" onClick="addInput()">+</button>
		<button type="button" class="delButtons">-</button>
	</fieldset>
ENDPRINT
}

## Print all Sets
#  Prints all set definitions
#  Notes that the catNames are visual, and therefore are passed as legends, not names.
sub printAllSets{
	for(my $i = 0; $i<$catCount; $i++){
		printSet("cat$i",$catLengths[$i],$catNames[$i]);
	}
}

#### OUTPUT RESULTS
##



#### PREPARATION
##

if($catCount==0){
	newCat("Projects",5,60);
	newCat("Quizzes",5,40);
}

#### MAIN PROGRAM
##
startFile();
makeSidebar();
makeContent();
endFile();