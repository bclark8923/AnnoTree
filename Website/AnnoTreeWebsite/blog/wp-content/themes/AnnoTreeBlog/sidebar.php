  <div id="sidebarcontent">
    <h4 style="color:#555;">Categories</h4>
     <ul style="list-style:none;padding-left:0;">
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
    <h4 style="color:#555;">Archives</h4>
     <ul style="list-style:none;padding-left:0;">
      <?php wp_get_archives('type=monthly'); ?>
     </ul>
  </div>
