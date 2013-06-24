<?php get_header(); ?>
  
  <div id="content" style="padding-top: 100px;min-height:100%;padding-bottom:30px;">
    <div class="row">
      <div class="nine columns">
        <?php if (have_posts()) : while (have_posts()) : the_post(); ?>
        <h2 style="background-color: #ccc;border-radius: 10px;"><a style="color:white;padding-left:20px;" href="<?php echo get_permalink($post->ID) ?>"><?php the_title(); ?></a></h2>
        <p><?php the_excerpt(__('(more...)')); ?></p>
        <h5>Posted: <?php the_time('F jS, Y') ?></h5>
        <h5>By: <?php the_author_link(); ?></h5>
        <hr>
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

