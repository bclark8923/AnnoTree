USE annotree;


-- fake data for users
call create_user('{SSHA512}UX9sgqjO+B6T4x+ymVTOX+ZfBl5QI1DbJKwMuDijfgwwDQoTHHm/waUNdSI4VlqLOg/gn6GSCvcBdFWSRJTM7NtAC+c=', 'matt', 'price', 'matt@price.com', 'ENG', 'EST', 'img/user.png', 'f2k3', '2013-07-25 16:03:22', 'https/ccp.annotree.com/services/');
call create_user('password', 'mike', 'max', 'unrealdps@gmail.com', 'ENG', 'EST', 'img/user.png', 'f2k3', '2013-07-25 16:03:22', 'https/ccp.annotree.com/services/');

-- fake data for forests
call create_forest(1,"Silith.io", "A company for only the truly brave");
call create_forest(1,"The Monkey Knows", "How dare you try to rustle my jimmies");
call create_forest(1,"Late Night", "Because we will be pulling a bunch of these");
call create_forest(1,"NoDesc Co", "");
call create_forest(1, 'World of Trees', 'What is World of Trees? World of Trees is an online game where players from around the world assume the roles of heroic fantasy characters and explore a virtual world full of mystery, magic, and endless adventure. So much for the short answer! If you’re still looking for a better understanding of what World of Trees is, this page and the Beginner’s Guide are the right place to start.So, what is this game? Among other things,');

call create_tree(1, (select id from forest where name = 'World of Trees'), 'Tree Dwarves', 'The bold and courageous Tree Dwarves are an ancient race descended from the earthen—beings of living stone created by the titans when the world was young. Due to a strange malady known as the curse of flesh, the Tree Dwarves’ earthen progenitors underwent a transformation that turned their rocky hides into soft skin. Ultimately, these creatures of flesh and blood dubbed themselves Tree Dwarves and carved out the mighty city of Ironforge in the snowy peaks of Khaz Modan.', 'img/logo.png', 'f2k3', '2013-07-25 16:03:22');

call create_branch(1, (select distinct id from tree where name = 'Tree Dwarves' LIMIT 1), 'Tree Dwarve Racial Traits', 'A racial trait, commonly referred to as a racial, is a special ability or power granted to a character based on race. These traits come in both active and passive forms. Each race receives at least 3 traits (several passive and at least one active trait per race).');

call create_leaf('Stoneform', 1, (select id from branch where name = 'Tree Dwarve Racial Traits'));

call create_leaf_comment(1, 'Removes all rogue poisons as well as Rupture and Garrote. ', (select id from leaf where name = 'Stoneform'));

