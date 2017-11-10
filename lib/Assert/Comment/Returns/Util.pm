package Assert::Comment::Returns::Util;
use strict;
use warnings;
use utf8;
use List::Util qw/any/;
use Scalar::Util qw/blessed/;

use Exporter 'import';
our @EXPORT = qw/$_isa $_isa_any $_is/;

our $_isa = sub {
    my ($obj, $isa) = @_;
    return unless blessed($obj);
    return $obj->isa($isa);
};

our $_isa_any = sub {
    my ($obj, @isa) = @_;
    return unless blessed($obj);
    return any { $obj->isa($_) } @isa;
};

1;
