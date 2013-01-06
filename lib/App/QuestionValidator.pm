
package App::QuestionValidator;

use v5.12;
use strict;
use warnings;
use Carp;
use Text::CSV;
use Exporter 'import';


=head1 NAME

App::QuestionValidator - Validates learn-style multiplechoice questions.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

If you are looking for a commandline interface, you should look at
B<question-validator.pl>.

This module supplies the necessary functions for validating learn
style multiple choice questions.

    use App::QuestionValidator;

    my $fields = load_question('question.csv');
    if ( "Question OK" eq validate($fields) ) {
        say "Valid!";
    }
    ...

=head1 EXPORT

load_question validate

=cut

our @EXPORT = qw( load_question validate );
our @EXPORT_OK = qw( is_multiple_choice count_answers count_correct
  count_incorrect validate_answer_points );

=head1 SUBROUTINES/METHODS

=head2 load_question

Load csv formatted question into memory.

Takes filename as an argument and returns an array reference to the
rows.

=cut

sub load_question {
    my ($filename) = @_;

    my $csv = Text::CSV->new( { binary => 1, auto_diag => 1 } );
    open( my $fh, "<", $filename );
    my $fields = $csv->getline_all($fh);

    return $fields;
}

=head2 is_multiple_choice

This function checks to make sure the question is properly marked as
multiple choice.

=cut

sub is_multiple_choice {
    my ($fields) = @_;

    # First row second column indicates the question type.
    return $fields->[0][1] eq "MC";
}

=head2 count_row_pattern

This function uses a test on each row. A count of the number of rows
for which the test evaluates to true is returned. Takes a reference to
an array of rows.

Example:

    count_row_pattern { $_->[0] eq "Option" } $fields;

This would return the number of rows for which the first column
contains "Option".

=cut

sub count_row_pattern (&$) {
    my ( $CODE, $fields ) = @_;

    my $count;
    for $_ (@$fields) {
        if ( $CODE->() ) {
            $count++;
        }
    }
    return $count;
}

=head2 count_answers

This will count the number of options in the question.

=cut

sub count_answers {
    my ($fields) = @_;

    count_row_pattern { $_->[0] eq "Option" } $fields;
}

=head2 count_correct

This will count the number of options that are considered completely
correct (worth 100% of the points).

=cut

sub count_correct {
    my ($fields) = @_;

    count_row_pattern { $_->[0] eq "Option" && $_->[1] == 100 } $fields;
}

=head2 count_incorrect

This will count the number of options that are considered completely
incorrect.

=cut 
    
sub count_incorrect {
    my ($fields) = @_;

    count_row_pattern { $_->[0] eq "Option" && $_->[1] == 0 } $fields;
}

=head2 validate_answer_points

This will ensure that no more than 2 options have a value of greater
than 50% of the marks.

=cut

sub validate_answer_points {
    my ($fields) = @_;

    my $opt_with_points =
      count_row_pattern { $_->[0] eq "Option" && $_->[1] > 50 } $fields;

    return $opt_with_points <= 2;
}


=head2 validate

Validate the supplied question.

=cut

sub validate {
    my ($fields) = @_;

    my $status = "Question OK";

    unless ( is_multiple_choice($fields) ) {

        carp "Question marked as something "
          . "other than multiple choice, please remedy this.";
        $status = "Not OK";
    }

    unless ( count_answers($fields) == 4 ) {

        carp "There should be 4 answers to your multiple choice question.";
        $status = "Not OK";
    }

    unless ( count_correct($fields) == 1 ) {

        carp "There Should be one and only one fully correct answer.";
        $status = "Not OK";
    }

    unless ( count_incorrect($fields) >= 2 ) {

        carp "There should be between 2 and 3 incorrect answers.";
        $status = "Not OK";
    }
    unless ( validate_answer_points($fields) ) {

        carp "There should be no more than two options worth more than 50%";
        $status = "Not OK";
    }

    return $status;
    # This should basically be the main function.
}

=head1 AUTHOR

Jean-Christophe Petkovich, <jcpetkovich@gmail.com>

=head1 BUGS

Please report any bugs or feature requests to <jcpetkovich@gmail.com>, I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::QuestionValidator

=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Jean-Christophe Petkovich.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1;    # End of App::QuestionValidator
