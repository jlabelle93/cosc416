// Q1: What is the average rating of movies the user watched?
MATCH (p:User{name: 'Darlene Garcia'})-[r:RATED]->(:Movie)
RETURN round(avg(r.rating), 2);
// Average rating of the movies Darlene watched is 3.37

// Q2: What is the average rating per genre?
MATCH (p:User{name: 'Darlene Garcia'})-[r:RATED]->(:Movie)-[:IN_GENRE]->(g:Genre)
RETURN g.name As Genre, round(avg(r.rating), 2) AS Rating
ORDER BY Rating DESC;
// The top three highest rated genres for Darlene are: War (3.9), Film-Noir (3.74), and Documentary (3.72).
// Interestingly when I ran the query above, I had "(no genres listed)" show up as the second
// highest rated "genre" for Darlene. This could cause some difficulties in generating recommendations off of this
// because how do we recommend something from that genre? They could be absolutely different types of movies with no
// other correlation to one another.
 
// Q3: What genres are the best candidates for recommendations based on the movie ratings?
// As mentioned above, when we take into account movies with defined genres we can definitively recommend
// War or Film-Noir genres to Darlene. However, we can't action her second-highest rated "genre", as it is effectively
// "no genre listed". We could generate a list of recommendations for this "genre", but as mentioned previously would run
// into the issue where movies matching this attribute may have absolutely no relation or thematic similarities with one another.

// Q4: Create a tentative list of recommended movies based on the average ratings
// Are we saying movies that Darlene would recommend, or are we saying movies that should be recommended to Darlene based on
// ratings by other users? If the latter, is that not something that is closer to collaborative filtering than content based filtering?
//
MATCH (p:User {name:'Darlene Garcia'}), (m:Movie)-[:IN_GENRE]->(g:Genre)
WHERE NOT (p)-[:RATED]->(m)
WITH collect(g.name) AS genres, m
MATCH (m)<-[r:RATED]-(:User)
WHERE ANY(item IN genres WHERE item IN ['War', 'Film-Noir'])
RETURN m.movieId, m.title, genres, round(avg(r.rating), 2) AS Ratings
ORDER BY Ratings DESC
LIMIT 100;
// Here's a list of possible recommendations for any film in the War or Film-Noir genres that Darlene hasn't watched,
// ranked by their average user rating.
// If we wanted to restrict it to movies that are both War and Film-Noir then...
MATCH (p:User {name:'Darlene Garcia'}), (m:Movie)-[:IN_GENRE]->(g:Genre)
WHERE NOT (p)-[:RATED]->(m)
WITH collect(g.name) AS genres, m
MATCH (m)<-[r:RATED]-(:User)
WHERE ALL(g IN ['War','Film-Noir'] WHERE g IN genres)
RETURN m.movieId, m.title, genres, round(avg(r.rating), 2) AS Ratings
ORDER BY Ratings DESC
LIMIT 100;
// ... there would be no results as there are no movies that belong to both genres together.

// Overall average user ratings of movies in the database
MATCH (:User)-[r:RATED]->(m:Movie)
RETURN m.movieId AS ID, m.title AS Movie, round(avg(r.rating), 2) AS Rating
ORDER BY Rating DESC

// So with the clarifications from lab, we take the top recommendations Darlene would make for the War and Film-Noir genres...
MATCH (p:User {name:'Darlene Garcia'}), (m:Movie)-[:IN_GENRE]->(g:Genre)
WHERE NOT (p)-[:RATED]->(m)
WITH collect(g.name) AS genres, m
WHERE ANY(item IN genres WHERE item IN ['War', 'Film-Noir'])
RETURN m.movieId, m.title, genres
LIMIT 100;
// Returns a list of 100 movies we could recommend to Darlene based on her preferences for the War or Film-Noir genres. This list of movies is not
// currently sorted by any metric and represents purely a sample of movies she has not seen from these genres.

// Q5: Use imdbRating data as a score to rank the recommended movies
MATCH (p:User {name:'Darlene Garcia'}), (m:Movie)-[:IN_GENRE]->(g:Genre)
WHERE NOT (p)-[:RATED]->(m)
WITH collect(g.name) AS genres, m
WHERE ANY(item IN genres WHERE item IN ['War', 'Film-Noir'])
RETURN m.movieId, m.title, genres, m.imdbRating AS IMDB_Score
ORDER BY IMDB_Score DESC
LIMIT 100;
// This results in a different list when we rank the possible recommendations by IMDB rating instead. There seems to be a trend where war movies are more highly
// rated in their IMDB scores.

// Q6: Create the Top 5 Movies to Watch list
// Using IMDB Ratings...
MATCH (p:User {name:'Darlene Garcia'}), (m:Movie)-[:IN_GENRE]->(g:Genre)
WHERE NOT (p)-[:RATED]->(m)
WITH collect(g.name) AS genres, m
WHERE ANY(item IN genres WHERE item IN ['War', 'Film-Noir'])
RETURN m.movieId, m.title, genres, m.imdbRating AS IMDB_Score
ORDER BY IMDB_Score DESC
LIMIT 5;
// With the results:
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

// Disregard this section... left in to show a direction I was pursuing before clarification
// Using average user ratings...
MATCH (p:User {name:'Darlene Garcia'}), (m:Movie)-[:IN_GENRE]->(g:Genre)
WHERE NOT (p)-[:RATED]->(m)
WITH collect(g.name) AS genres, m
MATCH (m)<-[r:RATED]-(:User)
WHERE ANY(item IN genres WHERE item IN ['War', 'Film-Noir'])
RETURN m.movieId, m.title, genres, round(avg(r.rating), 2) AS Ratings
ORDER BY Ratings DESC
LIMIT 100;
// With the results:
╒═════════╤═════════════════════╤════════════════════════════════════════╤═══════╕
│m.movieId│m.title              │genres                                  │Ratings│
╞═════════╪═════════════════════╪════════════════════════════════════════╪═══════╡
│97826    │"Patience Stone, The"│["Drama", "War"]                        │5.0    │
├─────────┼─────────────────────┼────────────────────────────────────────┼───────┤
│126430   │"The Pacific"        │["Adventure", "Action", "Drama", "War"] │5.0    │
├─────────┼─────────────────────┼────────────────────────────────────────┼───────┤
│32515    │"Walker"             │["Adventure", "Drama", "War", "Western"]│5.0    │
├─────────┼─────────────────────┼────────────────────────────────────────┼───────┤
│8675     │"Enemy Below, The"   │["Action", "Drama", "War"]              │5.0    │
├─────────┼─────────────────────┼────────────────────────────────────────┼───────┤
│26791    │"Shining Through"    │["Drama", "War", "Romance", "Thriller"] │5.0    │
└─────────┴─────────────────────┴────────────────────────────────────────┴───────┘
// User scores seem like they could be much more skewed, as we have cases where a small group of users
// could manipulate the scores significantly with high or low ratings. Even in the case where a single user
// has watched a film and rated it as a 5, it could show up here.

// Q7: Discuss limitations of the approach
//
// What can make this approach break or render it less reliable or accurate?
// User manipulation is a big thing that can make or break this approach, as well as the actual volume
// of users who have rated a movie. A movie with a small number of users who have highly rated it, or rated it incredibly low,
// and thus it would have a high or low ranking depending on the case. There could also be significant discrepancies between internal
// user ratings and the IMDB scores for a film. Once more it also comes down to if a user has also watched enough movies to allow for the
// creation of a profile. This method relies heavily on there being enough films a user has watched that a preference for genre
// can be discerned.
//
// Should we attempt to compensate for the bias?
// 
// I would essentially repeat my arguments from Part 1 here again. The only bias we may need to compensate for would be the scenarios
// where there are a small number of user reviews that are on either extreme of the review scale. However, we once more run into the problem
// where we could cause artificial suppression of certain movies based on our efforts to more faily present some titles to users. This could also
// extend to IMDB Score, as I believe that is an aggregate of critic reviews. Movies with a smaller number of critic reviews could lead to a more skewed IMDB
// score.

