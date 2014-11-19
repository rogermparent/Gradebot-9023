#!/usr/bin/perl
#!C:/xampp/perl/bin/perl.exe -w

use CGI qw(:cgi-lib :standard);
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
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
	<title>Graderbot 9023</title>
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
##Make Input Forms
# Create the forms that take in data.
sub makeInputForms
{
print<<ENDPRINT;
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
	printData();
	printFinalGrade();
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
	<fieldset class="category">
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
		print("<input type=hidden name='inputWeights' value='$catWeights[$i]'>\n");
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
		<label for="newcatbox">New category?:</label>
		<input type=checkbox name="newManipulator" id="newcatbox"/><input type=submit value="Update" />
	</div>
ENDPRINT
}

####OUTPUT RESULTS
##

##Normalize Weight
# Attempts to make all weights relative to 1.
# Takes input array, adds them to $total, multiplies each entry by 100/total
# Returns an array of the normalized weights
sub normalizeWeights
{
	my $total = 0;
	my @normWeights = [];
	foreach(@_)
{
		$total += $_;
	}
	foreach(@_)
{
		(@normWeights, $_ * (1/$total));
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
		@dataToPrint = param("cat$i");
		$sum = getSum(@dataToPrint);
		$name = param("nameOfcat$i");
		$length = @dataToPrint;
		$average = $sum/$length;
		print<<ENDPRINT;
		<div class="catResult">
			<h4>$name</h4>
ENDPRINT
		foreach(@dataToPrint)
		{
			printf("\t\t\t<p class='gradeValue'>$_</p>\n");
		}
		print<<ENDPRINT;
			<p class="equation">$sum / $length = $average</p>
		</div>
ENDPRINT
	}
}

##Print Final Grade
# prints a div containing the final grade data
sub printFinalGrade
{
	my @singleCat;
	my @catAverages;
	my @weights = param("inputWeights");
	@weights = normalizeWeights(@weights);
	print<<ENDPRINT;
	
ENDPRINT
	for(my $i = 0; $i < param("amountOfCategories"); $i++)
	{
		@singleCat = param("cat$i");
		push(@catAverages, getSum(@singleCat)/@singleCat);
		print($catAverages[$i], " ");
	}
	print('\n', $weights[0]);
}

##Get Sum and Get Average
# Convenience functions using foreach to get the sum or average of an array.
sub getSum
{
	my $sum;
	foreach(@_)
	{
		$sum += $_;
	}
	return $sum;
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
if(param("gradesEntered") ne "yes")
{
	makeSidebar();
	makeInputForms();
}
else
{
	makeResults();
}
endFile();
