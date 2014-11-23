#!/usr/bin/perl
#!C:/xampp/perl/bin/perl.exe -w

use CGI qw(:cgi-lib :standard);
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use Scalar::Util qw(looks_like_number);
use warnings;
use strict;

####VARIABLES
##  Defining variables

##Form definitions: Four arrays of the same length containing the properties of the forms.
# Names is strings, Lengths is integers, Weights is floats, and Data is arrays of integers
# There's also a variable that is incremented every time the setter is called to keep track of the amount of definitions.
my @catNames;
my @catLengths;
my @catWeights;
my @catData;
my $catCount = 0;

####PAGE CONSTRUCTION
##

##Start File and End File
# Used first and last to form the boilerplate of the HTML page.
sub startFile
{
print<<ENDPRINT; 
Content-type: text/html

<html>
<head>
	<meta charset="UTF-8" />
	<title>Gradebot 9023</title>
	<link href='http://fonts.googleapis.com/css?family=Raleway|Montserrat' rel='stylesheet' type='text/css'>
	<link rel="stylesheet" type="text/css" href="style.css">
	
</head>
<body>
ENDPRINT
}

sub endFile
{
print<<ENDPRINT; 
</body>
</html>
ENDPRINT
}

##Make Sidebar
# Create the sidebar and form manipulators
sub makeSidebar
{
print<<ENDPRINT;
	<div id="sidebarDiv">
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
				<div id="instructions">
					<p class="emphasis centered">Instructions</p>
					<p>Configure your input form here, click "Update", then fill out the input form.</p>
					<p>Updating the form will clear your input values, and vice versa.</p>
					<p>Check "New Category" and click "Update" to add a new category.<p>
					<p>Delete a category's name and click "Update" to remove it.<p>
					<p>Bookmark a form configuration to reuse it later!</p>
				</div>
			</form>
		</div>
	</div>
ENDPRINT
}
##Make Input Forms
# Create the forms that take in data.
sub makeInputForms
{
print<<ENDPRINT;
	<form method=post action="index.pl">
		<div class="inputForms">
			<div class="container centered">
				<label for="username">Username: </label><input type=text name="username" id="username"/>
			</div>
			<div class="container centered" id="inputFieldsets">
ENDPRINT
	printAllSets();
	print<<ENDPRINT;
			</div>
			<input type=hidden name="amountOfCategories" value="$catCount" />
			<input type=hidden name="gradesEntered" value="yes" />
			<input type=submit value="Submit" />
		</div>
	</form>
ENDPRINT
}

##Make Results
# Print out the results page
sub makeResults
{
	print("<div id='results'>\n\t");
	if(param("username") ne undef)
	{
		print("<div id='username' class='emphasis'>Username: ", param("username"),"</div>");
	}
	printData();
	printFinalGrade();
	print("</div>");
}

####DYNAMIC FORMS
##


##Variables to change the form definitions if needed.
# 
my @newCatNames = param("inputName");
my @newCatLengths = param("inputAmount");
my @newCatWeights = param("inputWeight");


##New Category: Appends a new form definition to the form quartet, the appends the count.
# This should always be used as opposed to directly modifying the arrays.
# Syntax: (name,length,weight)
sub newCat
{
	push(@catNames,$_[0]);
	push(@catLengths,$_[1]);
	push(@catWeights,$_[2]);
	push(@catData,[]);
	$catCount++;
}

##Text Input
# Returns the string of a text input tag
# Syntax is textInput(name)
sub textInput
{
	return sprintf("<input type=text name='$_[0]' />\n")
}

##Print Set: Print out a fieldset given a name, length, and legend.
# Syntax is printSet(name, length, legend)
sub printSet
{
print<<ENDPRINT;
	<fieldset class="inputCategory">
		<legend>$_[2]</legend>
ENDPRINT

	for(my $i = 0; $i < $_[1]; $i++)
	{
		print("\t\t", textInput($_[0]));
	}

print<<ENDPRINT;
		<input type=hidden name="nameOf$_[0]" value="$_[2]">
	</fieldset>
ENDPRINT
}

##Print all Sets
# Prints all set definitions
# Notes that the catNames are visual, and therefore are passed as legends, not names.
sub printAllSets
{
	for(my $i = 0; $i<$catCount; $i++)
	{
		printSet("cat$i",$catLengths[$i],$catNames[$i]);
		print("<input type=hidden name='inputWeights' value=$catWeights[$i]>\n");
	}
}

##Print Manipulator
# Prints a single manipulator, given parameters (name,amount,weight)
sub printManipulator
{
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
sub printAllManipulators
{
	for(my $i = 0; $i<$catCount; $i++)
{
		printManipulator($catNames[$i], $catLengths[$i], $catWeights[$i]);
	}
	if(param('newManipulator') eq 'on')
{
		printManipulator();
	}
	print<<ENDPRINT;
	<div>
		<label for="newcatbox">New Category:</label>
		<input type=checkbox name="newManipulator" id="newcatbox"/><input type=submit value="Update" />
	</div>
ENDPRINT
}

####OUTPUT RESULTS
##

##Normalize Weights
# Attempts to make all weights relative to 1.
# Takes input array, adds them to $total, multiplies each entry by 100/total
# Returns an array of the normalized weights
sub normalizeWeights
{
	my $total = 0;
	my @inWeights = @_;
	my @normWeights;
	foreach(@inWeights)
	{
		$total += $_;
	}
	foreach(@inWeights)
	{
		push(@normWeights, $_ * (1/$total));
	}
	return(@normWeights);
}

##Print data
# Prints all data entered in the fieldset
sub printData
{
	my @dataToPrint;
	my $sum;
	my $name;
	my $length;
	my $average;
	for(my $i = 0; $i < param("amountOfCategories"); $i++)
	{
		@dataToPrint = validate(param("cat$i"));
		$sum = getSum(@dataToPrint);
		$name = param("nameOfcat$i");
		$length = @dataToPrint;
		if($length==0){$length=1};
		$average = $sum/$length;
		print<<ENDPRINT;
		<div class="catResult">
			<h4>$name</h4>
ENDPRINT
		foreach(@dataToPrint)
		{
			printf("\t\t\t<p class='gradeValue'>$_</p>\n");
		}
		printf("<p class='equation emphasis'>%d / %d = %.2f</p>\n</div>",$sum,$length,$average);
	}
}

##Print Final Grade
# prints a div containing the final grade data
sub printFinalGrade
{
	my @singleCat;
	my @catAverages;
	my @weights = normalizeWeights(param("inputWeights"));
	my $length;
	print<<ENDPRINT;
	<div id="finalGrade">
ENDPRINT
	for(my $i = 0; $i < param("amountOfCategories"); $i++)
	{
		@singleCat = validate(param("cat$i"));
		$length = @singleCat;
		if($length == 0){
			$length = 1;
		}
		push(@catAverages, $weights[$i]*(getSum(@singleCat)/$length));
		printf("<div><div class='fgLabel'>%s:</div>%d</div>",param("nameOfcat$i"),$catAverages[$i]);
	}
	my $finalGrade = int(getSum(@catAverages));
	print("<b><div class='fgLabel'>Final Grade:</div>",$finalGrade,"<div class='gradeLetter'></b>",
	getGrade($finalGrade),"</div>\n</div>");
}

##Get Sum
# Convenience function using foreach to get the sum of an array.
sub getSum
{
	my $sum;
	foreach(@_)
	{
		$sum += $_;
	}
	return $sum;
}

##Validate Grade
# Error-traps a number array by forcing numbers greater than or less than a range
# to be set to the bounds of that range instead. It's hard-coded with 0-100;
# Also sets anything with letters to "pass"
# Parameters: (@array), Returns the valid array
sub validate{
	my @validArray = @_;
	for(my $i; $i<@validArray;$i++)
	{
		if(looks_like_number($validArray[$i]))
		{
			if($validArray[$i]<0)
			{
				$validArray[$i]=0;
			}
			elsif($validArray[$i]>100)
			{
				$validArray[$i]=100;
			}
		}
		else{
			$validArray[$i]=0;
		}
	}
	return @validArray;
}

##Get Grade
# Compares input to a grading scale, returns the letter
sub getGrade{
	my $grade=$_[0];
	if($grade>=93){return "A";}
	elsif($grade>=90){return "A-";}
	elsif($grade>=87){return "B+";}
	elsif($grade>=83){return "B";}
	elsif($grade>=80){return "B-";}
	elsif($grade>=77){return "C+";}
	elsif($grade>=73){return "C";}
	elsif($grade>=70){return "C-";}
	elsif($grade>=67){return "D+";}
	elsif($grade>=63){return "D";}
	else{return "F";}
}
####PREPARATION
##

if(@newCatNames==0)
{
	newCat("Projects",5,60);
	newCat("Quizzes",5,40);
}
else
{
	for(my $i = 0; $i<@newCatNames; $i++)
	{
		if($newCatNames[$i] ne undef)
		{
			newCat($newCatNames[$i],$newCatLengths[$i],$newCatWeights[$i]);
		}
	}
}

####MAIN PROGRAM
##
startFile();
makeSidebar();
if(param("gradesEntered") ne "yes")
{
	makeInputForms();
}
else
{
	makeResults();
}
endFile();
