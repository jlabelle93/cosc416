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
WITH p.name AS peer, count(m) AS peerRated, collect(m.movieId) AS peerWatched
MATCH (d:User {name:'Darlene Garcia'})-[:RATED]->(m2)
WHERE NOT peer = d.name
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

