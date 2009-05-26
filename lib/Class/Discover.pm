package Class::Discover;

use File::Find::Rule;
use File::Find::Rule::Perl;
use PPI;
use File::Temp;
use ExtUtils::MM_Unix;

sub discover_classes {
  my ($class, $opts) = @_;

  $opts ||= {};
  $opts->{keywords} ||= [qw/class role/];
  $opts->{require_use} ||= ['MooseX::Declare'];

  for (qw/keywords require_use/) {
    $opts->{$_} = [ $opts->{$_} ]
      if (ref $opts->{$_} ||'') ne 'ARRAY';
  }

  my @files;

  if ($opts->{files}) {
    @files = @{opts->{files}};
  } 
  elsif (my $dir = $opts->{dir}) {
    my $rule = File::Find::Rule->new;
    my $no_index = $opts->{no_index};
    @files = $rule->no_index({
        directory => [ map { "$dir/$_" } @{$no_index->{directory} || []} ],
        file => [ map { "$dir/$_" } @{$no_index->{file} || []} ],
    } )->perl_module
       ->in($dir);
  }

  for (@files) {
    my $file = $_;
    s/^\Q$dir\/\E//;
    $class->_search_for_classes_in_file($file, $_)
  }
}

sub _search_for_classes_in_file {
  my ($class, $file, $rel_file);

  my $doc = PPI::Document->new($file);

  for ($doc->children) {

    # Tokens can't have children
    next if $_->isa('PPI::Token');
    $self->_search_for_classes_in_node($_, "", $short_file)
  }
}

sub _search_for_classes_in_node {
  my ($self, $node, $class_prefix, $file) = @_;

  my $nodes = $node->find(sub {
      $_[1]->isa('PPI::Token::Word') && $_[1]->content eq 'class' || undef
  });
  return $self unless $nodes;

  for my $n (@$nodes) {
    $n= $n->next_token;
    # Skip over whitespace
    $n = $n->next_token while ($n && !$n->significant);

    next unless $n && $n->isa('PPI::Token::Word');

    my $class = $class_prefix . $n->content;

    # Now look for the '{'
    $n = $n->next_token while ($n && $n->content ne '{' );

    unless ($n) {
      warn "Unable to find '{' after 'class' somewhere in $file\n";
      return;
    }

    $self->provides( $class => { file => $file });

    # $n was the '{' token, its parent is the block/constructor for the 'hash'
    $n = $n->parent;
  
    for ($n->children) {

      # Tokens can't have children
      next if $_->isa('PPI::Token');
      $self->_search_for_classes_in_node($_, "${class}::", $file)
    }

    # I dont fancy duplicating the effort of parsing version numbers. So write
    # the stuff inside {} to a tmp file and use EUMM to get the version number
    # from it.
    my $fh = File::Temp->new;
    $fh->print($n->content);
    $fh->close;
    my $ver = ExtUtils::MM_Unix->parse_version($fh);

    $self->provides->{$class}{version} = $ver if defined $ver && $ver ne "undef";

    # Remove the block from the parent, so that we dont get confused by 
    # versions of sub-classes
    $n->parent->remove_child($n);
  }

  return $self;
}

1;

=head1 NAME

Class::Discover - detect MooseX::Declare's 'class' keyword in files.

=head1 SYNOPSIS

=head1 DESCRIPTION

This class is designed primarily for tools that whish to populate the
C<provides> field of META.{yml,json} files so that the CPAN indexer will pay
attention to the existance of your classes, rather than blithely ignoring them.

The version parsing is basically the same as what M::I's C<< ->version_form >>
does, so should hopefully work as well as it does.

=head1 SEE ALSO

L<MooseX::Declare> for the main reason for this module to exist.

L<Module::Install::ProvidesClass>

L<DistZilla>

=head1 AUTHOR

Ash Berlin C<< <ash@cpan.org> >>. (C) 2009. All rights reserved.

=head1 LICENSE 

Licensed under the same terms as Perl itself.

