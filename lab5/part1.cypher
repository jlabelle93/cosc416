MATCH (p:User)-[:RATED]->(m:Movie)
WITH p.name AS peer, count(m) AS peerRated, collect(m.movieId) AS peerWatched
MATCH (d:User {name:'Diana Robles'})-[:RATED]->(m2)
WHERE NOT peer = d.name
WITH peer, peerRated, peerWatched, collect(m2.movieId) AS watched
RETURN peer, peerRated, size(apoc.coll.intersection(peerWatched, watched)) AS Common, round(gds.similarity.jaccard(peerWatched, watched), 4) AS Jaccard
ORDER BY Common DESC
LIMIT 10;

MATCH (p:User)-[:RATED]->(m:Movie)
WITH p.name AS peer, count(m) AS peerRated, collect(m.movieId) AS peerWatched
MATCH (d:User {name:'Diana Robles'})-[:RATED]->(m2)
WHERE NOT peer = d.name
WITH peer, peerRated, peerWatched, collect(m2.movieId) AS watched
RETURN peer, peerRated, size(apoc.coll.intersection(peerWatched, watched)) AS Common, round(gds.similarity.jaccard(peerWatched, watched), 4) AS Jaccard
ORDER BY Jaccard DESC
LIMIT 10;
// Matches Vlad's results

// Now with Darlene Garcia (who rated 2391 movies)...
MATCH (p:User)-[:RATED]->(m:Movie)
WITH p.name AS peer, count(m) AS peerRated, collect(m.movieId) AS peerWatched
MATCH (d:User {name:'Darlene Garcia'})-[:RATED]->(m2)
WHERE NOT peer = d.name
WITH peer, peerRated, peerWatched, collect(m2.movieId) AS watched
RETURN peer, peerRated, size(apoc.coll.intersection(peerWatched, watched)) AS Common, round(gds.similarity.jaccard(peerWatched, watched), 4) AS Jaccard
ORDER BY Common DESC
LIMIT 5;
╒═══════════════╤═════════╤══════╤═══════╕
│peer           │peerRated│Common│Jaccard│
╞═══════════════╪═════════╪══════╪═══════╡
│"Angela Garcia"│1700     │796   │0.2416 │
├───────────────┼─────────┼──────┼───────┤
│"Larry Boyd"   │1340     │771   │0.2605 │
├───────────────┼─────────┼──────┼───────┤
│"Rita Owens"   │1291     │678   │0.2257 │
├───────────────┼─────────┼──────┼───────┤
│"Robert Brooks"│1868     │657   │0.1824 │
├───────────────┼─────────┼──────┼───────┤
│"Aaron Castro" │1011     │554   │0.1945 │
└───────────────┴─────────┴──────┴───────┘
MATCH (p:User)-[:RATED]->(m:Movie)
WHERE NOT p.name = 'Darlene Garcia'
WITH p.name AS peer, count(m) AS peerRated, collect(m.movieId) AS peerWatched
MATCH (:User {name:'Darlene Garcia'})-[:RATED]->(m2)
WITH peer, peerRated, peerWatched, collect(m2.movieId) AS watched
RETURN peer, peerRated, size(apoc.coll.intersection(peerWatched, watched)) AS Common, round(gds.similarity.jaccard(peerWatched, watched), 4) AS Jaccard
ORDER BY Jaccard DESC
LIMIT 5;
╒═════════════════╤═════════╤══════╤═══════╕
│peer             │peerRated│Common│Jaccard│
╞═════════════════╪═════════╪══════╪═══════╡
│"Larry Boyd"     │1340     │771   │0.2605 │
├─────────────────┼─────────┼──────┼───────┤
│"Angela Garcia"  │1700     │796   │0.2416 │
├─────────────────┼─────────┼──────┼───────┤
│"Rita Owens"     │1291     │678   │0.2257 │
├─────────────────┼─────────┼──────┼───────┤
│"Aaron Castro"   │1011     │554   │0.1945 │
├─────────────────┼─────────┼──────┼───────┤
│"Crystal Spencer"│923      │533   │0.1917 │
└─────────────────┴─────────┴──────┴───────┘

// Combined with Lab 4...

MATCH (p:User)-[:RATED]->(m:Movie)
WHERE NOT p.name = 'Darlene Garcia'
WITH p AS peer, count(m) AS peerRated, collect(m.movieId) AS peerWatched
WITH peer, peerRated, peerWatched
CALL {
    WITH peer
    MATCH (peer)-[:RATED]->(m:Movie)-[:IN_GENRE]->(g:Genre)
    WITH peer, g.name AS genres, count(m) AS mg ORDER BY mg DESC
    RETURN peer AS p, collect(genres)[0..3] AS top3
}
WITH peer, peerRated, top3, peerWatched
CALL {
    MATCH (u:User {name: 'Darlene Garcia'})-[:RATED]->(m2:Movie)
    RETURN u AS dg, collect(m2.movieId) AS dgW
}
WITH peer, peerRated, peerWatched, size(apoc.coll.intersection(peerWatched, dgW)) AS common, round(gds.similarity.jaccard(peerWatched, dgW), 4) AS jaccard, top3, ['Drama', 'Comedy', 'Romance'] AS dg3
RETURN  peer.name AS Peer, peerRated, common, top3, jaccard, size(apoc.coll.intersection(top3, dg3)) AS commonTop
ORDER BY commonTop DESC, jaccard DESC
LIMIT 5;

╒═════════════════╤═════════╤══════╤══════════════════════════════╤═══════╤═════════╕
│Peer             │peerRated│common│top3                          │jaccard│commonTop│
╞═════════════════╪═════════╪══════╪══════════════════════════════╪═══════╪═════════╡
│"Larry Boyd"     │1340     │771   │["Drama", "Comedy", "Romance"]│0.2605 │3        │
├─────────────────┼─────────┼──────┼──────────────────────────────┼───────┼─────────┤
│"Crystal Spencer"│923      │533   │["Drama", "Comedy", "Romance"]│0.1917 │3        │
├─────────────────┼─────────┼──────┼──────────────────────────────┼───────┼─────────┤
│"John Herrera"   │830      │493   │["Drama", "Comedy", "Romance"]│0.1807 │3        │
├─────────────────┼─────────┼──────┼──────────────────────────────┼───────┼─────────┤
│"Marissa Choi"   │1019     │498   │["Drama", "Comedy", "Romance"]│0.171  │3        │
├─────────────────┼─────────┼──────┼──────────────────────────────┼───────┼─────────┤
│"Julia Compton"  │726      │432   │["Drama", "Comedy", "Romance"]│0.1609 │3        │
└─────────────────┴─────────┴──────┴──────────────────────────────┴───────┴─────────┘


MATCH (p:User)-[:RATED]->(m:Movie)-[:IN_GENRE]->(g:Genre)
WHERE NOT p.name = 'Darlene Garcia' AND g.name IN ['Drama', 'Comedy', 'Romance']
WITH p AS peer, collect(m.movieId) AS peerMovies
MATCH (d:User {name: 'Darlene Garcia'})-[:RATED]->(m2:Movie)
WITH peer, peerMovies, collect(m2.movieId) AS darleneMovies
WITH peer, apoc.coll.subtract(peerMovies, darleneMovies) AS possRecommendations
WHERE peer.name IN ['Larry Boyd', 'Crystal Spencer', 'John Herrera', 'Marissa Choi', 'Julia Compton']
CALL {
    WITH peer, possRecommendations
    MATCH (m:Movie)
    WHERE m.movieId IN possRecommendations AND NOT m.imdbRating IS null 
    WITH peer, m, m.imdbRating AS rating ORDER BY rating DESC
    RETURN peer AS p, collect(m.title)[0..5] AS top5
}
WITH peer, top5
UNWIND top5 AS title
RETURN DISTINCT title AS Recommendation, count(title) AS Votes
ORDER BY Votes DESC
LIMIT 5;

╒═════════════════╤══════════════════════════════════════════════════════════════════════╕
│Peer             │Top_5_Suggestions                                                     │
╞═════════════════╪══════════════════════════════════════════════════════════════════════╡
│"Larry Boyd"     │["Léon: The Professional (a.k.a. The Professional) (Léon)", "Saving Pr│
│                 │ivate Ryan", "Braveheart", "Scarface", "Bill Cosby, Himself"]         │
├─────────────────┼──────────────────────────────────────────────────────────────────────┤
│"Marissa Choi"   │["Léon: The Professional (a.k.a. The Professional) (Léon)", "Saving Pr│
│                 │ivate Ryan", "Lion King, The", "Braveheart", "Princess Mononoke (Monon│
│                 │oke-hime)"]                                                           │
├─────────────────┼──────────────────────────────────────────────────────────────────────┤
│"Julia Compton"  │["Lord of the Rings: The Return of the King, The", "Léon: The Professi│
│                 │onal (a.k.a. The Professional) (Léon)", "Saving Private Ryan", "Great │
│                 │Dictator, The", "Children of Heaven, The (Bacheha-Ye Aseman)"]        │
├─────────────────┼──────────────────────────────────────────────────────────────────────┤
│"John Herrera"   │["Lord of the Rings: The Return of the King, The", "Léon: The Professi│
│                 │onal (a.k.a. The Professional) (Léon)", "Once Upon a Time in the West │
│                 │(C'era una volta il West)", "Saving Private Ryan", "Lion King, The"]  │
├─────────────────┼──────────────────────────────────────────────────────────────────────┤
│"Crystal Spencer"│["Lord of the Rings: The Return of the King, The", "Léon: The Professi│
│                 │onal (a.k.a. The Professional) (Léon)", "Saving Private Ryan", "Lion K│
│                 │ing, The", "Great Dictator, The"]                                     │
└─────────────────┴──────────────────────────────────────────────────────────────────────┘

╒═════════════════════════════════════════════════════════╤═════╕
│Recommendation                                           │Votes│
╞═════════════════════════════════════════════════════════╪═════╡
│"Léon: The Professional (a.k.a. The Professional) (Léon)"│5    │
├─────────────────────────────────────────────────────────┼─────┤
│"Saving Private Ryan"                                    │5    │
├─────────────────────────────────────────────────────────┼─────┤
│"Lord of the Rings: The Return of the King, The"         │3    │
├─────────────────────────────────────────────────────────┼─────┤
│"Lion King, The"                                         │3    │
├─────────────────────────────────────────────────────────┼─────┤
│"Braveheart"                                             │2    │
└─────────────────────────────────────────────────────────┴─────┘