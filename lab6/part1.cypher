CALL gds.graph.project("Peers", 
  ['Movie', 'User'], 
  { RATED:{orientation: "UNDIRECTED"}}
)
YIELD *;

╒══════════════════════════════════════════════════════════════════════╤══════════════════════════════════════════════════════════════════════╤═════════╤═════════╤═════════════════╤═════════════╕
│nodeProjection                                                        │relationshipProjection                                                │graphName│nodeCount│relationshipCount│projectMillis│
╞══════════════════════════════════════════════════════════════════════╪══════════════════════════════════════════════════════════════════════╪═════════╪═════════╪═════════════════╪═════════════╡
│{User: {label: "User", properties: {}}, Movie: {label: "Movie", proper│{RATED: {aggregation: "DEFAULT", orientation: "UNDIRECTED", indexInver│"Peers"  │9794     │200008           │114          │
│ties: {}}}                                                            │se: false, properties: {}, type: "RATED"}}                            │         │         │                 │             │
└──────────────────────────────────────────────────────────────────────┴──────────────────────────────────────────────────────────────────────┴─────────┴─────────┴─────────────────┴─────────────┘

call gds.graph.list 
      yield degreeDistribution, graphName, memoryUsage,
      sizeInBytes, nodeCount, relationshipCount, 
      density, schemaWithOrientation;

╒══════════════════════════════════════════════════════════════════════╤═════════╤═══════════╤═══════════╤═════════╤═════════════════╤═════════════════════╤══════════════════════════════════════════════════════════════════════╕
│degreeDistribution                                                    │graphName│memoryUsage│sizeInBytes│nodeCount│relationshipCount│density              │schemaWithOrientation                                                 │
╞══════════════════════════════════════════════════════════════════════╪═════════╪═══════════╪═══════════╪═════════╪═════════════════╪═════════════════════╪══════════════════════════════════════════════════════════════════════╡
│{min: 0, max: 2391, p90: 45, p999: 1011, p99: 274, p50: 3, p75: 13, p9│"Peers"  │"2852 KiB" │2920738    │9794     │200008           │0.0020853142591984904│{graphProperties: {}, nodes: {User: {}, Movie: {}}, relationships: {RA│
│5: 85, mean: 20.421482540330814}                                      │         │           │           │         │                 │                     │TED: {direction: "UNDIRECTED", properties: {}}}}                      │
└──────────────────────────────────────────────────────────────────────┴─────────┴───────────┴───────────┴─────────┴─────────────────┴─────────────────────┴──────────────────────────────────────────────────────────────────────┘

CALL gds.fastRP.mutate (
     "Peers", 
    { embeddingDimension:64, 
      IterationWeights: [0.0,1.0,1.0,1.0,1.0], 
      randomSeed:7474, // for reproducibility 
      mutateProperty: "embedding" // property name
    }) YIELD *;

╒═════════════════════╤════════════╤═════════╤═══════════════════╤═════════════╤══════════════════════════════════════════════════════════════════════╕
│nodePropertiesWritten│mutateMillis│nodeCount│preProcessingMillis│computeMillis│configuration                                                         │
╞═════════════════════╪════════════╪═════════╪═══════════════════╪═════════════╪══════════════════════════════════════════════════════════════════════╡
│9794                 │0           │9794     │0                  │59           │{randomSeed: 7474, mutateProperty: "embedding", jobId: "8f8e7b15-92b3-│
│                     │            │         │                   │             │463c-9860-70540966face", propertyRatio: 0.0, nodeSelfInfluence: 0, sud│
│                     │            │         │                   │             │o: false, iterationWeights: [0.0, 1.0, 1.0, 1.0, 1.0], normalizationSt│
│                     │            │         │                   │             │rength: 0.0, featureProperties: [], logProgress: true, nodeLabels: ["*│
│                     │            │         │                   │             │"], concurrency: 4, relationshipTypes: ["*"], embeddingDimension: 64} │
└─────────────────────┴────────────┴─────────┴───────────────────┴─────────────┴──────────────────────────────────────────────────────────────────────┘

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

╒═════════════╤═══════════╤═══════════════════╤═══════════════════╤═════════════╤═══════════╤════════════════════╤═════════════╤════════════════════╤══════════════════════════════════════════════════════════════════════╤══════════════════════════════════════════════════════════════════════╕
│ranIterations│didConverge│nodePairsConsidered│preProcessingMillis│computeMillis│writeMillis│postProcessingMillis│nodesCompared│relationshipsWritten│similarityDistribution                                                │configuration                                                         │
╞═════════════╪═══════════╪═══════════════════╪═══════════════════╪═════════════╪═══════════╪════════════════════╪═════════════╪════════════════════╪══════════════════════════════════════════════════════════════════════╪══════════════════════════════════════════════════════════════════════╡
│10           │true       │176115             │0                  │48           │270        │0                   │669          │3345                │{min: 0.8881340026855469, p5: 0.9739913940429688, max: 0.9992866516113│{writeProperty: "score", writeRelationshipType: "PEER", randomSeed: 42│
│             │           │                   │                   │             │           │                    │             │                    │281, p99: 0.9988136291503906, p1: 0.9547805786132812, p10: 0.979869842│, jobId: "46a4bdda-9a7d-4431-8a87-4947221d061f", deltaThreshold: 0.001│
│             │           │                   │                   │             │           │                    │             │                    │5292969, p90: 0.9966468811035156, p50: 0.9916648864746094, p25: 0.9874│, topK: 5, similarityCutoff: 0.0, perturbationRate: 0.0, sudo: false, │
│             │           │                   │                   │             │           │                    │             │                    │8779296875, p75: 0.9946708679199219, p95: 0.9978141784667969, mean: 0.│maxIterations: 100, writeConcurrency: 1, sampleRate: 0.9, initialSampl│
│             │           │                   │                   │             │           │                    │             │                    │9892653666269619, p100: 0.9992866516113281, stdDev: 0.0101895023296966│er: "UNIFORM", nodeProperties: {embedding: "COSINE"}, logProgress: tru│
│             │           │                   │                   │             │           │                    │             │                    │84}                                                                   │e, nodeLabels: ["User"], randomJoins: 10, concurrency: 1, relationship│
│             │           │                   │                   │             │           │                    │             │                    │                                                                      │Types: ["*"]}                                                         │
└─────────────┴───────────┴───────────────────┴───────────────────┴─────────────┴───────────┴────────────────────┴─────────────┴────────────────────┴──────────────────────────────────────────────────────────────────────┴──────────────────────────────────────────────────────────────────────┘

MATCH (darlene:User where darlene.name IN ["Darlene Garcia"])-[p:PEER] -(o) 
RETURN *;
╒════════════════════════════════╤════════════════════════════════════╤═══════════════════════════════════╕
│darlene                         │o                                   │p                                  │
╞════════════════════════════════╪════════════════════════════════════╪═══════════════════════════════════╡
│(:User {name: "Darlene Garcia"})│(:User {name: "Robin Pierce"})      │[:PEER {score: 0.9674363136291504}]│
├────────────────────────────────┼────────────────────────────────────┼───────────────────────────────────┤
│(:User {name: "Darlene Garcia"})│(:User {name: "Derrick Collier"})   │[:PEER {score: 0.9639710187911987}]│
├────────────────────────────────┼────────────────────────────────────┼───────────────────────────────────┤
│(:User {name: "Darlene Garcia"})│(:User {name: "Daniel Armstrong"})  │[:PEER {score: 0.9642564654350281}]│
├────────────────────────────────┼────────────────────────────────────┼───────────────────────────────────┤
│(:User {name: "Darlene Garcia"})│(:User {name: "Rachel Williams"})   │[:PEER {score: 0.9640225172042847}]│
├────────────────────────────────┼────────────────────────────────────┼───────────────────────────────────┤
│(:User {name: "Darlene Garcia"})│(:User {name: "Christopher Thomas"})│[:PEER {score: 0.9679588079452515}]│
└────────────────────────────────┴────────────────────────────────────┴───────────────────────────────────┘

MATCH (darlene:User where darlene.name IN ["Darlene Garcia", "Christopher Thomas"])-[p:PEER] -(o) return *;
╒════════════════════════════════════╤════════════════════════════════════╤═══════════════════════════════════╕
│darlene                             │o                                   │p                                  │
╞════════════════════════════════════╪════════════════════════════════════╪═══════════════════════════════════╡
│(:User {name: "Darlene Garcia"})    │(:User {name: "Robin Pierce"})      │[:PEER {score: 0.9674363136291504}]│
├────────────────────────────────────┼────────────────────────────────────┼───────────────────────────────────┤
│(:User {name: "Darlene Garcia"})    │(:User {name: "Derrick Collier"})   │[:PEER {score: 0.9639710187911987}]│
├────────────────────────────────────┼────────────────────────────────────┼───────────────────────────────────┤
│(:User {name: "Darlene Garcia"})    │(:User {name: "Daniel Armstrong"})  │[:PEER {score: 0.9642564654350281}]│
├────────────────────────────────────┼────────────────────────────────────┼───────────────────────────────────┤
│(:User {name: "Darlene Garcia"})    │(:User {name: "Rachel Williams"})   │[:PEER {score: 0.9640225172042847}]│
├────────────────────────────────────┼────────────────────────────────────┼───────────────────────────────────┤
│(:User {name: "Darlene Garcia"})    │(:User {name: "Christopher Thomas"})│[:PEER {score: 0.9679588079452515}]│
├────────────────────────────────────┼────────────────────────────────────┼───────────────────────────────────┤
│(:User {name: "Christopher Thomas"})│(:User {name: "James Harris"})      │[:PEER {score: 0.9811804890632629}]│
├────────────────────────────────────┼────────────────────────────────────┼───────────────────────────────────┤
│(:User {name: "Christopher Thomas"})│(:User {name: "Derrick Collier"})   │[:PEER {score: 0.9901443719863892}]│
├────────────────────────────────────┼────────────────────────────────────┼───────────────────────────────────┤
│(:User {name: "Christopher Thomas"})│(:User {name: "Darlene Garcia"})    │[:PEER {score: 0.9679588079452515}]│
├────────────────────────────────────┼────────────────────────────────────┼───────────────────────────────────┤
│(:User {name: "Christopher Thomas"})│(:User {name: "Clayton Lopez"})     │[:PEER {score: 0.9842787384986877}]│
├────────────────────────────────────┼────────────────────────────────────┼───────────────────────────────────┤
│(:User {name: "Christopher Thomas"})│(:User {name: "Julia Compton"})     │[:PEER {score: 0.9847290515899658}]│
├────────────────────────────────────┼────────────────────────────────────┼───────────────────────────────────┤
│(:User {name: "Christopher Thomas"})│(:User {name: "Valerie Jackson"})   │[:PEER {score: 0.9841831922531128}]│
├────────────────────────────────────┼────────────────────────────────────┼───────────────────────────────────┤
│(:User {name: "Christopher Thomas"})│(:User {name: "Derrick Collier"})   │[:PEER {score: 0.9901443719863892}]│
├────────────────────────────────────┼────────────────────────────────────┼───────────────────────────────────┤
│(:User {name: "Christopher Thomas"})│(:User {name: "Manuel Elliott"})    │[:PEER {score: 0.9832704067230225}]│
└────────────────────────────────────┴────────────────────────────────────┴───────────────────────────────────┘

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