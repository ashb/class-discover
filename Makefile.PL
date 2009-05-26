use warnings;
use inc::Module::Install 0.87;

requires 'File::Find::Rule';
requires 'File::Find::Rule::Perl';
requires 'PPI';
requires 'File::Temp';
requires 'ExtUtils::MM_Unix';
requires 'Path::Class';

test_requires 'Test::More';
test_requires 'Test::Differences';

write_all;
