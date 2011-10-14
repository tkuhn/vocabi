#!/usr/bin/perl

#-------------------------------------------------------------------------------
# vocabi (Command-Line Vocabulary Builder)
#-------------------------------------------------------------------------------
# Version: 0.0.1
# Date: 14 October 2011
# Author: Tobias Kuhn
#-------------------------------------------------------------------------------

use strict;
use List::Util 'shuffle';

print "\n";
print "********************\n";
print "    V O C A B I     \n";
print " vocabulary builder \n";
print "********************\n";
print "\n";

if ($#ARGV eq -1) {
	print "Arguments:\n";
	print "-s 5   enable scoring and use all entries with score 5 or less\n";
	print "-s 0   enable scoring and use all entries with score 0\n";
	print "-s -1  enable scoring and use all entries\n";
	print "-f     present entries in forward direction (first part is shown first)\n";
	print "-b     present entries in backward direction (default)\n";
	print "-m     present entries in mixed direction\n";
	print "\n";
	exit;
}

my $file;
my @lang1;
my @lang2;
my @score;
my @ind;
my $direction = 1;   # 0 forward; 1 backward; 2 mixed
my $smax = -2;   # -2 scores off; -1 all scores; 0-* max score

while (1) {
	if ($ARGV[0] eq "-s") {
		shift(@ARGV);
		$smax = shift(@ARGV) + 0;
	} elsif ($ARGV[0] eq "-f") {
		$direction = 0;
		shift(@ARGV);
	} elsif ($ARGV[0] eq "-b") {
		$direction = 1;
		shift(@ARGV);
	} elsif ($ARGV[0] eq "-m") {
		$direction = 2;
		shift(@ARGV);
	} else {
		last;
	}
}

$file = shift(@ARGV);

open(IN, $file);

my $line;

while ($line = <IN>) {
	chop $line;
	my @rec = split(/:/, $line);
	my $s = $rec[2] + 0;
	push(@lang1, $rec[0]);
	push(@lang2, $rec[1]);
	push(@score, $s);
	if ($smax < 0 || $s <= $smax) { push(@ind, $#lang1); }
}

close(IN);

@ind = shuffle(@ind);

print "Using " . ($#ind+1) . " of " . ($#lang1+1) . " entries from file $file\n\n";
print "Commands:\n";
print "q  quit\n";
print ">  next\n";
print "<  previous \n";
if ($smax > -2) {
	print "+  increase score\n";
	print "-  decrease score\n";
	print "\$  set score to 0\n";
	print "1  set score to 1\n";
	print "2  set score to 2, etc.\n";
}
print "\n";

for (my $i = 0 ; $i <= $#ind+1 ; $i++) {
	my $n = $ind[$i];
	
	my $d = $direction;
	if ($d == 2) { $d = $i % 2; }
	
	my $sep = "";
	if ($i == $#ind+1) {
		$sep = "===== FINISHED =====";
	} else {
		for (my $p = 0 ; $p < 20 ; $p++) {
			if ($i/($#ind+1) > $p/20 + 0.025) { $sep .= "="; } else { $sep .= "-"; }
		}
	}
	print "\n$sep\n";
	
	if ($i <= $#ind) {
		if ($d == 0) {
			print $lang1[$n];
		} else {
			print $lang2[$n];
		}
		print "   ? ";
	} else {
		print "[press enter to quit] ";
	}
	
	my $in = <STDIN>;
	chop $in;
	$in = lc $in;
	my $action = 0;
	
	if ($i > $#ind && $in ne "<") {
		$in = "q";
	}
	
	if ($in =~ "[q<>]") {
		$action = $in;
	} else {
		if ($in ne "") {
			print "[invalid command]\n";
		}
		if ($d == 0) {
			print "$lang2[$n]";
		} else {
			print "$lang1[$n]";
		}
		if ($smax > -2) {
			print "   ($score[$n]) ";
			$in = <STDIN>;
			chop $in;
			$in = lc $in;
			if ($in =~ /[0-9]+/) {
				$score[$n] = $in;
			} elsif ($in eq "+" || $in eq ".") {
				$score[$n]++;
			} elsif ($in eq "-" && $score[$n] > 0) { 
				$score[$n]--;
			} elsif ($in eq "\$") {
				$score[$n] = 0;
			} elsif ($in =~ "[q<>]") {
				$action = $in;
			} elsif ($in ne "") {
				print "[invalid command]\n";
			}
		} else {
			print "\n";
		}
	}
	
	if ($action eq "<") {
		if ($i > 0) {
			$i = $i - 2;
			print "<<<<< PREVIOUS <<<<<\n\n";
		} else {
			$i = -1;
			print "<<<<<< FIRST <<<<<<<\n\n";
		};
		next;
	} elsif ($action eq "q") {
		print "======= QUIT =======\n\n";
		last;
	}
	
	print "$sep\n\n";
}

open(OUT, ">$file");

for (my $i = 0; $i < $#lang1+1; $i++) {
	print(OUT "$lang1[$i]:$lang2[$i]:$score[$i]\n");
}

close(OUT);

