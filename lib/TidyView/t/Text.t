#!/usr/bin/perl

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
  use_ok('TidyView::Text');
};

require_ok('TidyView::Text');

can_ok('TidyView::Text', qw(
			    new
			    insertFile
			    insertText
			    replace
			    yview
			    configure
			    yviewMoveto
			    length
			    balanceText
			   )
      );

use Log::Log4perl qw(:levels get_logger);

Log::Log4perl->init_and_watch('bin/log.conf', 10);

my $logger = get_logger((caller(0))[3]);

use Tk;

my $main_win = MainWindow->new();
$main_win->configure(-title => 'TidyView', );
$main_win->geometry('+0+0');

my $tt = TidyView::Text->new(parent => $main_win);

isa_ok($tt, 'TidyView::Text');

$tt->insertText("");

is($tt->length(), 0, "recorded we added 0 lines");

$tt->insertText("\n");

is($tt->length(), 1, "recorded we added 1 lines");

$tt->insertText("\n\n");

is($tt->length(), 3, "recorded we added 2 lines - to total 3");

$tt->replace("");

is($tt->length(), 0, "recorded we deleted all lines and added none");

$tt->replace("\n");

is($tt->length(), 1, "recorded we deleted all lines and added one");

$tt->replace("\n\n");

is($tt->length(), 2, "recorded we deleted all lines and added two");

# test balancing algorithm

my $tt2 = TidyView::Text->new(parent => $main_win);

$tt2->insertText("");

is($tt2->length(), 0, "empty pane");

TidyView::Text->balanceText(left  => $tt,
			    right => $tt2);

is($tt ->length(), 2, "unchanged after balancing");
is($tt2->length(), 2, "added two lines to balance");
