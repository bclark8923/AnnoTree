USE annotree;


-- fake data for users
call create_user('password', 'mike', 'max', 'unrealdps@gmail.com', 'ENG', 'EST', null);
call create_user('{SSHA512}UX9sgqjO+B6T4x+ymVTOX+ZfBl5QI1DbJKwMuDijfgwwDQoTHHm/waUNdSI4VlqLOg/gn6GSCvcBdFWSRJTM7NtAC+c=', 'matt', 'price', 'matt@price.com', 'ENG', 'EST', null);

-- fake data for forests
call create_forest(1,"Silith.io", "A company for only the truly brave");
call create_forest(1,"The Monkey Knows", "How dare you try to rustle my jimmies");
call create_forest(1,"Late Night", "Because we will be pulling a bunch of these");
call create_forest(1,"NoDesc Co", "");
call create_forest(1, 'World of Trees', 'What is World of Trees? World of Trees is an online game where players from around the world assume the roles of heroic fantasy characters and explore a virtual world full of mystery, magic, and endless adventure. So much for the short answer! If you’re still looking for a better understanding of what World of Trees is, this page and the Beginner’s Guide are the right place to start.So, what is this game? Among other things,');


