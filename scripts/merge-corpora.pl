#!/usr/bin/env perl

use strict;
use warnings;
use v5.12;

use List::Util qw/shuffle/;
use List::MoreUtils qw/all each_array/;

die "Usage: $0 file1 file2 file3 file4" if scalar @ARGV != 4;

my %fh = map {open my $fh, '<', $_; $_ => $fh} @ARGV;
my %corpora = map {$_ => read_corpus($fh{$_})} @ARGV;

# Consistency checking. All four same no. of sentences, all sentences same
# length.
my @lengths = map {scalar @{$corpora{$_}}} @ARGV;
die "Corpora have different lengths\n" if not equal_lengths(@lengths);

my $len = scalar @{$corpora{$ARGV[0]}};
for my $i (0..$len-1) {
    my @lengths = map {scalar @{$corpora{$_}[$i]}} @ARGV;
    die "Unequal sentence lengths\n" if not equal_lengths(@lengths);
}

# Create permutation of selections.
my $chunks = int($len/10);
$chunks++ if $len % 10;
my $div = int(($chunks-5) / 3);
my $mod = ($chunks-5) % 3;
my @index = ((3) x 5, (0, 1, 2) x $div);
@index = (@index, 0..$mod-1) if $mod;
@index = shuffle @index;

#my $div = int(($len-5)/3);
#my $mod = ($len-5)%3;
#my @index = ((3) x 5, (0, 1, 2) x $div);
#@index = (@index, 0..$mod-1) if $mod;
#@index = shuffle @index;

for my $i (0..$len-1) {
    my $idx = int($i / 10);
    my $k = $ARGV[$index[$idx]];
    say "# $k";
    say join("\n", @{$corpora{$k}[$i]}), "\n";
}

sub read_corpus {
    my ($fh) = @_;

    my @sentences;
    my $lines = [];
    while(my $line = <$fh>) {
        chomp $line;

        if(@$lines > 0 and not $line) {
            push @sentences, $lines;
            $lines = [];
            next;
        }

        push @$lines, $line;
    }

    if(@$lines > 0) {
        say "# ping ", scalar @$lines;
        push @sentences, $lines;
        $lines = [];
    }

    return \@sentences;
}

sub equal_lengths {
    my ($a, $b, $c, $d) = @_;

    return $a == $b
       and $a == $c
       and $a == $d;
}
