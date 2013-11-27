<!doctype html>
<!-- paulirish.com/2008/conditional-stylesheets-vs-css-hacks-answer-neither/ -->
<!--[if lt IE 7]> <html class="no-js ie6 oldie" lang="en"> <![endif]-->
<!--[if IE 7]>    <html class="no-js ie7 oldie" lang="en"> <![endif]-->
<!--[if IE 8]>    <html class="no-js ie8 oldie" lang="en"> <![endif]-->
<!--[if IE 9]>    <html class="no-js ie9" lang="en"> <![endif]-->
<!-- Consider adding an manifest.appcache: h5bp.com/d/Offline -->
<!--[if gt IE 9]><!--> <html class="no-js" lang="en" itemscope> <!--<![endif]-->
<head>
  <meta charset="utf-8">

  <!-- Use the .htaccess and remove these lines to avoid edge case issues.
       More info: h5bp.com/b/378 -->
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">

  <title>AnnoTree | <?php echo get_the_title(); ?></title>

  <meta name="description" content="" />
  <meta name="keywords" content="" />
  <meta name="author" content="humans.txt">

  <link rel="shortcut icon" type="image/x-icon" href="http://annotree.com/favicon.ico" />
  <link rel="icon" type="image/png" href="http://annotree.com/favicon.png" />

  <!-- Facebook Metadata /-->
  <meta property="fb:page_id" content="118364948355465" />
  <meta property="og:title" content="<?php echo get_the_title(); ?> | AnnoTree" />
  <meta property="og:image" content="http://annotree.com/img/logo.png" />
  <meta property="og:description" content=""/>

  <!-- Google+ Metadata /-->
  <meta itemprop="name" content="<?php echo get_the_title(); ?> | AnnoTree">
  <meta itemprop="description" content="">
  <meta itemprop="image" content="http://annotree.com/img/logo.png">

  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1 user-scalable=no">
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">

  <!-- We highly recommend you use SASS and write your custom styles in sass/_custom.scss.
       However, there is a blank style.css in the css directory should you prefer -->
  <link href="http://fonts.googleapis.com/css?family=Lato:300" rel="stylesheet" type="text/css">

  <link rel="stylesheet" href="/wp-content/themes/AnnoTreeBlog/css/bootstrap.min.css">
  <link rel="stylesheet" href="/wp-content/themes/AnnoTreeBlog/css/bootstrap-theme.min.css">
  <link rel="stylesheet" href="<?php echo get_stylesheet_uri(); ?>">

  <script src="/wp-content/themes/AnnoTreeBlog/js/libs/modernizr-2.6.2.min.js"></script>
</head>

<body>
  <div class="navbar">
    <div class="container" style="height:99px;">
      <div class="navbar-header">
        <button class="navbar-toggle" type="button" data-toggle="collapse" data-target=".bs-navbar-collapse" style="margin-top:35px;">
          <span class="sr-only">Toggle navigation</span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
        </button>
        <a class="navbar-brand navbar-annotree" href="http://annotree.com"><img src="/wp-content/themes/AnnoTreeBlog/img/LogoNameWeb.png" /></a>
      </div>
      <div class="navbar-collapse bs-navbar-collapse collapse">
        <ul class="nav navbar-nav navbar-nav-annotree">
          <li><a href="http://annotree.com">Home</a></li>
          <li class="active"><a href="http://blog.annotree.com">Blog</a></li>
          <li class="signInButton">
            <a style="color:white;text-decoration:none;padding:0;" href="http://app.annotree.com">
              <button href="http://app.annotree.com" class="btn btn-annotree">Sign in</button>
            </a>
          </li>
        </ul>
      </div><!--/.navbar-collapse -->
    </div>
  </div>
