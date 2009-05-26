use warnings;
use inc::Module::Install 0.87;

requires 'File::Find::Rule';
requires 'File::Find::Rule::Perl';
requires 'PPI';
requires 'File::Temp';
requires 'ExtUtils::MM_Unix';


write_all;
