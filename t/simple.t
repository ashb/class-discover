use strict;
use warnings;

use FindBin qw/$Bin/;
use Test::More tests => 2;
use Test::Differences;

use_ok('Class::Discover');

$DB::single = 1;
my $classes = Class::Discover->discover_classes({
  dir => "$Bin/data/dir1/",
  files => "$Bin/data/dir1/lib/Class1.pm" 
});

eq_or_diff(
  $classes,
  [ { MyClass => { file => "lib/Class1.pm", type => "class", version => "0.03_a" } } ],
  "Provided files"
);

$classes = Class::Discover->discover_classes({
  dir => "$Bin/data/dir1",
});

eq_or_diff(
  $classes,
  [ 
    { MyClass => { file => "lib/Class1.pm", type => "class", version => "0.03_a" } },
    { MyClass2 => { file => "lib/Class2.pm", type => "class" } },
  ],
  "Found files"
);


$classes = Class::Discover->discover_classes({
  dir => "$Bin/data/dir1",
  no_index => {
    file => ["lib/Class1.pm"]
  }
});

eq_or_diff(
  $classes,
  [ 
    { MyClass2 => { file => "lib/Class2.pm", type => "class" } },
  ],
  "Found files, no_index"
);


$classes = Class::Discover->discover_classes({
  dir => "$Bin/data/dir2",
  no_index => {
    file => ["lib/Class1.pm"]
  }
});

eq_or_diff(
  $classes,
  [ 
    { MyClass2 => { file => "lib/Class2.pm", type => "class" } },
  ],
  "Found files, no_index"
);
