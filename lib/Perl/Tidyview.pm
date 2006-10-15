package Perl::Tidyview;

use strict;
use warnings;

our $VERSION = sprintf("%d.%02d", q$Revision: 1.2 $ =~ /(\d+)\.(\d+)/);

1;

__END__

=head VERSION

Holds the product version identifier

1;

__END__

=head1 NAME

tidyview - a previewer for the effects of perltidy's plethora of options

=head1 SYNOPSIS

  tidyview
  tidyview [--log <log4perl config file>] [<perl code file>]

=head1 DESCRIPTION

tidyview is a Tk-based GUI that assists with selecting options for use with perltidy, a source code reformatter and indenter for Perl.

As good as perltidy is, it suffers a little from the huge number of options it supports - so whilst it is possible to find a set of options to layout the code exactly how you want, finding that set of options can be quite time consuming, requiring lots of back-to-back comparisons to find the effect your looking for. And thats where tidyview can help.

tidyview allows you to see the effect of perltidy options side-by-side with your original code. All of perltidy's options that affect code layout (rather than the operation of perltidy itself) are able to be selected, with Tk widgets that constrain them to valid values where possible.

Additionally, once your happy with the selected options, tidyview allows you to generate the selected options as a .perltidyrc configuration file, for further use.

=head1 OPTION CATEGORY

Within the tidyview application, the perltidy options are grouped into broad categories, in a drop-down list titled "Formatting Section". These formatting sections match the sections in the perltidy documention, being

=over

=item Basic Formatting Options

=item Code Indentation Control

=item Whitespace Control

=item Comment Controls

=item Linebreak Controls

=item Controlling list formatting

=item Retaining or ignoring existing line breaks

=item Blank line Control

=item Styles

=item Other Controls

=item HTML options

=item pod2html options

=back

Each of these sections presents a set of options to the user, generally 

=over

=item A set of checkbox style options

=item A set of integer-based options, either as a spinbox or a textbox, depending on your version of Tk

=item A set of text-based options - note, at the moment, no validation of what you enter is done, perltidy and not tidyview will complain.

=item A set of list-based options, as a scrolling listbox

=item A set of colour dialogues, for things like POD colour options

=back

Note that not all option sections will display all these sets, as not all section have options that need these sets - for example in the HTML options section, the only set displayed is the checkbox set, as perltidy does not support any other option sets.

=head1 TODO

perltidy is a very young application, so there are many ways it can be improved. Some of these include

=over

=item The ability to read an existing .perltidyrc

=item The ability to check that the parse tree has not been altered by the reformatting and indentation. This is planned to be support through PPI::Signature

=item Support for displaying the before and after formatting as a colourised diff

=item Support for generating CVS/Subversion/<insert favourite version management here> pre/post-commit hooks

=item Reorganise really long option lists so that things dont get pushed off the screen.

=item everyones favouriites - more doco and tests

=back

AUTHORS

Leif Eriksen <F<tidyview@sourceforge.net>>

=cut
