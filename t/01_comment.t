use Test2::V0;

use Assert::Comment::Returns;
use PPI;

subtest 'get_assert_type_from_comment' => sub {
    my $doc = PPI::Document->new(\<<'...');
# returns: Str
sub foo {
}

# comment
# returns: Dict[
#   a => Str, # comment1
#   b => Int, # comment2
# ]
#
# comment
sub bar {
}

# invalid type declaration
# returns: ArrayRef[!@#$]
sub baz {
}

# returns: Str
# you need empty line after type declaration
sub qux {
}

# multiple type declaration
# returns: Str
#
# returns: Int
sub quux {
}
...

    my $subs = Assert::Comment::Returns->get_subroutines($doc);

    my $type_foo = Assert::Comment::Returns->get_assert_type_from_comment($subs->[0]);
    is $type_foo, object {
        prop blessed => 'Type::Tiny';
        call display_name => 'Str';
    };
    ok $type_foo->check('string');

    my $type_bar = Assert::Comment::Returns->get_assert_type_from_comment($subs->[1]);
    is $type_bar, object {
        prop blessed => 'Type::Tiny';
        call display_name => 'Dict[a => Str, b => Int]';
    };
    ok $type_bar->check({a => 'string', b => 1234});

    subtest 'invalid type declaration' => sub {
        like dies {
            Assert::Comment::Returns->get_assert_type_from_comment($subs->[2]);
        }, qr/^Invalid type declaration at baz:/;
    };

    subtest 'no empty line after type declaration' => sub {
        like dies {
            Assert::Comment::Returns->get_assert_type_from_comment($subs->[3]);
        }, qr/^Invalid type declaration at qux:/;
    };

    subtest 'multiple type declaration' => sub {
        my $type_quux = Assert::Comment::Returns->get_assert_type_from_comment($subs->[4]);
        is $type_quux, object {
            prop blessed => 'Type::Tiny';
            call display_name => 'Str';
        };
        ok $type_quux->check('string');
    };
};

subtest 'get_comments_at_top_of_cursor' => sub {
    my $doc = PPI::Document->new(\<<'...');
# COMMENT1
sub foo {
}

#
# COMMENT2
#

sub bar {
}

# COMMENT3.1

# COMMENT3.2
sub baz {
}
...

    my $subs = Assert::Comment::Returns->get_subroutines($doc);
    is +Assert::Comment::Returns->get_comments_at_top_of_cursor($subs->[0]), "# COMMENT1\n";
    is +Assert::Comment::Returns->get_comments_at_top_of_cursor($subs->[1]), "#\n# COMMENT2\n#\n";
    is +Assert::Comment::Returns->get_comments_at_top_of_cursor($subs->[2]), "# COMMENT3.1\n\n# COMMENT3.2\n";
};

done_testing;
