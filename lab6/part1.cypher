CALL gds.graph.project("Peers", 
  ['Movie', 'User'], 
  { RATED:{orientation: "UNDIRECTED"}}
)
YIELD *;

call gds.graph.list 
      yield degreeDistribution, graphName, memoryUsage,
      sizeInBytes, nodeCount, relationshipCount, 
      density, schemaWithOrientation;

CALL gds.fastRP.mutate (
     "Peers", 
    { embeddingDimension:64, 
      IterationWeights: [0.0,1.0,1.0,1.0,1.0], 
      randomSeed:7474, // for reproducibility 
      mutateProperty: "embedding" // property name
    }) YIELD *;

    CALL gds.knn.write("Peers", 
     { nodeLabels:["User"],  
     nodeProperties:"embedding", topK:5,
     writeRelationshipType: "PEER",
     writeProperty: "score", 
     randomSeed: 42, 
     sampleRate: 0.9, 
     concurrency: 1
     })
YIELD *;
// Check
// match(u) -[r:PEER] - (o) return * limit 50

MATCH (darlene:User where darlene.name IN ["Darlene Garcia"])-[p:PEER] -(o) 
RETURN *;

MATCH (darlene:User where darlene.name IN ["Darlene Garcia", "Christopher Thomas"])-[p:PEER] -(o) return *;

MATCH(darlene:User{name:"Darlene Garcia"})
CALL { WITH darlene
      MATCH (darlene)-[:PEER] - (peer:User) - [rate:RATED] ->(m:Movie)
      RETURN  m, rate, peer 
      ORDER BY  peer.score   DESC,  // peer similarity -- most similar peers first
                rate.rating  DESC   // peer rating     -- then their ratings
              }
WITH * 
WHERE NOT (darlene)-[:RATED] -(m)
RETURN  m.title              AS title,  
   ROUND(AVG(rate.rating),2) AS peerRating, // average peer rating
   COUNT(DISTINCT peer) AS votes,           // votes
   m.imdbRating         AS imdbRating       // imdbRating as is
ORDER BY peerRating * votes DESC            // measure of film quality
LIMIT 10;

╒════════════════════════════════════════════════════════════════════╤══════════╤═════╤══════════╕
│title                                                               │peerRating│votes│imdbRating│
╞════════════════════════════════════════════════════════════════════╪══════════╪═════╪══════════╡
│"Mighty Aphrodite"                                                  │4.0       │3    │7.1       │
├────────────────────────────────────────────────────────────────────┼──────────┼─────┼──────────┤
│"Star Wars: Episode IV - A New Hope"                                │4.0       │3    │8.7       │
├────────────────────────────────────────────────────────────────────┼──────────┼─────┼──────────┤
│"Before Sunset"                                                     │3.83      │3    │8.0       │
├────────────────────────────────────────────────────────────────────┼──────────┼─────┼──────────┤
│"Midnight in Paris"                                                 │4.75      │2    │7.7       │
├────────────────────────────────────────────────────────────────────┼──────────┼─────┼──────────┤
│"Departures (Okuribito)"                                            │4.5       │2    │8.1       │
├────────────────────────────────────────────────────────────────────┼──────────┼─────┼──────────┤
│"Saving Private Ryan"                                               │4.25      │2    │8.6       │
├────────────────────────────────────────────────────────────────────┼──────────┼─────┼──────────┤
│"Monty Python and the Holy Grail"                                   │4.25      │2    │8.3       │
├────────────────────────────────────────────────────────────────────┼──────────┼─────┼──────────┤
│"Bullets Over Broadway"                                             │4.25      │2    │7.5       │
├────────────────────────────────────────────────────────────────────┼──────────┼─────┼──────────┤
│"Diving Bell and the Butterfly, The (Scaphandre et le papillon, Le)"│4.0       │2    │8.0       │
├────────────────────────────────────────────────────────────────────┼──────────┼─────┼──────────┤
│"Superman II"                                                       │4.0       │2    │6.8       │
└────────────────────────────────────────────────────────────────────┴──────────┴─────┴──────────┘

MATCH(darlene:User{name:"Darlene Garcia"}) -[r:RATED] -()
WITH darlene, AVG(r.rating) AS darleneAvgRating
CALL { WITH darlene, darleneAvgRating
      MATCH (darlene)-[:PEER] -(peer:User) - [rate:RATED] ->(m:Movie)
      WHERE rate.rating >  darleneAvgRating
      RETURN  m, rate, peer 
      ORDER BY  peer.score   DESC,  // peer similarity -- most similar peers first
                rate.rating  DESC   // peer rating     -- then their ratings
              }
WITH * 
WHERE NOT (darlene)-[:RATED] -(m)
RETURN  m.title              AS title,  
   ROUND(AVG(rate.rating),2) AS peerRating, // average peer rating
   COUNT(DISTINCT peer) AS votes,           // votes
   m.imdbRating         AS imdbRating       // imdbRating as is
ORDER BY peerRating * votes DESC            // measure of film quality
LIMIT 10;

╒════════════════════════════════════════════════════════════════════╤══════════╤═════╤══════════╕
│title                                                               │peerRating│votes│imdbRating│
╞════════════════════════════════════════════════════════════════════╪══════════╪═════╪══════════╡
│"Star Wars: Episode IV - A New Hope"                                │4.0       │3    │8.7       │
├────────────────────────────────────────────────────────────────────┼──────────┼─────┼──────────┤
│"Before Sunset"                                                     │3.83      │3    │8.0       │
├────────────────────────────────────────────────────────────────────┼──────────┼─────┼──────────┤
│"Midnight in Paris"                                                 │4.75      │2    │7.7       │
├────────────────────────────────────────────────────────────────────┼──────────┼─────┼──────────┤
│"Departures (Okuribito)"                                            │4.5       │2    │8.1       │
├────────────────────────────────────────────────────────────────────┼──────────┼─────┼──────────┤
│"Mighty Aphrodite"                                                  │4.33      │2    │7.1       │
├────────────────────────────────────────────────────────────────────┼──────────┼─────┼──────────┤
│"Saving Private Ryan"                                               │4.25      │2    │8.6       │
├────────────────────────────────────────────────────────────────────┼──────────┼─────┼──────────┤
│"Monty Python and the Holy Grail"                                   │4.25      │2    │8.3       │
├────────────────────────────────────────────────────────────────────┼──────────┼─────┼──────────┤
│"Bullets Over Broadway"                                             │4.25      │2    │7.5       │
├────────────────────────────────────────────────────────────────────┼──────────┼─────┼──────────┤
│"Incredibles, The"                                                  │4.0       │2    │8.0       │
├────────────────────────────────────────────────────────────────────┼──────────┼─────┼──────────┤
│"Diving Bell and the Butterfly, The (Scaphandre et le papillon, Le)"│4.0       │2    │8.0       │
└────────────────────────────────────────────────────────────────────┴──────────┴─────┴──────────┘

MATCH(darlene:User{name:"Darlene Garcia"}) -[r:RATED] -(m) -[:IN_GENRE] ->(genre:Genre)
WITH darlene, genre, AVG(r.rating) AS darleneAvgRating 
CALL { WITH darlene, darleneAvgRating,genre
      MATCH (darlene)-[:PEER] - (peer:User) - [rate:RATED] ->(m:Movie) -[:IN_GENRE] ->(g:Genre)
      WHERE 1.0*rate.rating/darleneAvgRating > 1.25 
        AND g = genre
      RETURN  m, rate, peer 
      ORDER BY  peer.score   DESC,  // peer similarity -- most similar peers first
                rate.rating  DESC   // peer rating     -- then their ratings
              }
WITH * 
WHERE NOT (darlene)-[:RATED] -(m)
RETURN  m.title              AS title,  
   ROUND(AVG(rate.rating),2) AS peerRating, // average peer rating
   COUNT(DISTINCT peer) AS votes,           // votes
   m.imdbRating         AS imdbRating       // imdbRating as is
ORDER BY peerRating * votes DESC            // measure of film quality
LIMIT 10;

╒════════════════════════════════════╤══════════╤═════╤══════════╕
│title                               │peerRating│votes│imdbRating│
╞════════════════════════════════════╪══════════╪═════╪══════════╡
│"Star Wars: Episode IV - A New Hope"│4.0       │3    │8.7       │
├────────────────────────────────────┼──────────┼─────┼──────────┤
│"Midnight in Paris"                 │4.75      │2    │7.7       │
├────────────────────────────────────┼──────────┼─────┼──────────┤
│"Mighty Aphrodite"                  │4.6       │2    │7.1       │
├────────────────────────────────────┼──────────┼─────┼──────────┤
│"Departures (Okuribito)"            │4.5       │2    │8.1       │
├────────────────────────────────────┼──────────┼─────┼──────────┤
│"Monty Python and the Holy Grail"   │4.38      │2    │8.3       │
├────────────────────────────────────┼──────────┼─────┼──────────┤
│"Finding Nemo"                      │4.0       │2    │8.1       │
├────────────────────────────────────┼──────────┼─────┼──────────┤
│"East-West (Est-ouest)"             │5.0       │1    │7.5       │
├────────────────────────────────────┼──────────┼─────┼──────────┤
│"Breaker Morant"                    │5.0       │1    │7.9       │
├────────────────────────────────────┼──────────┼─────┼──────────┤
│"Saving Private Ryan"               │5.0       │1    │8.6       │
├────────────────────────────────────┼──────────┼─────┼──────────┤
│"Bucket List, The"                  │5.0       │1    │7.4       │
└────────────────────────────────────┴──────────┴─────┴──────────┘

MATCH (darlene:User{name:"Darlene Garcia"})
CALL { WITH darlene 
      MATCH (darlene) -[a:RATED] -(gm)
      RETURN AVG(a.rating) AS darleneGlobalRating 
     }
MATCH(darlene) -[r:RATED] -(m) -[:IN_GENRE] ->(genre:Genre)
WITH darlene, genre, darleneGlobalRating, AVG(r.rating) AS darleneAvgRating 
WHERE darleneAvgRating > darleneGlobalRating
CALL { WITH darlene, darleneAvgRating, genre
      MATCH (darlene)-[:PEER] ->(peer:User) - [rate:RATED] ->(m:Movie) 
                   -[:IN_GENRE] ->(g:Genre)
      WHERE 1.0*rate.rating/darleneAvgRating > 1.25 
        AND g = genre
      RETURN  m, rate, peer, genre as peerGenre
      ORDER BY  peer.score   DESC,  // peer similarity -- most similar peers first
                rate.rating  DESC   // peer rating     -- then their ratings
     }
WITH * 
WHERE NOT (darlene)-[:RATED] -(m)
RETURN  m.title              AS title,  
   ROUND(AVG(rate.rating),2) AS peerRating, // average peer rating
   COUNT(DISTINCT peer) AS votes,           // votes
   m.imdbRating         AS imdbRating,      // imdbRating as is
   collect(DISTINCT peerGenre.name) as genres // list of genres matching criteria
ORDER BY peerRating * votes DESC            // measure of film quality
LIMIT 10;

╒═══════════════════════════════╤══════════╤═════╤══════════╤══════════════════╕
│title                          │peerRating│votes│imdbRating│genres            │
╞═══════════════════════════════╪══════════╪═════╪══════════╪══════════════════╡
│"Departures (Okuribito)"       │4.5       │2    │8.1       │["Drama"]         │
├───────────────────────────────┼──────────┼─────┼──────────┼──────────────────┤
│"Breaker Morant"               │5.0       │1    │7.9       │["Drama", "War"]  │
├───────────────────────────────┼──────────┼─────┼──────────┼──────────────────┤
│"Papillon"                     │5.0       │1    │8.0       │["Drama", "Crime"]│
├───────────────────────────────┼──────────┼─────┼──────────┼──────────────────┤
│"Bucket List, The"             │5.0       │1    │7.4       │["Drama"]         │
├───────────────────────────────┼──────────┼─────┼──────────┼──────────────────┤
│"Mighty Aphrodite"             │5.0       │1    │7.1       │["Drama"]         │
├───────────────────────────────┼──────────┼─────┼──────────┼──────────────────┤
│"East-West (Est-ouest)"        │5.0       │1    │7.5       │["Drama"]         │
├───────────────────────────────┼──────────┼─────┼──────────┼──────────────────┤
│"Saving Private Ryan"          │5.0       │1    │8.6       │["Drama", "War"]  │
├───────────────────────────────┼──────────┼─────┼──────────┼──────────────────┤
│"Mr. Holland's Opus"           │5.0       │1    │7.3       │["Drama"]         │
├───────────────────────────────┼──────────┼─────┼──────────┼──────────────────┤
│"Mrs. Palfrey at the Claremont"│4.5       │1    │7.6       │["Drama"]         │
├───────────────────────────────┼──────────┼─────┼──────────┼──────────────────┤
│"Barney's Version"             │4.5       │1    │7.3       │["Drama"]         │
└───────────────────────────────┴──────────┴─────┴──────────┴──────────────────┘