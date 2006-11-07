package TidyView::Text;

use strict;
use warnings;

use IO::File;
use Tk::ROText;

use Log::Log4perl qw(get_logger);
use Data::Dumper;

my @scrolledWidgets = (); # scrollbar-linked widgets

my %color = (
	norm   => [],
	add    => [-background => '#aaffaa'],
	del    => [-background => '#ffaaaa'],
	pad    => [-background => '#f0f0f0'],
);

sub new {
  my ($proto, %args) = @_;

  my $class = ref $proto || $proto;

  my ($parent, $scrollbar) = @args{qw(parent scrollbar)};

  return unless $parent;

  my $self = bless {}, $proto;

  # line is nt visible, but is used for helpig with the coloured diff display
  $self->{line} = $parent->ROText(
				  -width       => 5,
				  -background  => '#e0e0e0',
				  -foreground  => '#a0a0a0',
				  -borderwidth => 0,
				  -state       => 'disabled',
				 )->pack(
					 -side   => 'left',
					 -fill   => 'y',
					 -anchor => 'n',
					);

  $self->{text} = $parent->ROText(
				  -borderwidth => 0,
				  -wrap        => 'none',
				  -background  => 'white',
				  -foreground  => 'black',
				 )->pack(
					 -side   => 'left',
					 -expand => 1,
					 -fill   => 'both',
					);

  for ($self->text()) {
    $_->tagConfigure('norm', @{$color{norm}});
    $_->tagConfigure('add',  @{$color{add}});
    $_->tagConfigure('del',  @{$color{del}});
    $_->tagConfigure('pad',  @{$color{pad}});
    $_->tagRaise('sel');
  }

  push @scrolledWidgets, $self->{line}, $self->{text};

  $self->line()->configure(-yscrollcommand => [\&scroll_panes, $scrollbar, $self->text(), \@scrolledWidgets]);
  $self->text()->configure(-yscrollcommand => [\&scroll_panes, $scrollbar, $self->text(), \@scrolledWidgets]);

  $scrollbar->configure(-command => sub { $_->yview(@_) foreach @scrolledWidgets });

  return $self;
}

# we dont call this as a class method, it is a straight function called by Tk as a callback
sub scroll_panes {
  my ($scrollbar, $callingWidget, $scrolledWidgets) = splice(@_, 0, 3);

  $scrollbar->set(@_);

  my ($top, $bottom) = $callingWidget->yview();

  $_->yviewMoveto($top) foreach @$scrolledWidgets;
}

sub line {
  my ($self) = @_;

  return $self->{line};
}

sub text {
  my ($self) = @_;

  return $self->{text};
}

1;
