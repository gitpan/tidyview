package TidyView::Text;

use strict;
use warnings;

use IO::File;
use Log::Log4perl qw(get_logger);
use Data::Dumper;

sub new {
  my ($proto, %args) = @_;

  return unless (
		 exists  $args{parent} and
		 defined $args{parent});

  my ($parent, $file) = @args{qw(parent file)};

  my $class = ref $proto || $proto;

  (my $textwidget = $parent->Text(-state => 'disabled'))->pack(
							      -side   => 'left',
							      -expand => 1,
							      -fill   => 'both'
					  );

  my $self = bless({widget => $textwidget}, $class);

  if ($file) {
    $self->insertFile($file);
  }

  return $self;
}

sub insertFile {
  my ($self, $filename) = @_;

  my $logger = get_logger((caller(0))[3]);

  {
    my $fh = IO::File->new($filename, O_RDONLY)
      or die $!;

    my $lineCount = 0;
    # do we want to turn off $\ ?

    my @contents = $fh->getlines();

    $self->{unpaddedText} = join('', @contents);

    $self->insertText($self->{unpaddedText});

    $self->{lineCount} = @contents;
  }
}

sub insertText {
  my ($self, $text) = @_;

  $self->{widget}->configure(-state => 'normal');

  $self->{widget}->insert("end", $text);

  $self->{widget}->configure(-state => 'disabled');

  $self->{lineCount} += (my @lines = split(/$/m, $text));
}

sub replace {
  my ($self, $text) = @_;

  my $logger = get_logger((caller(0))[3]);

  $self->{widget}->configure(-state => 'normal');

  $self->{widget}->delete('1.0', 'end');

  $self->{widget}->insert('end', $text);

  $self->{widget}->configure(-state => 'disable');

  $self->{lineCount} = (my @lines = split(/$/m, $text));

  return;
}

# wrappers

sub yview {
  my ($self, @args) = @_;

  return $self->{widget}->yview(@args);
}

sub configure {
  my ($self, @args) = @_;

  return $self->{widget}->configure(@args);
}

sub yviewMoveto {
  my ($self, @args) = @_;

  return $self->{widget}->yviewMoveto(@args);
}

sub length {
  my ($self) = @_;

  return $self->{lineCount};
};

# manipulate the two text pane objects to make sure they both have the same number of lines.
# we do this because we lock the two text panes together with one scrollbar, and if they are
# different lengths then the scrollbar and pane management is really weird - the scrollbar
# ends up quivering as it asymptotes to the position of the two panes.

sub balanceText {
  my (undef, %args) = @_;

  my ($left, $right) = @args{qw(left right)};

  my ($shortPane, $longPane) = $left->length() < $right->length() ? ($left, $right) : ($right, $left);

  my $padLines = $longPane->length() - $shortPane->length();

  $shortPane->insertText("\n" x $padLines);

  $shortPane->{length} += $padLines;
}

1;
