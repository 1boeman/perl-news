#!/usr/bin/perl -wT

package CrawlerUtil;

use strict;
use URI;
use XML::Feed;
use Exporter;
use URI::Escape;
use Try::Tiny;
use HTML::StripTags qw(strip_tags); 
use HTML::Template; 
use XML::LibXML; 

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = qw( htmlify_feed $export_dir );
@EXPORT_OK   = qw();
%EXPORT_TAGS = ( DEFAULT => [qw()],
                 Both    => [qw()]);

our $export_dir = '.'; 


sub htmlify_feed{
	my %args = @_;
	
	my $uri = $args{uri} || die 'uri param required';  
	my $outputdir = $args{outputdir} || die 'param missing outputdir'; 
	my $item_template = $args{item_template} || die 'param missing item_template';
	my $block_template = $args{block_template} || die 'param missing block_template';
	my $maximum_items = $args{maximum_items} || 0; 

	my $html_list = ''; 
	my $feed = 0; 
	my ($body,$link,$title,@teaser,$teaser,$template,$feed_title,$template_block);
	my $maximum_body_words = 200; 
	my $iterator = 0; 

    unless (-d $outputdir){
        die 'Output dir not found: ' . $outputdir;
    }

	print "\n\n";
	print "Now feeding on: ".$uri."\n";

 	my $htmllist = '';
	
	my $outputfilename = substr $outputdir.'/'.uri_escape($uri), 0,200;

	try {
		$feed = XML::Feed->parse(URI->new($uri)) or print "FAIL-2: ".$uri.' --- ' . XML::Feed->errstr;
	} catch {
		print "FAIL-0: ". $uri;  
		return;   
	};

	if (!$feed){
		print "FAIL-1: ".$uri; 
		return;
	}
			
	open(OUTPUT_FILE,">".$outputfilename); 
	binmode(OUTPUT_FILE, ":utf8");
		
	for my $entry ($feed->entries) {
		$template = HTML::Template->new(filename=>$item_template); 
		$link = $entry->link; 
		$title = strip_tags($entry->title);
		$body = $entry->content->body;
	
		$template->param(link=>$link); 
		$template->param(title=>$title); 
		if ($body){
			$body = strip_tags($body); 
			@teaser = split /\s+/, $body;
			if (scalar(@teaser) > $maximum_body_words ){
				$body = join ' ', @teaser[0..$maximum_body_words]; 
			}
			$template->param(body=>$body)
		}
		$html_list .= $template->output;
		
		if ($maximum_items){
			$iterator++; 
			if ($iterator == $maximum_items){
				last; 
			}
		}
	}
		
	$template_block = HTML::Template->new(filename=>$block_template); 
	$template_block->param(block_html=>$html_list); 
	$template_block->param(title=> ($feed->title || $uri)); 

	print OUTPUT_FILE $template_block->output; 
	print "Output stored in $outputfilename \n".
	close (OUTPUT_FILE);
}




