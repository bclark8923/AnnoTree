USE annotree;


--fake data for users
select create_user('password', 'mike', 'max', 'unrealdps@gmail.com', 'ENG', 'EST', null);
select create_user('{SSHA512}lYeG5lCnnF/b2Ao/qWWLkQZZzZwMSg8Ks0m2vUZl5I+T0EmEzjyhwCudoEZxw4vuJWhg5rLTVr8kWGX3pef46Z4tR4o=', 'matt', 'price', 'matt@price.com', 'ENG', 'EST', null);

-- fake data for forests
select create_forest(1,"Silith.io", "A company for only the truly brave");
select create_forest(1,"The Monkey Knows", "How dare you try to rustle my jimmies");
select create_forest(1,"Late Night", "Because we will be pulling a bunch of these");
select create_forest(1,"NoDesc Co", "");
select create_forest(1, 'World of Trees', 'What is World of Trees? World of Trees is an online game where players from around the world assume the roles of heroic fantasy characters and explore a virtual world full of mystery, magic, and endless adventure. So much for the short answer! If you’re still looking for a better understanding of what World of Trees is, this page and the Beginner’s Guide are the right place to start.So, what is this game? Among other things,');


