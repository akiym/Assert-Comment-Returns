package Assert::Comment::Returns;
use strict;
use warnings;
use utf8;

use Assert::Comment::Returns::Util;
use Smart::Args::TypeTiny;

use Assert::Comment::Returns::Type qw/type/;

our $VERSION = "0.01";

# returns: Arrayref[PPI::Statement::Sub]
sub get_subroutines {
    args_pos my $class,
             my $doc => 'PPI::Document',
             ;

    return $doc->find(sub { $_[1]->isa('PPI::Statement::Sub') && $_[1]->name });
}

# returns: Type::Tiny
sub get_assert_type_from_comment {
    args_pos my $class,
             my $stmt => 'PPI::Statement::Sub',
             ;

    my $comments = $class->get_comments_at_top_of_cursor($stmt);
    my ($type_name) = $comments =~ /#\s*returns:\s*(.+?)(?:$|\n#\n|\n\n)/s;
    $type_name =~ s/^#\s*//mg;
    $type_name =~ s/#.+$//mg;   # remove comments in type declaration
    $type_name =~ s/\n//g;
    $type_name =~ s/,\s*\]/]/g; # remove trailing comma

    my $type = eval { type($type_name) };
    if ($@) {
        my $sub_name = $stmt->name;
        die "Invalid type declaration at $sub_name: $@";
    }
    return $type;
}

# returns: Str
sub get_comments_at_top_of_cursor {
    args_pos my $class,
             my $stmt => 'PPI::Statement::Sub',
             ;

    my @comments;
    my $cursor = $stmt->first_token->previous_token;
    while ($cursor->$_isa_any(qw/PPI::Token::Comment PPI::Token::Whitespace/)) {
        unshift @comments, $cursor;
        $cursor = $cursor->previous_token;
    }

    # remove whitespace beginning of line
    while (@comments) {
        if ($comments[0]->$_isa('PPI::Token::Whitespace')) {
            shift @comments;
        } else {
            last;
        }
    }
    # remove whitespace end of line
    while (@comments) {
        if ($comments[-1]->$_isa('PPI::Token::Whitespace')) {
            pop @comments;
        } else {
            last;
        }
    }

    return join '', @comments;
}

1;
__END__

=encoding utf-8

=head1 NAME

Assert::Comment::Returns - It's new $module

=head1 SYNOPSIS

    use Assert::Comment::Returns;

=head1 DESCRIPTION

Assert::Comment::Returns is ...

=head1 LICENSE

Copyright (C) Takumi Akiyama.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Takumi Akiyama E<lt>t.akiym@gmail.comE<gt>

=cut

