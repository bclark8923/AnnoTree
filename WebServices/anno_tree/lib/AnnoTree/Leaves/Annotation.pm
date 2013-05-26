package AnnoTree::Leaves::Annotation;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;

my $imgDir = '/home/matt/Documents/AnnoTree/WebServices/anno_tree/public/img';

sub list {
    my $self = shift;

    $self->render(text => 'testing');
}

sub testScreenshotUpload {
    my $self = shift;
    
    $self->render(template => 'leaves/annotation/testupload');
}

sub annotationCreation {
    my $self = shift;

    #$self->app->log->debug(Dumper($self->ua));
    #my $image = $self->param('image');
    
    my $forestid = $self->param('forestid');
    my $treeid = $self->param('treeid');
    my $branchid = $self->param('branchid');
    my $leafid = $self->param('leafid');
    
    my $annotationDir = "$imgDir/screenshot/$forestid/$treeid/$branchid/$leafid";
    #$self->app->log->debug(Dumper($self->req->upload));
    #$self->app->log->debug(Dumper($self->req));
    $self->app->log->debug("annotationdir: $annotationDir");

    # get the file names in the annotation dir that file will be uploaded to - need this to get the highest prefix
    opendir(my $dir, $annotationDir) or $self->app->log->debug('could not open');
    my @files = reverse sort readdir($dir);
    $self->app->log->debug(Dumper(@files));

    my $annotationid = @files ? substr($files[0], 0, 1) + 1 : "0";   
    my $upload = $self->req->upload('screenshot');

    # need to figure out this name piece or just create a web service for each annotation type (not ideal)
    $self->req->{'name'} eq 'screenshot' ? $self->app->log->debug('screenshot found') : $self->app->log->debug('not a screenshot');
    $self->app->log->debug(Dumper($upload));

    $upload->move_to("$annotationDir/$annotationid" . "_" . "$upload->{filename}");

    $self->render(text => "Thanks for uploading $upload->{filename}");
}

sub annotationDisplay {
    my $self = shift;

    $self->render(template => 'leaves/annotation/display', imgDir => $imgDir);
}

return 1;
