  <div id="sidebarcontent">
    <h4>Categories</h4>
     <ul>
      <?php
		$args = array(
		  'orderby' => 'name',
		  'parent' => 0
		  );
		$categories = get_categories( $args );
		foreach ( $categories as $category ) {
			echo '<a href="' . get_category_link( $category->term_id ) . '">' . $category->name . '</a><br/>';
		}
		?>
     </ul>
    <h4>Archives</h4>
     <ul>
      <?php wp_get_archives('type=monthly'); ?>
     </ul>
  </div>
