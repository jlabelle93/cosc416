// Step 1: Split Darlene’s movies into two sets. 
//     Add an attribute "dataset" first that will be 
//     used to add labels to Movie nodes
MATCH(u:User) -[r:RATED] -> (m:Movie)
WHERE u.name = "Darlene Garcia"
SET m.dataset =  CASE WHEN rand() < 0.8 THEN "Train"
                      ELSE "Validation" END
RETURN m.title, m.dataset ;

// Step 2: Add Validation label (to use by Native GDS projection)
MATCH(u:User) -[r:RATED] -(m:Movie)
WHERE u.name = "Darlene Garcia" AND m.dataset = "Validation" 
SET m:Validation;   

// Step 3: All other movies go into Train set (to use by GDS projection)
MATCH(u:User) -[r:RATED] -(m:Movie)
WHERE  m.dataset is NULL OR m.dataset <> "Validation"
SET m:Train;

// Step 1: Create Projection for Peers identification
CALL gds.graph.project("PeersTrain", 
  ["Train", 'User'], 
  {RATED:{orientation: "UNDIRECTED"}}
) YIELD *;

╒══════════════════════════════════════════════════════════════════════╤══════════════════════════════════════════════════════════════════════╤════════════╤═════════╤═════════════════╤═════════════╕
│nodeProjection                                                        │relationshipProjection                                                │graphName   │nodeCount│relationshipCount│projectMillis│
╞══════════════════════════════════════════════════════════════════════╪══════════════════════════════════════════════════════════════════════╪════════════╪═════════╪═════════════════╪═════════════╡
│{User: {label: "User", properties: {}}, Train: {label: "Train", proper│{RATED: {aggregation: "DEFAULT", orientation: "UNDIRECTED", indexInver│"PeersTrain"│9241     │178926           │63           │
│ties: {}}}                                                            │se: false, properties: {}, type: "RATED"}}                            │            │         │                 │             │
└──────────────────────────────────────────────────────────────────────┴──────────────────────────────────────────────────────────────────────┴────────────┴─────────┴─────────────────┴─────────────┘

CALL gds.fastRP.mutate (
     'PeersTrain', 
    { embeddingDimension:64, 
      IterationWeights: [0.0,1.0,1.0,1.0], 
      randomSeed:7474,     
      mutateProperty: 'embedding'
    }) YIELD *;

╒═════════════════════╤════════════╤═════════╤═══════════════════╤═════════════╤══════════════════════════════════════════════════════════════════════╕
│nodePropertiesWritten│mutateMillis│nodeCount│preProcessingMillis│computeMillis│configuration                                                         │
╞═════════════════════╪════════════╪═════════╪═══════════════════╪═════════════╪══════════════════════════════════════════════════════════════════════╡
│9241                 │0           │9241     │0                  │62           │{randomSeed: 7474, mutateProperty: "embedding", jobId: "deaaee50-e67d-│
│                     │            │         │                   │             │4fa2-894c-730990f9c3ad", propertyRatio: 0.0, nodeSelfInfluence: 0, sud│
│                     │            │         │                   │             │o: false, iterationWeights: [0.0, 1.0, 1.0, 1.0], normalizationStrengt│
│                     │            │         │                   │             │h: 0.0, featureProperties: [], logProgress: true, nodeLabels: ["*"], c│
│                     │            │         │                   │             │oncurrency: 4, relationshipTypes: ["*"], embeddingDimension: 64}      │
└─────────────────────┴────────────┴─────────┴───────────────────┴─────────────┴──────────────────────────────────────────────────────────────────────┘

CALL gds.knn.write("PeersTrain", 
     { nodeLabels:["User"],  
     nodeProperties:"embedding", topK:50,
     writeRelationshipType: "PEER_TRAIN",
     writeProperty: "score", 
     randomSeed: 42,     
     concurrency: 1
     })
YIELD *;

╒═════════════╤═══════════╤═══════════════════╤═══════════════════╤═════════════╤═══════════╤════════════════════╤═════════════╤════════════════════╤══════════════════════════════════════════════════════════════════════╤══════════════════════════════════════════════════════════════════════╕
│ranIterations│didConverge│nodePairsConsidered│preProcessingMillis│computeMillis│writeMillis│postProcessingMillis│nodesCompared│relationshipsWritten│similarityDistribution                                                │configuration                                                         │
╞═════════════╪═══════════╪═══════════════════╪═══════════════════╪═════════════╪═══════════╪════════════════════╪═════════════╪════════════════════╪══════════════════════════════════════════════════════════════════════╪══════════════════════════════════════════════════════════════════════╡
│3            │true       │3328869            │0                  │698          │882        │0                   │669          │33450               │{min: 0.7967033386230469, p5: 0.9449729919433594, max: 0.9988555908203│{writeProperty: "score", writeRelationshipType: "PEER_TRAIN", randomSe│
│             │           │                   │                   │             │           │                    │             │                    │125, p99: 0.9963607788085938, p1: 0.9147796630859375, p10: 0.954807281│ed: 42, jobId: "857160d9-c4f8-4ec4-b361-1c1e99af7146", deltaThreshold:│
│             │           │                   │                   │             │           │                    │             │                    │4941406, p90: 0.9908294677734375, p50: 0.9788055419921875, p25: 0.9692│ 0.001, topK: 50, similarityCutoff: 0.0, perturbationRate: 0.0, sudo: │
│             │           │                   │                   │             │           │                    │             │                    │039489746094, p75: 0.9862327575683594, p95: 0.9930229187011719, mean: │false, maxIterations: 100, writeConcurrency: 1, sampleRate: 0.5, initi│
│             │           │                   │                   │             │           │                    │             │                    │0.9749599208176047, p100: 0.9988555908203125, stdDev: 0.01837469435842│alSampler: "UNIFORM", nodeProperties: {embedding: "COSINE"}, logProgre│
│             │           │                   │                   │             │           │                    │             │                    │4207}                                                                 │ss: true, nodeLabels: ["User"], randomJoins: 10, concurrency: 1, relat│
│             │           │                   │                   │             │           │                    │             │                    │                                                                      │ionshipTypes: ["*"]}                                                  │
└─────────────┴───────────┴───────────────────┴───────────────────┴─────────────┴───────────┴────────────────────┴─────────────┴────────────────────┴──────────────────────────────────────────────────────────────────────┴──────────────────────────────────────────────────────────────────────┘


MATCH(darlene:User{name:"Darlene Garcia"})
CALL { WITH darlene 
      MATCH (darlene)-[:PEER_TRAIN] // Peers defined by the TRAIN set only
          - (peer:User) - [rate:RATED] ->(m:Movie)
      RETURN  m, rate, peer 
      ORDER BY  peer.score   DESC,  // peer similarity -- most similar peers first
                rate.rating  DESC   // peer rating     -- then their ratings
              }
WITH m, // movies recommended by peers
   ROUND(AVG(rate.rating),2) AS peerRating, // average peer rating
   COUNT(DISTINCT peer) AS votes,           // votes
   m.imdbRating         AS imdbRating       // imdbRating as is
ORDER BY peerRating * votes DESC            // measure of film quality (score)
WITH COLLECT(ID(m)) as recommendation       // collect all recommendations ordered by score
CALL {match(mt:Validation) return collect(ID(mt)) as validation } // validation set
RETURN size(recommendation) AS sizeof_rec ,
       size(validation)     AS sizeof_val, 
    ROUND(gds.similarity.jaccard(recommendation[0..9], validation),4) 
      AS quality_10,
    ROUND(gds.similarity.jaccard(recommendation[0..19], validation),4) 
      AS quality_20, 
    ROUND(gds.similarity.jaccard(recommendation[0..29], validation),4) 
      AS quality_30,
    ROUND(gds.similarity.jaccard(recommendation[0..39], validation),4) 
      AS quality_40,
    ROUND(gds.similarity.jaccard(recommendation[0..49], validation),4) 
      AS quality_50;

╒══════════╤══════════╤══════════╤══════════╤══════════╤══════════╤══════════╕
│sizeof_rec│sizeof_val│quality_10│quality_20│quality_30│quality_40│quality_50│
╞══════════╪══════════╪══════════╪══════════╪══════════╪══════════╪══════════╡
│3774      │494       │0.004     │0.0079    │0.0116    │0.0133    │0.0207    │
└──────────┴──────────┴──────────┴──────────┴──────────┴──────────┴──────────┘

MATCH(darlene:User{name:"Darlene Garcia"}) -[r:RATED] -()
WITH darlene, AVG(r.rating) AS darleneAvgRating
CALL { WITH darlene, darleneAvgRating
      MATCH (darlene)-[:PEER_TRAIN]  // Peers defined by the TRAIN set only
        -(peer:User) - [rate:RATED] ->(m:Movie)
      WHERE rate.rating >  darleneAvgRating
      RETURN  m, rate, peer 
      ORDER BY  peer.score   DESC,  // peer similarity -- most similar peers first
                rate.rating  DESC   // peer rating     -- then their ratings
              }
WITH m,                                     // movies recommended by peers 
   ROUND(AVG(rate.rating),2) AS peerRating, // average peer rating
   COUNT(DISTINCT peer) AS votes,           // votes
   m.imdbRating         AS imdbRating       // imdbRating as is
ORDER BY peerRating * votes DESC            // measure of film quality
WITH COLLECT(ID(m)) as recommendation       // collect all recommendations ordered by score
CALL {match(mt:Validation) return collect(ID(mt)) as validation } // validation set
RETURN size(recommendation) AS sizeof_rec ,
       size(validation)     AS sizeof_val, 
    ROUND(gds.similarity.jaccard(recommendation[0..9], validation),4) 
      AS quality_10,
    ROUND(gds.similarity.jaccard(recommendation[0..19], validation),4) 
      AS quality_20, 
    ROUND(gds.similarity.jaccard(recommendation[0..29], validation),4) 
      AS quality_30,
    ROUND(gds.similarity.jaccard(recommendation[0..39], validation),4) 
      AS quality_40,
    ROUND(gds.similarity.jaccard(recommendation[0..49], validation),4) 
      AS quality_50;

╒══════════╤══════════╤══════════╤══════════╤══════════╤══════════╤══════════╕
│sizeof_rec│sizeof_val│quality_10│quality_20│quality_30│quality_40│quality_50│
╞══════════╪══════════╪══════════╪══════════╪══════════╪══════════╪══════════╡
│2713      │494       │0.004     │0.0079    │0.0097    │0.0152    │0.0207    │
└──────────┴──────────┴──────────┴──────────┴──────────┴──────────┴──────────┘

MATCH(darlene:User{name:"Darlene Garcia"}) -[r:RATED] -(m) -[:IN_GENRE] ->(genre:Genre)
WITH darlene, genre, AVG(r.rating) AS darleneAvgRating 
CALL { WITH darlene, darleneAvgRating,genre
      MATCH (darlene)-[:PEER_TRAIN]  // Peers defined by the TRAIN set only
        - (peer:User) - [rate:RATED] ->(m:Movie) -[:IN_GENRE] ->(g:Genre)
      WHERE 1.0*rate.rating/darleneAvgRating > 1.25 
        AND g = genre
      RETURN  m, rate, peer 
      ORDER BY  peer.score   DESC,  // peer similarity -- most similar peers first
                rate.rating  DESC   // peer rating     -- then their ratings
              }
WITH m,                                     // movies recommended by peers 
   ROUND(AVG(rate.rating),2) AS peerRating, // average peer rating
   COUNT(DISTINCT peer) AS votes,           // votes
   m.imdbRating         AS imdbRating       // imdbRating as is
ORDER BY peerRating * votes DESC            // measure of film quality
WITH COLLECT(ID(m)) as recommendation       // collect all recommendations ordered by score
CALL {match(mt:Validation) return collect(ID(mt)) as validation } // validation set
RETURN size(recommendation) AS sizeof_rec ,
       size(validation)     AS sizeof_val, 
    ROUND(gds.similarity.jaccard(recommendation[0..9], validation),4) 
      AS quality_10,
    ROUND(gds.similarity.jaccard(recommendation[0..19], validation),4) 
      AS quality_20, 
    ROUND(gds.similarity.jaccard(recommendation[0..29], validation),4) 
      AS quality_30,
    ROUND(gds.similarity.jaccard(recommendation[0..39], validation),4) 
      AS quality_40,
    ROUND(gds.similarity.jaccard(recommendation[0..49], validation),4) 
      AS quality_50;

╒══════════╤══════════╤══════════╤══════════╤══════════╤══════════╤══════════╕
│sizeof_rec│sizeof_val│quality_10│quality_20│quality_30│quality_40│quality_50│
╞══════════╪══════════╪══════════╪══════════╪══════════╪══════════╪══════════╡
│1796      │494       │0.004     │0.0079    │0.0136    │0.0133    │0.0188    │
└──────────┴──────────┴──────────┴──────────┴──────────┴──────────┴──────────┘

MATCH (darlene:User{name:"Darlene Garcia"})
CALL { WITH darlene 
      MATCH (darlene) -[a:RATED] -(gm)
      RETURN AVG(a.rating) AS darleneGlobalRating 
     }
MATCH(darlene) -[r:RATED] -(m) -[:IN_GENRE] ->(genre:Genre)
WITH darlene, genre, darleneGlobalRating, AVG(r.rating) AS darleneAvgRating 
WHERE darleneAvgRating > darleneGlobalRating
CALL { WITH darlene, darleneAvgRating, genre
      MATCH (darlene)-[:PEER_TRAIN]  // Peers defined by the TRAIN set only
            -(peer:User) - [rate:RATED] ->(m:Movie) 
                   -[:IN_GENRE] ->(g:Genre)
      WHERE 1.0*rate.rating/darleneAvgRating > 1.25 
        AND g = genre
      RETURN  m, rate, peer, genre as peerGenre
      ORDER BY  peer.score   DESC,  // peer similarity -- most similar peers first
                rate.rating  DESC   // peer rating     -- then their ratings
     }
WITH m,                                     // movies recommended by peers 
   ROUND(AVG(rate.rating),2) AS peerRating, // average peer rating
   COUNT(DISTINCT peer) AS votes,           // votes
   m.imdbRating         AS imdbRating,      // imdbRating as is
   collect(DISTINCT peerGenre.name) as genres // list of genres matching criteria
ORDER BY peerRating * votes DESC            // measure of film quality
WITH COLLECT(ID(m)) as recommendation       // collect all recommendations ordered by score
CALL {match(mt:Validation) return collect(ID(mt)) as validation } // validation set
RETURN size(recommendation) AS sizeof_rec ,
       size(validation)     AS sizeof_val, 
    ROUND(gds.similarity.jaccard(recommendation[0..9], validation),4) 
      AS quality_10,
    ROUND(gds.similarity.jaccard(recommendation[0..19], validation),4) 
      AS quality_20, 
    ROUND(gds.similarity.jaccard(recommendation[0..29], validation),4) 
      AS quality_30,
    ROUND(gds.similarity.jaccard(recommendation[0..39], validation),4) 
      AS quality_40,
    ROUND(gds.similarity.jaccard(recommendation[0..49], validation),4) 
      AS quality_50;

╒══════════╤══════════╤══════════╤══════════╤══════════╤══════════╤══════════╕
│sizeof_rec│sizeof_val│quality_10│quality_20│quality_30│quality_40│quality_50│
╞══════════╪══════════╪══════════╪══════════╪══════════╪══════════╪══════════╡
│1035      │494       │0.004     │0.0039    │0.0077    │0.0114    │0.015     │
└──────────┴──────────┴──────────┴──────────┴──────────┴──────────┴──────────┘


