Perl-news
=========

Parse  RSS feeds to easily embeddable html fragments or pages. 

Installation:
------------
On Ubuntu/Debian first apt-get install libxml-libxml-perl and libxml-feed-perl if necessary & use CPAN to install HTML::StripTags.

Run make to create the expected output directories.

Run update_everything to parse all feeds specified in the in the xml files in the pages directory.
One xml file in the ./pages directory corresponds to one html file in the newscrawl_output/pages directory.



