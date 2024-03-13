
// Q1: How do the recommendations obtained in Part 1 and Part 2 differ?
// Part 1 recommendations
// Either Drama or Comedy
╒═══════════════════════════╤═════╤═════════════════════════════╕
│Recommendation             │Score│Genres                       │
╞═══════════════════════════╪═════╪═════════════════════════════╡
│"Band of Brothers"         │9.6  │["Action", "Drama", "War"]   │
├───────────────────────────┼─────┼─────────────────────────────┤
│"Shawshank Redemption, The"│9.3  │["Drama", "Crime"]           │
├───────────────────────────┼─────┼─────────────────────────────┤
│"Decalogue, The (Dekalog)" │9.2  │["Drama", "Crime", "Romance"]│
├───────────────────────────┼─────┼─────────────────────────────┤
│"Godfather, The"           │9.2  │["Drama", "Crime"]           │
├───────────────────────────┼─────┼─────────────────────────────┤
│"Pride and Prejudice"      │9.1  │["Drama", "Romance"]         │
└───────────────────────────┴─────┴─────────────────────────────┘
// Both Drama AND Comedy
╒═══════════════════════════════════════════╤═════╤════════════════════════════════════════╕
│Recommendation                             │Score│Genres                                  │
╞═══════════════════════════════════════════╪═════╪════════════════════════════════════════╡
│"Pulp Fiction"                             │8.9  │["Drama", "Comedy", "Crime", "Thriller"]│
├───────────────────────────────────────────┼─────┼────────────────────────────────────────┤
│"Forrest Gump"                             │8.8  │["Drama", "War", "Comedy", "Romance"]   │
├───────────────────────────────────────────┼─────┼────────────────────────────────────────┤
│"Dr. Horrible's Sing-Along Blog"           │8.7  │["Sci-Fi", "Drama", "Comedy", "Musical"]│
├───────────────────────────────────────────┼─────┼────────────────────────────────────────┤
│"Gentlemen of Fortune (Dzhentlmeny udachi)"│8.6  │["Drama", "Comedy", "Crime", "Mystery"] │
├───────────────────────────────────────────┼─────┼────────────────────────────────────────┤
│"Intouchables"                             │8.6  │["Drama", "Comedy"]                     │
└───────────────────────────────────────────┴─────┴────────────────────────────────────────┘   

// Part 2 Recommendations
// Either War or Film-Noir
╒═════════╤══════════════════════╤══════════════════════════╤══════════╕
│m.movieId│m.title               │genres                    │IMDB_Score│
╞═════════╪══════════════════════╪══════════════════════════╪══════════╡
│7502     │"Band of Brothers"    │["Action", "Drama", "War"]│9.6       │
├─────────┼──────────────────────┼──────────────────────────┼──────────┤
│93040    │"Civil War, The"      │["War", "Documentary"]    │9.5       │
├─────────┼──────────────────────┼──────────────────────────┼──────────┤
│27611    │"Battlestar Galactica"│["Sci-Fi", "Drama", "War"]│8.7       │
├─────────┼──────────────────────┼──────────────────────────┼──────────┤
│108709   │"Generation Kill"     │["Drama", "War"]          │8.7       │
├─────────┼──────────────────────┼──────────────────────────┼──────────┤
│2028     │"Saving Private Ryan" │["Action", "Drama", "War"]│8.6       │
└─────────┴──────────────────────┴──────────────────────────┴──────────┘

// Q2: Discuss possible reasons for these differences.
// Interestingly there is one case of overlap between the two methods and that is the recommendation
// that Darlene watch Band of Brothers based on her preference for genres she's watched and her preference
// based on ratings given to genres. That being said, that seems to be the only overlap in a top 5 scenario.
// I think a big reason for the differences in the two parts is Darlene may watch many Drama and Comedy movies,
// but she tends to consistently rate movies in the War genre specifically higher than movies in the Drama genre.
// We can even demonstrate that with the following query:
MATCH (p:User{name: 'Darlene Garcia'})-[r:RATED]->(:Movie)-[:IN_GENRE]->(g:Genre)
WHERE g.name IN ['Drama', 'Comedy', 'War', 'Film-Noir']
RETURN g.name As Genre, round(avg(r.rating), 2) AS Rating
ORDER BY Rating DESC;

╒═══════════╤══════╕
│Genre      │Rating│
╞═══════════╪══════╡
│"War"      │3.9   │
├───────────┼──────┤
│"Film-Noir"│3.74  │
├───────────┼──────┤
│"Drama"    │3.45  │
├───────────┼──────┤
│"Comedy"   │3.13  │
└───────────┴──────┘

// We can make a guess that War films generally resonate more with Darlene than say, a Comedy. Whether this is due to
// consistencies or other qualifiers in the genres themselves, I can't say for certain.\

// Q3: What approach would work better in the real-life scenario? Why?
// In the real-life scenario, for this case specifically, I think accounting for ratings gives us a more accurate reflection
// of recommendations we can make to Darlene based on her preferences. Ideally, we would be able to loop Film-Noir into the 
// list of recommendations as well but there is no overlap between War and Film-Noir (at least that Darlene has not seen). While
// ratings are a very subjective metric, it is easier to determine how a user might "feel" about movies they watch instead of solely
// relying on the number of movies in a particular genre they have consumed. I feel like using the ratings method also avoids some of the
// bias that might be at play due to the prevalence of Drama films. It is, however, not a perfect method.

// Q4: Come up with a better way to create recommendations by combining both methods.
// Approach where we first filter based on highest rated genres, and then look specifically for
// Drama or Comedy films in that list
MATCH (p:User {name:'Darlene Garcia'}), (m:Movie)-[:IN_GENRE]->(g:Genre)
WHERE NOT (p)-[:RATED]->(m)
WITH collect(g.name) AS genres, m
WHERE ANY(item IN genres WHERE item IN ['War', 'Film-Noir'])
WITH genres, m
WHERE ANY(item IN genres WHERE item IN ['Drama', 'Comedy'])
RETURN m.movieId, m.title, genres, m.imdbRating AS IMDB_Score
LIMIT 10;
╒═════════╤═════════════════════════════════════════════════╤═════════════════════════════════════════╤══════════╕
│m.movieId│m.title                                          │genres                                   │IMDB_Score│
╞═════════╪═════════════════════════════════════════════════╪═════════════════════════════════════════╪══════════╡
│61026    │"Red Cliff (Chi bi)"                             │["Adventure", "Action", "Drama", "War"]  │7.4       │
├─────────┼─────────────────────────────────────────────────┼─────────────────────────────────────────┼──────────┤
│63853    │"Australia"                                      │["Adventure", "Drama", "War", "Western"] │6.6       │
├─────────┼─────────────────────────────────────────────────┼─────────────────────────────────────────┼──────────┤
│4339     │"Von Ryan's Express"                             │["Adventure", "Action", "Drama", "War"]  │7.2       │
├─────────┼─────────────────────────────────────────────────┼─────────────────────────────────────────┼──────────┤
│897      │"For Whom the Bell Tolls"                        │["Adventure", "Drama", "War", "Romance"] │7.0       │
├─────────┼─────────────────────────────────────────────────┼─────────────────────────────────────────┼──────────┤
│4103     │"Empire of the Sun"                              │["Adventure", "Action", "Drama", "War"]  │7.8       │
├─────────┼─────────────────────────────────────────────────┼─────────────────────────────────────────┼──────────┤
│27816    │"Saints and Soldiers"                            │["Adventure", "Action", "Drama", "War"]  │6.8       │
├─────────┼─────────────────────────────────────────────────┼─────────────────────────────────────────┼──────────┤
│6947     │"Master and Commander: The Far Side of the World"│["Adventure", "Drama", "War"]            │7.4       │
├─────────┼─────────────────────────────────────────────────┼─────────────────────────────────────────┼──────────┤
│42681    │"49th Parallel"                                  │["Adventure", "Drama", "War", "Thriller"]│7.5       │
├─────────┼─────────────────────────────────────────────────┼─────────────────────────────────────────┼──────────┤
│8640     │"King Arthur"                                    │["Adventure", "Action", "Drama", "War"]  │6.3       │
├─────────┼─────────────────────────────────────────────────┼─────────────────────────────────────────┼──────────┤
│7458     │"Troy"                                           │["Adventure", "Action", "Drama", "War"]  │7.2       │
└─────────┴─────────────────────────────────────────────────┴─────────────────────────────────────────┴──────────┘
// This makes sense to me, but I am curious to see what differences (if any) may come up flipping the filters around.
MATCH (p:User {name:'Darlene Garcia'}), (m:Movie)-[:IN_GENRE]->(g:Genre)
WHERE NOT (p)-[:RATED]->(m)
WITH collect(g.name) AS genres, m
WHERE ANY(item IN genres WHERE item IN ['Drama', 'Comedy'])
WITH genres, m
WHERE ANY(item IN genres WHERE item IN ['War', 'Film-Noir'])
RETURN m.movieId, m.title, genres, m.imdbRating AS IMDB_Score
LIMIT 10;
// And there were no differences, which I kind of expected given the transitive properties of this query.
// But what if we look at situations where the movie has to occupy the Drama AND Comedy genres, then filter based
// on the genre scores for War and Film-Noir?
MATCH (p:User {name:'Darlene Garcia'}), (m:Movie)-[:IN_GENRE]->(g:Genre)
WHERE NOT (p)-[:RATED]->(m)
WITH collect(g.name) AS genres, m
WHERE ALL(g IN ['Drama','Comedy'] WHERE g IN genres)
WITH genres, m
WHERE ANY(item IN genres WHERE item IN ['War', 'Film-Noir'])
RETURN m.movieId, m.title, genres, m.imdbRating AS IMDB_Score
LIMIT 10;
╒═════════╤══════════════════════════════════════════════╤══════════════════════════════════════════════════════════════════════╤══════════╕
│m.movieId│m.title                                       │genres                                                                │IMDB_Score│
╞═════════╪══════════════════════════════════════════════╪══════════════════════════════════════════════════════════════════════╪══════════╡
│81132    │"Rubber"                                      │["Adventure", "Action", "Drama", "Comedy", "Western", "Horror", "Crime│5.8       │
│         │                                              │", "Thriller", "Mystery", "Film-Noir"]                                │          │
├─────────┼──────────────────────────────────────────────┼──────────────────────────────────────────────────────────────────────┼──────────┤
│8690     │"Slaughterhouse-Five"                         │["Sci-Fi", "Drama", "War", "Comedy"]                                  │7.0       │
├─────────┼──────────────────────────────────────────────┼──────────────────────────────────────────────────────────────────────┼──────────┤
│1273     │"Down by Law"                                 │["Drama", "Comedy", "Film-Noir"]                                      │7.9       │
├─────────┼──────────────────────────────────────────────┼──────────────────────────────────────────────────────────────────────┼──────────┤
│1281     │"Great Dictator, The"                         │["Drama", "War", "Comedy"]                                            │8.5       │
├─────────┼──────────────────────────────────────────────┼──────────────────────────────────────────────────────────────────────┼──────────┤
│48032    │"Tiger and the Snow, The (La tigre e la neve)"│["Drama", "War", "Comedy", "Romance"]                                 │7.2       │
├─────────┼──────────────────────────────────────────────┼──────────────────────────────────────────────────────────────────────┼──────────┤
│665      │"Underground"                                 │["Drama", "War", "Comedy"]                                            │8.1       │
├─────────┼──────────────────────────────────────────────┼──────────────────────────────────────────────────────────────────────┼──────────┤
│946      │"To Be or Not to Be"                          │["Drama", "War", "Comedy"]                                            │8.2       │
├─────────┼──────────────────────────────────────────────┼──────────────────────────────────────────────────────────────────────┼──────────┤
│3035     │"Mister Roberts"                              │["Drama", "War", "Comedy"]                                            │7.8       │
├─────────┼──────────────────────────────────────────────┼──────────────────────────────────────────────────────────────────────┼──────────┤
│3003     │"Train of Life (Train de vie)"                │["Drama", "War", "Comedy", "Romance"]                                 │7.7       │
├─────────┼──────────────────────────────────────────────┼──────────────────────────────────────────────────────────────────────┼──────────┤
│2436     │"Tea with Mussolini"                          │["Drama", "War", "Comedy"]                                            │6.9       │
└─────────┴──────────────────────────────────────────────┴──────────────────────────────────────────────────────────────────────┴──────────┘
// That's a pretty different list of results...

// Q5: Merge Cypher queries of Part 1 and Part 2 to create the final list of recommendations
// Now if we throw in the ranking by IMDB Rating...
MATCH (p:User {name:'Darlene Garcia'}), (m:Movie)-[:IN_GENRE]->(g:Genre)
WHERE NOT (p)-[:RATED]->(m)
WITH collect(g.name) AS genres, m
WHERE ANY(item IN genres WHERE item IN ['War', 'Film-Noir'])
WITH genres, m
WHERE ANY(item IN genres WHERE item IN ['Drama', 'Comedy'])
RETURN m.movieId, m.title, genres, m.imdbRating AS IMDB_Score
ORDER BY IMDB_Score DESC
LIMIT 5;
╒═════════╤═════════════════════════════════════════╤═════════════════════════════╤══════════╕
│m.movieId│m.title                                  │genres                       │IMDB_Score│
╞═════════╪═════════════════════════════════════════╪═════════════════════════════╪══════════╡
│7502     │"Band of Brothers"                       │["Action", "Drama", "War"]   │9.6       │
├─────────┼─────────────────────────────────────────┼─────────────────────────────┼──────────┤
│108709   │"Generation Kill"                        │["Drama", "War"]             │8.7       │
├─────────┼─────────────────────────────────────────┼─────────────────────────────┼──────────┤
│27611    │"Battlestar Galactica"                   │["Sci-Fi", "Drama", "War"]   │8.7       │
├─────────┼─────────────────────────────────────────┼─────────────────────────────┼──────────┤
│2028     │"Saving Private Ryan"                    │["Action", "Drama", "War"]   │8.6       │
├─────────┼─────────────────────────────────────────┼─────────────────────────────┼──────────┤
│5690     │"Grave of the Fireflies (Hotaru no haka)"│["Drama", "War", "Animation"]│8.5       │
└─────────┴─────────────────────────────────────────┴─────────────────────────────┴──────────┘
// This list ends up not being substantially different from the results of Part 2.
// But what if we took the method from the end of the last part and applied the IMDB Score ranking here?
MATCH (p:User {name:'Darlene Garcia'}), (m:Movie)-[:IN_GENRE]->(g:Genre)
WHERE NOT (p)-[:RATED]->(m)
WITH collect(g.name) AS genres, m
WHERE ALL(g IN ['Drama','Comedy'] WHERE g IN genres)
WITH genres, m
WHERE ANY(item IN genres WHERE item IN ['War', 'Film-Noir'])
RETURN m.movieId, m.title, genres, m.imdbRating AS IMDB_Score
ORDER BY IMDB_Score DESC
LIMIT 5;
╒═════════╤═════════════════════╤════════════════════════════════╤══════════╕
│m.movieId│m.title              │genres                          │IMDB_Score│
╞═════════╪═════════════════════╪════════════════════════════════╪══════════╡
│1281     │"Great Dictator, The"│["Drama", "War", "Comedy"]      │8.5       │
├─────────┼─────────────────────┼────────────────────────────────┼──────────┤
│946      │"To Be or Not to Be" │["Drama", "War", "Comedy"]      │8.2       │
├─────────┼─────────────────────┼────────────────────────────────┼──────────┤
│665      │"Underground"        │["Drama", "War", "Comedy"]      │8.1       │
├─────────┼─────────────────────┼────────────────────────────────┼──────────┤
│1273     │"Down by Law"        │["Drama", "Comedy", "Film-Noir"]│7.9       │
├─────────┼─────────────────────┼────────────────────────────────┼──────────┤
│3035     │"Mister Roberts"     │["Drama", "War", "Comedy"]      │7.8       │
└─────────┴─────────────────────┴────────────────────────────────┴──────────┘
// Although ratings seem to be lower, we do get some interesting recommendations that are significantly different
// than our other approach.