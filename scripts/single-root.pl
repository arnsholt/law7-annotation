#!/usr/bin/env perl

use strict;
use warnings;
use v5.12;

use Lingua::CoNLLX;

my $corpus = Lingua::CoNLLX->new(file => $ARGV[0]);

for my $sentence (@{$corpus->sentences}) {
    my $root = $sentence->token(0);
    my @children = @{$root->children};

    my $new_head = $children[0];
    $new_head->deprel('FRAG') if $new_head->deprel eq 'ROOT';
    for my $child (@children[1..$#children]) {
        $root->_delete_child($child);
        $new_head->_add_child($child);
        $child->head($new_head);
        $child->deprel("FRAG");
    }

    say $sentence, "\n";
}
