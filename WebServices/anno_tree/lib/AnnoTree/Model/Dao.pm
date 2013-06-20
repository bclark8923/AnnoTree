package AnnoTree::Model::Dao;

use Mojo::Base -base;
use AnnoTree::Model::MySQL;
use Data::Dumper; 

# Paramaters: Class, Procedure name, Anonymous hash of Paramters
sub procedure {
    my ($class, $name, $params) = @_;

    #print "$name\n";
    #print Dumper($params) . "\n";
    my $json = {};
    my $result = AnnoTree::Model::MySQL->db->execute('call ' . $name, $params);
    print $result->[0]->[0] . "\n";
    print Dumper($result);
    #my $cols = $result->fetch; # get the columns (keys for json)
    #print Dumper
    #my $resultIndex = 0;
    #for(my $i = 0; $i < @{$cols}; $i++) {
    #    $json->{params}->[$i] = $cols->[$i];
    #}    
    #while (my $info = $result->fetch) {
        #my $userInfo = $result->fetch; # get the newly created user's info
        #    for(my $i = 0; $i < @{$cols}; $i++) {
        #$json->{results}->[$resultIndex]->{$cols->[$i]} = $info->[$i];
            #}
            #}
    #$json->{$cols} = $result->fetch->[0];

    return {test => 'hi there'}; #AnnoTree::Model::MySQL->procedure({test => 'hi there'});
}

return 1;
