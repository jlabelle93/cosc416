MATCH (p:User)-[:RATED]->(m:Movie)
WHERE p.name <> 'Darlene Garcia'
WITH p AS peer, collect(m.movieId) AS peerMovies
MATCH (d:User {name: 'Darlene Garcia'})-[:RATED]->(m2:Movie)
WITH peer, peerMovies, collect(m2.movieId) AS darleneMovies
WITH peer, apoc.coll.subtract(peerMovies, darleneMovies) AS possRecommendations
WHERE peer.name IN ['Michelle Harris', 'Mrs. Megan Davis', 'Michael Simmons', 'Sue Mason', 'Amber Thompson', 'Briana Lara', 'Randy Blake', 'Robert Jones', 'Zachary Bowers', 'Alexis Lopez']
CALL {
    WITH peer, possRecommendations
    MATCH (peer)-[r:RATED]->(m:Movie)
    WHERE m.movieId IN possRecommendations AND NOT m.imdbRating IS null 
    WITH peer, m, r.rating AS rating
    RETURN peer AS p, collect(m {.*, userRating: rating}) AS top
}
WITH peer, p, top
UNWIND top AS peerTop
RETURN DISTINCT peerTop.title AS Recommendation, round(avg(peerTop.userRating), 1) AS Avg_Peer_Rating, count(peerTop.title) AS Votes, peerTop.imdbRating AS imdbRating
ORDER BY Avg_Peer_Rating DESC
LIMIT 5;

//Ranked by Avg_Peer_Rating
╒═══════════════════════════════════════════════════════════╤═══════════════╤═════╤══════════╕
│Recommendation                                             │Avg_Peer_Rating│Votes│imdbRating│
╞═══════════════════════════════════════════════════════════╪═══════════════╪═════╪══════════╡
│"Sin City"                                                 │5.0            │1    │8.1       │
├───────────────────────────────────────────────────────────┼───────────────┼─────┼──────────┤
│"Black Cat, White Cat (Crna macka, beli macor)"            │5.0            │1    │8.1       │
├───────────────────────────────────────────────────────────┼───────────────┼─────┼──────────┤
│"Arizona Dream"                                            │5.0            │1    │7.4       │
├───────────────────────────────────────────────────────────┼───────────────┼─────┼──────────┤
│"Passion of Joan of Arc, The (Passion de Jeanne d'Arc, La)"│5.0            │1    │8.4       │
├───────────────────────────────────────────────────────────┼───────────────┼─────┼──────────┤
│"And the Ship Sails On (E la nave va)"                     │5.0            │1    │7.7       │
└───────────────────────────────────────────────────────────┴───────────────┴─────┴──────────┘

//Ranked by Avg_Peer_Rating, imdbRating
╒═══════════════════════╤═══════════════╤═════╤══════════╕
│Recommendation         │Avg_Peer_Rating│Votes│imdbRating│
╞═══════════════════════╪═══════════════╪═════╪══════════╡
│"Generation Kill"      │5.0            │1    │8.7       │
├───────────────────────┼───────────────┼─────┼──────────┤
│"Louis C.K.: Shameless"│5.0            │1    │8.7       │
├───────────────────────┼───────────────┼─────┼──────────┤
│"Louis C.K.: Hilarious"│5.0            │1    │8.6       │
├───────────────────────┼───────────────┼─────┼──────────┤
│"Baraka"               │5.0            │1    │8.6       │
├───────────────────────┼───────────────┼─────┼──────────┤
│"Louis C.K.: Chewed Up"│5.0            │1    │8.6       │
└───────────────────────┴───────────────┴─────┴──────────┘

MATCH (p:User)-[:RATED]->(m:Movie)
WHERE p.name <> 'Darlene Garcia'
WITH p AS peer, collect(m.movieId) AS peerMovies
MATCH (d:User {name: 'Darlene Garcia'})-[:RATED]->(m2:Movie)
WITH peer, peerMovies, collect(m2.movieId) AS darleneMovies
WITH peer, apoc.coll.subtract(peerMovies, darleneMovies) AS possRecommendations
WHERE peer.name IN ['Michelle Harris', 'Mrs. Megan Davis', 'Michael Simmons', 'Sue Mason', 'Amber Thompson', 'Briana Lara', 'Randy Blake', 'Robert Jones', 'Zachary Bowers', 'Alexis Lopez']
CALL {
    WITH peer, possRecommendations
    MATCH (peer)-[r:RATED]->(m:Movie)
    WHERE m.movieId IN possRecommendations AND NOT m.imdbRating IS null 
    WITH peer, m, r.rating AS rating
    RETURN peer AS p, collect(m {.*, userRating: rating}) AS top
}
WITH peer, p, top
UNWIND top AS peerTop
WITH DISTINCT peerTop.title AS Recommendation, round(avg(peerTop.userRating), 1) AS Avg_Peer_Rating, count(peerTop.title) AS Votes, peerTop.imdbRating AS imdbRating
WHERE Votes > 2
RETURN Recommendation, Avg_Peer_Rating, Votes, imdbRating
ORDER BY Avg_Peer_Rating DESC
LIMIT 5;

//Discard single reviews
╒══════════════════════════════════════════════════╤═══════════════╤═════╤══════════╕
│Recommendation                                    │Avg_Peer_Rating│Votes│imdbRating│
╞══════════════════════════════════════════════════╪═══════════════╪═════╪══════════╡
│"The Earrings of Madame de..."                    │5.0            │2    │8.1       │
├──────────────────────────────────────────────────┼───────────────┼─────┼──────────┤
│"To Be or Not to Be"                              │5.0            │2    │8.2       │
├──────────────────────────────────────────────────┼───────────────┼─────┼──────────┤
│"Trouble in Paradise"                             │5.0            │2    │8.2       │
├──────────────────────────────────────────────────┼───────────────┼─────┼──────────┤
│"Ikiru"                                           │4.8            │2    │8.3       │
├──────────────────────────────────────────────────┼───────────────┼─────┼──────────┤
│"Motorcycle Diaries, The (Diarios de motocicleta)"│4.8            │2    │7.8       │
└──────────────────────────────────────────────────┴───────────────┴─────┴──────────┘

//At least 3 reviews
╒═══════════════════════════════════════════════╤═══════════════╤═════╤══════════╕
│Recommendation                                 │Avg_Peer_Rating│Votes│imdbRating│
╞═══════════════════════════════════════════════╪═══════════════╪═════╪══════════╡
│"Princess Bride, The"                          │4.5            │3    │8.1       │
├───────────────────────────────────────────────┼───────────────┼─────┼──────────┤
│"Maltese Falcon, The (a.k.a. Dangerous Female)"│4.5            │3    │7.4       │
├───────────────────────────────────────────────┼───────────────┼─────┼──────────┤
│"Monty Python and the Holy Grail"              │4.4            │5    │8.3       │
├───────────────────────────────────────────────┼───────────────┼─────┼──────────┤
│"The Hunger Games: Catching Fire"              │4.3            │3    │7.6       │
├───────────────────────────────────────────────┼───────────────┼─────┼──────────┤
│"Ninotchka"                                    │4.3            │3    │8.0       │
└───────────────────────────────────────────────┴───────────────┴─────┴──────────┘

MATCH (p:User)-[:RATED]->(m:Movie)
WHERE p.name <> 'Darlene Garcia'
WITH p AS peer, collect(m.movieId) AS peerMovies
MATCH (d:User {name: 'Darlene Garcia'})-[:RATED]->(m2:Movie)
WITH peer, peerMovies, collect(m2.movieId) AS darleneMovies
WITH peer, apoc.coll.subtract(peerMovies, darleneMovies) AS possRecommendations
WHERE peer.name IN ['Michelle Harris', 'Mrs. Megan Davis', 'Michael Simmons', 'Sue Mason', 'Amber Thompson', 'Briana Lara', 'Randy Blake', 'Robert Jones', 'Zachary Bowers', 'Alexis Lopez']
CALL {
    WITH peer, possRecommendations
    MATCH (peer)-[r:RATED]->(m:Movie)
    WHERE m.movieId IN possRecommendations AND NOT m.imdbRating IS null 
    WITH peer, m, r.rating AS rating
    RETURN peer AS p, collect(m {.*, userRating: rating}) AS top
}
WITH peer, p, top
UNWIND top AS peerTop
WITH DISTINCT peerTop.title AS Recommendation, round(avg(peerTop.userRating), 1) AS Avg_Peer_Rating, count(peerTop.title) AS Votes, peerTop.imdbRating AS imdbRating
RETURN Recommendation, Avg_Peer_Rating, Votes, Avg_Peer_Rating*Votes AS Weighted_Peer_Rating, imdbRating
ORDER BY Weighted_Peer_Rating DESC
LIMIT 5;

//Weighted Peer Rating
╒════════════════════════════════════════════════╤═══════════════╤═════╤════════════════════╤══════════╕
│Recommendation                                  │Avg_Peer_Rating│Votes│Weighted_Peer_Rating│imdbRating│
╞════════════════════════════════════════════════╪═══════════════╪═════╪════════════════════╪══════════╡
│"Lord of the Rings: The Two Towers, The"        │3.7            │8    │29.6                │8.7       │
├────────────────────────────────────────────────┼───────────────┼─────┼────────────────────┼──────────┤
│"Lord of the Rings: The Return of the King, The"│3.5            │8    │28.0                │8.9       │
├────────────────────────────────────────────────┼───────────────┼─────┼────────────────────┼──────────┤
│"Monty Python and the Holy Grail"               │4.4            │5    │22.0                │8.3       │
├────────────────────────────────────────────────┼───────────────┼─────┼────────────────────┼──────────┤
│"Batman Begins"                                 │4.1            │4    │16.4                │8.3       │
├────────────────────────────────────────────────┼───────────────┼─────┼────────────────────┼──────────┤
│"Casino Royale"                                 │4.0            │4    │16.0                │8.0       │
└────────────────────────────────────────────────┴───────────────┴─────┴────────────────────┴──────────┘
