<?php get_header(); ?>
  
  <div id="content" style="padding-top: 100px;min-height:100%;padding-bottom:30px;">
    <div class="row">
      <div class="nine columns">
        <?php if (have_posts()) : while (have_posts()) : the_post(); ?>
        <h2 style="color:#bbb;font-weight:100;"><?php the_title(); ?></h2>
        <p><?php the_content(); ?></p>
        <h5><?php the_time('F jS, Y') ?></h5>
        <h5><?php the_author_link(); ?></h5>
        <hr>
        <?php comments_template( '', true ); ?>
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

