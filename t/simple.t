use strict;
use warnings;

use FindBin qw/$Bin/;
use Test::More tests => 5;
use Test::Differences;

use_ok('Class::Discover');

# RT #48571 : Random Test Failures due to unexpected array order
# See Also :  RT #48593 : Document Result-Order being arbitrary and not-predictable

sub class_sort {
    my ( $x, $y ) = @_;
    my @m = keys %{ $x };
    my @n = keys %{ $y };
    return $m[0] cmp $n[0];
}

sub c_sort($){
    [ sort { class_sort($a,$b) } @{ $_[0] } ]
}

# /RT

my $classes = c_sort Class::Discover->discover_classes({
  dir => "$Bin/data/dir1/",
  files => "$Bin/data/dir1/lib/Class1.pm"
});

eq_or_diff(
  $classes,
  c_sort [ { MyClass => { file => "lib/Class1.pm", type => "class", version => "0.03_a" } } ],
  "Provided files"
);

$classes = c_sort Class::Discover->discover_classes({ dir => "$Bin/data/dir1" });

eq_or_diff(
  $classes,
  c_sort [
    { MyClass => { file => "lib/Class1.pm", type => "class", version => "0.03_a" } },
    { MyClass2 => { file => "lib/Class2.pm", type => "class" } },
  ],
  "Found files"
);


$classes = c_sort Class::Discover->discover_classes({
  dir => "$Bin/data/dir1",
  no_index => {
    file => ["lib/Class1.pm"]
  }
});

eq_or_diff(
  $classes,
  c_sort [
    { MyClass2 => { file => "lib/Class2.pm", type => "class" } },
  ],
  "Found files, no_index"
);


$classes = c_sort Class::Discover->discover_classes({ dir => "$Bin/data/dir2" });

eq_or_diff(
  $classes,
  c_sort [
    { Outer => { file => "lib/Nested.pm", type => "class" } },
    { 'Global::Versioned' => { file => "lib/Nested.pm", type => "class", version => "1" } },
    { 'Outer::Inner::Versioned' => { file => "lib/Nested.pm", type => "class", version => "1" } },
    { 'Outer::Inner::Unversioned' => { file => "lib/Nested.pm", type => "class" } },
    { Global => { file => "lib/Nested.pm", type => "class" } },
    { MyRole => { file => "lib/Nested.pm", type => "role" } },
  ],
  "Found files, no_index"
);

