#!/usr/bin/perl -w
use HTML::Template;
use strict; 
use Data::Dumper; 
use Getopt::Std;
use URI::Escape;

use XML::LibXML; 
my ($file,@files,$page_dir); 

$page_dir = '../pages';

opendir(D,$page_dir);
@files = readdir(D); 
closedir (D);

foreach $file (@files) {
	if ($file =~ /xml/){
		&page_xml_to_html ($page_dir , $file,
			'../templates/page.html',
				'../../newscrawl_output/feeds',
					'../../newscrawl_output/pages'); 
	}
}

sub page_xml_to_html{
	my ($section,$template,@feeds,$feed,@section_html,$item_html,@page_data,$feed_src,$hash); 
	my ($filepath,$filename, $page_template, $data_dir,$output_dir) = @_;   
    unless (-d $output_dir) {
        die 'Output dir not found: ' . $output_dir;
    }
    	
	my $parser = XML::LibXML->new();
	my $doc = XML::LibXML->load_xml(location => $filepath. '/' .$filename ); 
	my @sections = $doc->findnodes('/page/section');
		
	$template = HTML::Template->new(filename=>$page_template); 
	@page_data = (); 
	foreach $section (@sections){
		@section_html = (); 
		
		@feeds = $section->findnodes('./feed'); 

		foreach $feed (@feeds){
			$hash = uri_escape($feed->firstChild->data); 
			$feed_src = substr $data_dir.'/'.$hash, 0,200;
			
			open (FILE, $feed_src) or next;  #di ('Failed to open '. $feed_src);
			print "\nopened".$feed_src;

			$item_html = join("", <FILE>);
			close(FILE); 
				
			push (@section_html,$item_html); 
		}
		
		push (@page_data,{section => join(" ",@section_html)});
	}

	$template->param(sections => \@page_data);
	$filename =~ s/xml$/html/; 	
	print $filename; 
	open PAGE_FILE, '>', $output_dir.'/'.$filename;
	
	print PAGE_FILE $template->output; 
	close PAGE_FILE; 
	print "\nwrote ".$output_dir.'/'.$filename."\n"; 
}




