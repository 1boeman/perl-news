#!/usr/bin/perl -w

# feeds to html gets feeds from xml files in directory and retrieves/parses their content to html 
# saves html files 

use strict; 
use lib "..";
use CrawlerUtil; 
use Data::Dumper; 
use Getopt::Std;
use Cwd;
our (%opts,$page_dir,$dir,$input_dir,$output_dir); 
getopt('uid', \%opts); 

$dir = getcwd; 

# option i contains inputdirectory
if ($opts{i}){
	$input_dir = $opts{i}; 
}else{
	$input_dir = $dir.'/../pages';
}

if ($opts{d}){
	$output_dir = $opts{d}; 
}else{
	$output_dir = $dir.'/../../newscrawl_output/feeds';
}

&clean_output_dir();
&get_pages_feeds ( $input_dir ); 

sub clean_output_dir{
	my (@files,$file);
	opendir(D,$output_dir);
	@files = readdir(D); 
	closedir (D);
	foreach $file (@files){
		if ($file =~ /\.xml$/){
			print 'deleting ' .  $output_dir . '/' . $file."\n"  ; 
			unlink( $output_dir.'/'.$file ); 
		}
	}
}

sub get_pages_feeds{
	my ($pagedir) = @_; 
	my ($file, @files, $page_parser,$dom,@feeds,@nodes,$node,%hash,@unique_feeds,$feed);

	# option u contains single feed url 	
	if ($opts{u}){
		@unique_feeds = ($opts{u});
	}else{
		opendir(D,$pagedir); 
		@files = readdir(D); 
		closedir (D);

		foreach $file (@files) {
			if ($file !~ /\.xml$/){
				next;
			}
			$dom = XML::LibXML->load_xml(
				location => $pagedir.'/'.$file 
			      # parser options ...
			);
			@nodes = $dom->getElementsByTagName('feed'); 
			foreach $node (@nodes){
				push (@feeds,$node->firstChild->data);
			}
		}
		%hash   = map { $_, 1 } @feeds;
		@unique_feeds = keys %hash;
	}
		
	foreach $feed (@unique_feeds){
		CrawlerUtil::htmlify_feed (
			uri=>,$feed, 
			outputdir=>$output_dir,
			item_template=>$dir.'/../templates/item.html',
			block_template=>$dir.'/../templates/block.html',
			maximum_items => 20
		);
	}
}

