package Assert::Comment::Returns::Type;
use strict;
use warnings;
use utf8;
use Type::Registry;

use Exporter 'import';
our @EXPORT_OK = qw/type/;

my $reg = Type::Registry->for_class(__PACKAGE__);

sub type {
    my ($type_name) = @_;
    if (my $type = $reg->simple_lookup($type_name)) {
        return $type;
    } else {
        my $type = Type::Utils::dwim_type(
            $type_name,
            fallback => ['lookup_via_mouse', 'make_class_type'],
        );
        $type->{display_name} = $type_name;
        $reg->add_type($type, $type_name);
        return $type;
    }
}

1;
