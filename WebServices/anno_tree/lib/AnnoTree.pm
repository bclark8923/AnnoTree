package AnnoTree;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('example#welcome');
    
    # ===== FORESTS =====
    $r->get('/forest')->to('forest#list');
    $r->get('/forest/:id' => [id => qr/\d+/])->to('forest#unique');

    # ===== TREES =====
    $r->get('/:forestid/tree/' => [forestid => qr/\d+/])->to('tree#list');

}

1;
