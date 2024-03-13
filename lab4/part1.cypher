// Part 1

MATCH (p:User)-[r:RATED]->(:Movie)
WITH count(r) AS Reviews, p
WHERE Reviews >= 300
RETURN DISTINCT p.name, Reviews
ORDER BY Reviews DESC
LIMIT 1;

// Darlene Garcia

// Q1: Darlene Garcia rated 2391 movies

MATCH (p:User{name: 'Darlene Garcia'})-[:RATED]->(m:Movie)-[:IN_GENRE]->(g:Genre)
WITH g.name AS genres
RETURN genres AS Genre, count(genres) AS Movies_Watched_in_Genre
ORDER BY Movies_Watched_in_Genre DESC;

// Q2: Darlene watched 1478 movies in the Drama genre. Comedy and Romance movies were the next closest at 798 and 546 respectively.

// Q3:
// Drama, Comedy, and Romance are the top three genres she has watched, according to her ratings history.
// Based on:
MATCH (m:Movie)-[:IN_GENRE]->(g:Genre)
WITH g.name AS genres
RETURN genres AS Genre, count(genres) AS Movies_in_Genre
ORDER BY Movies_in_Genre DESC;
// the most common genres in the dataset are Drama, Comedy, and Thriller.
// Thus it is most likely a user will watch something that belongs to the Drama or Comedy genres.
// This also means any recommendations to a user will also have a high chance of belonging to the Drama or Comedy genres
// due to the tendency to attach to highly connected nodes.

// Q4:
// As discussed above: Drama, Comedy, and Romance are the biggest hits on Darlene's watched list.
// It would make sense to recommend something to her that belongs to at least one of these genres.
// However, we may have an issue where she has already watched most of the movies belonging to a particular genre.

// List of Darlene's Movies belonging to Drama or Comedy Genres
MATCH (p:User {name:'Darlene Garcia'})-[:RATED]->(m:Movie)-[:IN_GENRE]->(g:Genre)
WHERE g.name IN ['Drama', 'Comedy']
RETURN m.movieId, m.title AS Darlene_Movies, collect(g.name);
// 2276
//
// List of all movies in the db belonging to Drama or Comedy Genres
MATCH (m:Movie)-[:IN_GENRE]->(g:Genre)
WHERE g.name IN ['Drama', 'Comedy']
RETURN m.movieId, m.title, collect(g.name);
// 7680
//
// List of all movies Darlene has not watched in the Drama or Comedy Genres
MATCH (p:User {name:'Darlene Garcia'}), (m:Movie)-[:IN_GENRE]->(g:Genre)
WHERE NOT(p)-[:RATED]->(m) AND g.name IN ['Drama', 'Comedy']
RETURN m.movieId, m.title;
// 5404
//

// Q5 & Q6:
MATCH (p:User {name:'Darlene Garcia'}), (m:Movie)-[:IN_GENRE]->(g:Genre)
WITH NOT(p)-[:RATED]->(m) AS Unwatched, collect(g.name) AS genres, m
WHERE NOT m.imdbRating IS NULL AND ANY(item IN genres WHERE item IN ['Drama', 'Comedy'])
RETURN m.movieId, m.title, genres, m.imdbRating
ORDER BY m.imdbRating DESC
LIMIT 100;
// With a 2:1 ratio of Drama movies watched to Comedy movies, it makes sense to push Darlene more towards
// drama titles, than try to steer her towards titles that are both drama AND comedy.

// Q7:
MATCH (p:User {name:'Darlene Garcia'}), (m:Movie)-[:IN_GENRE]->(g:Genre)
WITH NOT(p)-[:RATED]->(m) AS Unwatched, collect(g.name) AS genres, m
WHERE NOT m.imdbRating IS NULL AND ANY(item IN genres WHERE item IN ['Drama', 'Comedy'])
RETURN m.title AS Recommendation, m.imdbRating AS Score, genres AS Genres
ORDER BY m.imdbRating DESC
LIMIT 5;
// Results:
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
// OR
// We could recommend movies containing both Comedy and Drama genres to her:
MATCH (p:User {name:'Darlene Garcia'}), (m:Movie)-[:IN_GENRE]->(g:Genre)
WITH NOT(p)-[:RATED]->(m) AS Unwatched, collect(g.name) AS genres, m
WHERE NOT m.imdbRating IS NULL AND ALL(g IN ['Drama','Comedy'] WHERE g IN genres)
RETURN m.title AS Recommendation, m.imdbRating AS Score, genres AS Genres
ORDER BY m.imdbRating DESC
LIMIT 5;
// Results
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

// Q8:
// 
// Will it work well for other users? 
// 
// Darlene does not represent your typical user. She has a wealth of data to draw from to create recommendations.
// However, the approach to recommendation that I have taken would work well with a user who has consumed a fairly significant amount of content.
//
// Can it break down? What are the implicit conditions of its applicability?
//
// This approach definitely hits limits for new users or for users that have watched a small amount of films. Obviously with new users, the cold start
// problem applies from a purely content based approach. This could be remedied by layering in the collaborative filtering approach. With users who have watched
// a small amount of films, the problem could also be that they do not have a perceptible trend in their viewing habits. Let's say a user has watched less than 10 movies,
// and there has been no repetition of any genre in that data set. Improbable, but possible. Attempting to make a recommendation based on the above approach will
// prove to be difficult as there is no defined "taste preference". We could approach purely from a highly-rated film perspective and give some recommendations on that front,
// but even that may not be a reliable source as overall ratings are a very high level look at a very subjective metric.
//
// How to compensate the bias caused by the uneven representation of genres in the database?
// 
// We could apply some form of ranking based on the percentage of the database a certain genre represents. Genres that occur frequently would have a 
// fractional multiplier applied to them, while underrepresented genres could just have a multiplier applied. This seems like the most logical way to
// compensate for the prevalence of Drama in particular. Another more complex approach could possibly be to put more emphasis on the secondary genres associated
// with a movie that has the Drama genre attached to it.
//
// Should this bias be compensated? Discuss pro and contra arguments.
//
// Any attempt at reducing bias runs significant risk of injecting more bias in the system. An argument in favour of introducing a form of compensation
// would be the obvious: allow users to interact with content that is perhaps underserved or underrepresented. It may also serve user taste profiles to serve
// this content as they may prefer niche movies or say, low rated movies. However, this system would need constant tweaks as new movies are added to the database.
// This could lead to other problems where new movies belonging solely to a dominant genre would then be suppressed in recommendations and artificially have engagement
// lowered.
//
// Other thoughts based on your understanding?
//
// Content based filtering has strengths in a large datasource, where there has been enough user engagement to develop a rough profile of the user.
// In order to make recommendations with this, we do need a fair amount of inferred information about the user based on their habits using the system.