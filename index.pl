#!/usr/bin/perl

use CGI qw(:cgi-lib :standard);
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use warnings;
use strict;

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
			<form method=get action="index.pl">
				<div id="manipulators">
ENDPRINT
	printAllManipulators();
	print<<ENDPRINT;
				</div>
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

## Variables to change the form definitions if needed.
#  
my @newCatNames = param("inputName");
my @newCatLengths = param("inputAmount");
my @newCatWeights = param("inputWeight");


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

## Print Manipulator
#  Prints a single manipulator, given parameters (name,amount,weight)
sub printManipulator{
	print<<ENDPRINT;
	<fieldset class="manipulator">
		<legend>
		<input type=text name="inputName" value="$_[0]" />
		</legend>
		<div><label>Inputs:</label><input type=number name="inputAmount" value="$_[1]"/></div>
		<div><label>Weight:</label><input type=number name="inputWeight" value="$_[2]"/></div>
	</fieldset>
ENDPRINT
}

##Print All Manipulators
# Calls Print Manipulator for every definition
sub printAllManipulators{
	for(my $i = 0; $i<$catCount; $i++){
		printManipulator($catNames[$i], $catLengths[$i], $catWeights[$i]);
	}
	if(param('newManipulator') eq 'on'){
		printManipulator();
	}
	print<<ENDPRINT;
	<div>
		<label for="newcatbox">New category?:</label>
		<input type=checkbox name="newManipulator" id="newcatbox"/><input type=submit value="Update" />
	</div>
ENDPRINT
}

#### OUTPUT RESULTS
##



#### PREPARATION
##

if(@newCatNames==0){
	newCat("Projects",5,60);
	newCat("Quizzes",5,40);
}else{
	for(my $i = 0; $i<@newCatNames; $i++){
		if($newCatNames[$i] ne undef){
			newCat($newCatNames[$i],$newCatLengths[$i],$newCatWeights[$i]);
		}
	}
}

#### MAIN PROGRAM
##
startFile();
makeSidebar();
makeContent();
endFile();
