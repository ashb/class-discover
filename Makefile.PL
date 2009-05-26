use warnings;
use inc::Module::Install 0.89;

all_from 'lib/Class/Discover.pm';

requires 'File::Find::Rule';
requires 'File::Find::Rule::Perl';
requires 'PPI';
requires 'File::Temp';
requires 'ExtUtils::MM_Unix';
requires 'Path::Class';

test_requires 'Test::More';
test_requires 'Test::Differences';

jsonmeta();
write_all;

WriteMakefile(
  dist => {
    PREOP => 'pod2text lib/Class/DISCOVER.pm > README'
  },
);
