package TidyView::Display;

use strict;
use warnings;

use Log::Log4perl qw(get_logger);

use Data::Dumper;

INIT {
  eval "require Algorithm::Diff";

  if ($@) {
    *_display = \&show_plain_text;
  } else {
    *_display = \&show_diff_text;
  }

  eval "require Perl::Signature";

  if ($@) {
    *_warnSemanticDelta = undef;
  } else {
    *_warnSemanticDelta = \&warnSemanticRuination;
  }

}

sub preview_tidy_changes {
  my ($self, %args) = @_;

  my ($fileToTidy, $originalTextWidget, $tidyTextWidget, $rootWindow) = @args{qw(fileToTidy
										 originalTextWidget
										 tidyTextWidget
										 rootWindow
										)};
  my %widgetType = (
		    line0 => $originalTextWidget->line(),
		    text0 => $originalTextWidget->text(),
		    line1 => $tidyTextWidget->line(),
		    text1 => $tidyTextWidget->text(),
		   );

  $rootWindow->Busy(-recurse => 1);

  $widgetType{$_}->configure(-state => 'normal') foreach qw(line0 line1);

  $widgetType{$_}->delete('0.0', 'end')          foreach qw(line0 line1);

  $widgetType{$_}->delete('0.0', 'end')          foreach qw(text0 text1);

  my $originalText = $self->load_file($fileToTidy);
  my $tidiedText   = [PerlTidy::Run->execute(file => $fileToTidy)];

  $self->_display(
		  originalText => $originalText,
		  tidiedText   => $tidiedText,
		  widgets      => \%widgetType
		 );

  $widgetType{$_}->configure(-state => 'disabled') foreach qw(line0 line1);

  $rootWindow->Unbusy();

  if (defined *_warnSemanticDelta{CODE}) {
    if (Perl::Signature->source_signature(join('', @$originalText)) ne
	Perl::Signature->source_signature(join('', @$tidiedText  ))) {
      $self->_warnSemanticDelta(widget => $rootWindow);
    }
  }
}

sub show_plain_text {
  my ($self, %args) = @_;

  my ($left, $right, $widgets) = @args{qw(originalText tidiedText widgets)};

  my @ln = (1, 1);
  my $z  = @$right - @$left;

  foreach my $l (@$left) {
    $widgets->{line0}->insert('end', sprintf("%5i\n", $ln[0]++));
    $widgets->{text0}->insert('end', $l);
  }

  if ($z > 0) {
    for (1 .. $z) {
      $widgets->{line0}->insert('end', "\n");
      $widgets->{text0}->insert('end', "\n");
    }
  }

  foreach my $l (@$right) {
    $widgets->{line1}->insert('end', sprintf("%5i\n", $ln[1]++));
    $widgets->{text1}->insert('end', $l);
  }

  if ($z < 0) {
    for (1 .. -$z) {
      $widgets->{line1}->insert('end', "\n");
      $widgets->{text1}->insert('end', "\n");
    }
  }
}

sub show_diff_text {
  my ($self, %args) = @_;

  my ($left, $right, $widgets) = @args{qw(originalText tidiedText widgets)};

  my @diff = Algorithm::Diff::sdiff($left, $right);

  my @tag = (
	     {'u' => 'norm', 'c' => 'del', '-' => 'del', '+' => 'del'},
	     {'u' => 'norm', 'c' => 'add', '-' => 'add', '+' => 'add'},
	    );

  my @ln = (1,  1);

  foreach my $d (@diff) {

    if ($d->[0] eq 'c') {
      # Provide detail on changes within the line.

      # Remove any trailing newline so that it won't cause the tag to
      # highlight to EOL.
      my @nl = (chomp $d->[1], chomp $d->[2]);
      my $dx = [split(qr/(\s+|\b)/, $d->[1])]; # word diff
      my $dy = [split(qr/(\s+|\b)/, $d->[2])]; # word diff
      my @dd = Algorithm::Diff::sdiff($dx, $dy);

      foreach my $d (@dd) {
	$widgets->{text0}->insert('end', $d->[1], $tag[0]{$d->[0]});
	$widgets->{text1}->insert('end', $d->[2], $tag[1]{$d->[0]});
      }

      # Replace any newlines removed so that we know whether or
      # not to pad the line. Also write a newline to the text area.
      for my $i (0 .. 1) {
	next unless $nl[$i];
	$d->[$i+1] .= "\n";
	$widgets->{"text$i"}->insert('end', "\n");
      }

    } else {
      # Either the whole line matches, or it doesn't match at all (add/del)
      $widgets->{text0}->insert('end', $d->[1], $tag[0]{$d->[0]});
      $widgets->{text1}->insert('end', $d->[2], $tag[1]{$d->[0]});
    }

    for my $n (0 .. 1) {
      if ($d->[$n+1] =~ /\n/) {
				# Add line number from source file to gutter
	$widgets->{"line$n"}->insert('end', sprintf("%5i\n", $ln[$n]++));
      } else {
				# Pad text display to align matches
				# Leave line number empty
	$widgets->{"text$n"}->insert('end', "\n", 'pad');
	$widgets->{"line$n"}->insert('end', "\n");
      }
    }
  }
}

sub load_file {
  my ($self, $file) = @_;

  open(my $fh, '<', $file) or do {
    warn "Can't read '$file' [$!]\n";
    return;
  };

  my @data = <$fh>;
  close($fh);

  return \@data;
}

sub warnSemanticRuination {
  my ($self, %args) = @_;

  my ($widget) = @args{qw(widget)};

  $widget->messageBox(
		      -title   => 'Problem tidying File',
		      -icon    => 'warning',
		      -type    => 'Ok',
		      -message => "Semantic change detected on tidied version\nDo not use these options",
		     );
}

1;
