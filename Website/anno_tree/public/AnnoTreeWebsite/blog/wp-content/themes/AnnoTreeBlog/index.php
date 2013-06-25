<?php get_header(); ?>
  
  <div id="content" style="padding-top: 100px;min-height:100%;padding-bottom:30px;">
    <div class="row">
      <div class="nine columns">
        <?php if (have_posts()) : while (have_posts()) : the_post(); ?>
        <h2 style="padding-bottom:0;font-weight:100;"><a href="<?php echo get_permalink($post->ID) ?>"><?php the_title(); ?></a></h2>
        <h5><?php the_time('F jS, Y') ?></h5>
        <p><?php the_excerpt(__('(more...)')); ?></p>
        <hr style="border-bottom:none; margin-top:60px;margin-bottom:60px;">
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

