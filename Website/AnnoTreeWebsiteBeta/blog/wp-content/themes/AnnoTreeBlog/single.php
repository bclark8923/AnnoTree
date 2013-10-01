<?php get_header(); ?>
  
  <div id="content" style="padding-top: 20px;min-height:100%;padding-bottom:30px;max-width:990px;" class="container">
    <div class="row">
      <div class="col-md-9">
        <?php if (have_posts()) : while (have_posts()) : the_post(); ?>
        <h2 style="color:#bbb;font-weight:100;font-size:40px;"><?php the_title(); ?></h2>
        <div style="float:left;">
          <a href="https://twitter.com/share" class="twitter-share-button" data-via="annotree">Tweet</a>
        </div>
        <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>
        <div id="fb-root"></div>
        <script src="http://connect.facebook.net/en_US/all.js#xfbml=1"></script>
        <fb:like style="float:left;" href="<?php echo get_permalink(); ?>" data-layout="button_count" show_faces="false" width="450"></fb:like>
        <br/>
        <p><?php the_content(); ?></p>
        <h5><?php the_time('F jS, Y') ?></h5>
        <h5><?php the_author_link(); ?></h5>
        <div style="float:left;">
          <a href="https://twitter.com/share" class="twitter-share-button" data-via="AnnoTree">Tweet</a>
        </div>        <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>
        <div id="fb-root"></div>
        <script src="http://connect.facebook.net/en_US/all.js#xfbml=1"></script>
        <fb:like style="float:left;" href="<?php echo get_permalink(); ?>" data-layout="button_count" show_faces="false" width="450"></fb:like>
        <br/>
        <hr>
        <?php comments_template( '', true ); ?>
        <?php endwhile; else: ?>
        <p><?php _e('Sorry, no posts matched your criteria.'); ?></p>
        <?php endif; ?> 
      </div>
      <div class="col-md-3">
        <?php get_sidebar(); ?>
      </div>
    </div> 
  </div>

<?php get_footer(); ?>

