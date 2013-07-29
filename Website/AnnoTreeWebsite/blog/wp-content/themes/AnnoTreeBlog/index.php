<?php get_header(); ?>
  
  <div id="content" style="padding-top: 100px;min-height:100%;padding-bottom:30px;">
    <div class="row">
      <div class="nine columns">
        <?php if (have_posts()) : while (have_posts()) : the_post(); ?>
        <h4 style="padding-bottom:0;font-weight:100;"><a href="<?php echo get_permalink($post->ID) ?>"><?php the_title(); ?></a></h4>
        <h6><?php the_time('F jS, Y') ?></h6>
        <p><?php the_excerpt('Read More...'); ?></p>
        <p class="success badge">
          <?php comments_number( '0 Comments', '1 Comment', '% Comments' ); ?>
        </p>
        <br/>

        <div style="float:left;">
          <a href="https://twitter.com/share" class="twitter-share-button" data-via="AnnoTree" data-url="<?php echo get_permalink( $id ); ?>" data-text="<?php echo the_title( $id ); ?>">Tweet</a>
        </div>   
        <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>
        
        <div id="fb-root"></div>
        <script src="http://connect.facebook.net/en_US/all.js#xfbml=1"></script>
        <fb:like style="float:left;" href="<?php echo get_permalink(); ?>" show_faces="true" width="450"></fb:like><hr style="border-bottom:none; margin-top:60px;margin-bottom:60px;">
        <br/>
        <?php endwhile; else: ?>
        <p><?php _e('Sorry, no posts matched your criteria.'); ?></p>
        <?php endif; ?> 
      </div>
      <div class="three columns">
        <?php get_sidebar(); ?>
      </div>
    </div> 
  </div>

<?php get_footer(); ?>

