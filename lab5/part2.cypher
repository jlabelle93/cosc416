MATCH (p:User)-[r:RATED]->(m:Movie)<-[r2:RATED]-(d:User {name:'Darlene Garcia'})
WITH p, collect(m.movieId) AS common, collect(r.rating) AS pRatings, collect(r2.rating) AS dRatings
WHERE p.name <> 'Darlene Garcia'
WITH p, common, pRatings, dRatings
MATCH (p)-[:RATED]-(m:Movie)
WITH p, common, collect(m.movieId) AS pWatched, pRatings, dRatings
WHERE size(common) > 50
RETURN p.name AS Peer, size(pWatched) AS peerWatched, size(common) AS common, round(gds.similarity.jaccard(pWatched, common), 4) AS jaccard, round(gds.similarity.cosine(pRatings, dRatings), 4) AS cosine, round(gds.similarity.pearson(pRatings, dRatings), 4) AS pearson, round(gds.similarity.euclidean(pRatings, dRatings), 4) AS euclidean, round(gds.similarity.euclideanDistance(pRatings, dRatings), 4) AS euclideanDist
ORDER BY euclidean DESC
LIMIT 10;

//Ranking by Euclidean Similarity
╒═════════════════╤═══════════╤══════╤═══════╤══════╤═══════╤═════════╤═════════════╕
│Peer             │peerWatched│common│jaccard│cosine│pearson│euclidean│euclideanDist│
╞═════════════════╪═══════════╪══════╪═══════╪══════╪═══════╪═════════╪═════════════╡
│"Michelle Harris"│111        │60    │0.5405 │0.9725│0.1587 │0.1141   │7.7621       │
├─────────────────┼───────────┼──────┼───────┼──────┼───────┼─────────┼─────────────┤
│"Kristina Foster"│116        │56    │0.4828 │0.959 │0.4899 │0.1089   │8.1854       │
├─────────────────┼───────────┼──────┼───────┼──────┼───────┼─────────┼─────────────┤
│"Holly Lopez"    │82         │60    │0.7317 │0.9563│0.2299 │0.1045   │8.5732       │
├─────────────────┼───────────┼──────┼───────┼──────┼───────┼─────────┼─────────────┤
│"Charles Banks"  │82         │60    │0.7317 │0.9649│0.4031 │0.1038   │8.6313       │
├─────────────────┼───────────┼──────┼───────┼──────┼───────┼─────────┼─────────────┤
│"George Mcmillan"│141        │61    │0.4326 │0.9573│0.4891 │0.1032   │8.6891       │
├─────────────────┼───────────┼──────┼───────┼──────┼───────┼─────────┼─────────────┤
│"Daniel Lester"  │116        │55    │0.4741 │0.9499│0.1244 │0.1025   │8.7607       │
├─────────────────┼───────────┼──────┼───────┼──────┼───────┼─────────┼─────────────┤
│"Ruth Patterson" │82         │55    │0.6707 │0.9549│0.2428 │0.1019   │8.8176       │
├─────────────────┼───────────┼──────┼───────┼──────┼───────┼─────────┼─────────────┤
│"Amanda Pearson" │106        │51    │0.4811 │0.9466│-0.062 │0.1006   │8.9443       │
├─────────────────┼───────────┼──────┼───────┼──────┼───────┼─────────┼─────────────┤
│"Amber Thompson" │99         │57    │0.5758 │0.9692│0.1531 │0.1006   │8.9443       │
├─────────────────┼───────────┼──────┼───────┼──────┼───────┼─────────┼─────────────┤
│"Randy Blake"    │76         │62    │0.8158 │0.9663│0.0178 │0.0997   │9.0277       │
└─────────────────┴───────────┴──────┴───────┴──────┴───────┴─────────┴─────────────┘

MATCH (p:User)-[:RATED]->(m:Movie)
WHERE p.name <> 'Darlene Garcia'
WITH p AS peer, collect(m.movieId) AS peerMovies
MATCH (d:User {name: 'Darlene Garcia'})-[:RATED]->(m2:Movie)
WITH peer, peerMovies, collect(m2.movieId) AS darleneMovies
WITH peer, apoc.coll.subtract(peerMovies, darleneMovies) AS possRecommendations
WHERE peer.name IN ['Michelle Harris', 'Kristina Foster', 'Holly Lopez', 'Charles Banks', 'George Mcmillan', 'Daniel Lester', 'Ruth Patterson', 'Amanda Pearson', 'Amber Thompson', 'Randy Blake']
CALL {
    WITH peer, possRecommendations
    MATCH (m:Movie)
    WHERE m.movieId IN possRecommendations AND NOT m.imdbRating IS null 
    WITH peer, m, m.imdbRating AS rating ORDER BY rating DESC
    RETURN peer AS p, collect(m) AS top
}
WITH peer, p, top
UNWIND top AS peerTop
RETURN DISTINCT peerTop.title AS Recommendation, count(peerTop.title) AS Votes, peerTop.imdbRating AS imdbRating
ORDER BY imdbRating DESC
LIMIT 5;

╒════════════════════════════════════════════════╤═════╤══════════╕
│Recommendation                                  │Votes│imdbRating│
╞════════════════════════════════════════════════╪═════╪══════════╡
│"Decalogue, The (Dekalog)"                      │1    │9.2       │
├────────────────────────────────────────────────┼─────┼──────────┤
│"Lord of the Rings: The Return of the King, The"│5    │8.9       │
├────────────────────────────────────────────────┼─────┼──────────┤
│"Battlestar Galactica"                          │1    │8.7       │
├────────────────────────────────────────────────┼─────┼──────────┤
│"Lord of the Rings: The Two Towers, The"        │5    │8.7       │
├────────────────────────────────────────────────┼─────┼──────────┤
│"Star Wars: Episode IV - A New Hope"            │5    │8.7       │
└────────────────────────────────────────────────┴─────┴──────────┘

//Ranking by Cosine Similarity
╒══════════════════╤═══════════╤══════╤═══════╤══════╤═══════╤═════════╤═════════════╕
│Peer              │peerWatched│common│jaccard│cosine│pearson│euclidean│euclideanDist│
╞══════════════════╪═══════════╪══════╪═══════╪══════╪═══════╪═════════╪═════════════╡
│"Michelle Harris" │111        │60    │0.5405 │0.9725│0.1587 │0.1141   │7.7621       │
├──────────────────┼───────────┼──────┼───────┼──────┼───────┼─────────┼─────────────┤
│"Mrs. Megan Davis"│224        │138   │0.6161 │0.9712│0.3875 │0.0788   │11.694       │
├──────────────────┼───────────┼──────┼───────┼──────┼───────┼─────────┼─────────────┤
│"Michael Simmons" │191        │121   │0.6335 │0.9711│0.3403 │0.085    │10.7703      │
├──────────────────┼───────────┼──────┼───────┼──────┼───────┼─────────┼─────────────┤
│"Sue Mason"       │504        │348   │0.6905 │0.9704│0.1877 │0.0508   │18.6815      │
├──────────────────┼───────────┼──────┼───────┼──────┼───────┼─────────┼─────────────┤
│"Amber Thompson"  │99         │57    │0.5758 │0.9692│0.1531 │0.1006   │8.9443       │
├──────────────────┼───────────┼──────┼───────┼──────┼───────┼─────────┼─────────────┤
│"Briana Lara"     │230        │173   │0.7522 │0.9678│0.2863 │0.0704   │13.2098      │
├──────────────────┼───────────┼──────┼───────┼──────┼───────┼─────────┼─────────────┤
│"Randy Blake"     │76         │62    │0.8158 │0.9663│0.0178 │0.0997   │9.0277       │
├──────────────────┼───────────┼──────┼───────┼──────┼───────┼─────────┼─────────────┤
│"Robert Jones"    │73         │64    │0.8767 │0.966 │0.0594 │0.0982   │9.1788       │
├──────────────────┼───────────┼──────┼───────┼──────┼───────┼─────────┼─────────────┤
│"Zachary Bowers"  │268        │162   │0.6045 │0.9656│0.0668 │0.0597   │15.748       │
├──────────────────┼───────────┼──────┼───────┼──────┼───────┼─────────┼─────────────┤
│"Alexis Lopez"    │145        │74    │0.5103 │0.9652│0.5401 │0.0992   │9.083        │
└──────────────────┴───────────┴──────┴───────┴──────┴───────┴─────────┴─────────────┘

MATCH (p:User)-[:RATED]->(m:Movie)
WHERE p.name <> 'Darlene Garcia'
WITH p AS peer, collect(m.movieId) AS peerMovies
MATCH (d:User {name: 'Darlene Garcia'})-[:RATED]->(m2:Movie)
WITH peer, peerMovies, collect(m2.movieId) AS darleneMovies
WITH peer, apoc.coll.subtract(peerMovies, darleneMovies) AS possRecommendations
WHERE peer.name IN ['Michelle Harris', 'Mrs. Megan Davis', 'Michael Simmons', 'Sue Mason', 'Amber Thompson', 'Briana Lara', 'Randy Blake', 'Robert Jones', 'Zachary Bowers', 'Alexis Lopez']
CALL {
    WITH peer, possRecommendations
    MATCH (m:Movie)
    WHERE m.movieId IN possRecommendations AND NOT m.imdbRating IS null 
    WITH peer, m, m.imdbRating AS rating ORDER BY rating DESC
    RETURN peer AS p, collect(m) AS top
}
WITH peer, p, top
UNWIND top AS peerTop
RETURN DISTINCT peerTop.title AS Recommendation, count(peerTop.title) AS Votes, peerTop.imdbRating AS imdbRating
ORDER BY imdbRating DESC
LIMIT 5;

╒════════════════════════════════════════════════╤═════╤══════════╕
│Recommendation                                  │Votes│imdbRating│
╞════════════════════════════════════════════════╪═════╪══════════╡
│"Band of Brothers"                              │2    │9.6       │
├────────────────────────────────────────────────┼─────┼──────────┤
│"Cosmos"                                        │1    │9.3       │
├────────────────────────────────────────────────┼─────┼──────────┤
│"Decalogue, The (Dekalog)"                      │1    │9.2       │
├────────────────────────────────────────────────┼─────┼──────────┤
│"Lord of the Rings: The Return of the King, The"│8    │8.9       │
├────────────────────────────────────────────────┼─────┼──────────┤
│"Lord of the Rings: The Two Towers, The"        │8    │8.7       │
└────────────────────────────────────────────────┴─────┴──────────┘

//Ranking by Pearson
╒══════════════════╤═══════════╤══════╤═══════╤══════╤═══════╤═════════╤═════════════╕
│Peer              │peerWatched│common│jaccard│cosine│pearson│euclidean│euclideanDist│
╞══════════════════╪═══════════╪══════╪═══════╪══════╪═══════╪═════════╪═════════════╡
│"Alexis Lopez"    │145        │74    │0.5103 │0.9652│0.5401 │0.0992   │9.083        │
├──────────────────┼───────────┼──────┼───────┼──────┼───────┼─────────┼─────────────┤
│"Kristina Foster" │116        │56    │0.4828 │0.959 │0.4899 │0.1089   │8.1854       │
├──────────────────┼───────────┼──────┼───────┼──────┼───────┼─────────┼─────────────┤
│"George Mcmillan" │141        │61    │0.4326 │0.9573│0.4891 │0.1032   │8.6891       │
├──────────────────┼───────────┼──────┼───────┼──────┼───────┼─────────┼─────────────┤
│"Cheryl Gordon"   │154        │98    │0.6364 │0.9583│0.4636 │0.083    │11.0454      │
├──────────────────┼───────────┼──────┼───────┼──────┼───────┼─────────┼─────────────┤
│"Rita Owens"      │1291       │678   │0.5252 │0.9627│0.424  │0.0324   │29.8915      │
├──────────────────┼───────────┼──────┼───────┼──────┼───────┼─────────┼─────────────┤
│"Charles Banks"   │82         │60    │0.7317 │0.9649│0.4031 │0.1038   │8.6313       │
├──────────────────┼───────────┼──────┼───────┼──────┼───────┼─────────┼─────────────┤
│"Cody Johnson"    │617        │329   │0.5332 │0.9374│0.3984 │0.0377   │25.5049      │
├──────────────────┼───────────┼──────┼───────┼──────┼───────┼─────────┼─────────────┤
│"Elizabeth Cantu" │99         │57    │0.5758 │0.9479│0.3949 │0.0952   │9.5          │
├──────────────────┼───────────┼──────┼───────┼──────┼───────┼─────────┼─────────────┤
│"Jonathan Booker" │148        │96    │0.6486 │0.9493│0.3934 │0.0764   │12.083       │
├──────────────────┼───────────┼──────┼───────┼──────┼───────┼─────────┼─────────────┤
│"Mrs. Megan Davis"│224        │138   │0.6161 │0.9712│0.3875 │0.0788   │11.694       │
└──────────────────┴───────────┴──────┴───────┴──────┴───────┴─────────┴─────────────┘
...
WHERE peer.name IN ['Alexis Lopez', 'Kristina Foster', 'George Mcmillan', 'Cheryl Gordon', 'Rita Owens', 'Charles Banks', 'Cody Johnson', 'Elizabeth Cantu', 'Jonathan Booker', 'Mrs. Megan Davis']
...
╒════════════════════════════════════════════════════════════════════╤═════╤══════════╕
│Recommendation                                                      │Votes│imdbRating│
╞════════════════════════════════════════════════════════════════════╪═════╪══════════╡
│"Buster Keaton: A Hard Act to Follow"                               │1    │8.9       │
├────────────────────────────────────────────────────────────────────┼─────┼──────────┤
│"Good, the Bad and the Ugly, The (Buono, il brutto, il cattivo, Il)"│1    │8.9       │
├────────────────────────────────────────────────────────────────────┼─────┼──────────┤
│"Lord of the Rings: The Return of the King, The"                    │5    │8.9       │
├────────────────────────────────────────────────────────────────────┼─────┼──────────┤
│"Berlin Alexanderplatz"                                             │1    │8.8       │
├────────────────────────────────────────────────────────────────────┼─────┼──────────┤
│"Lord of the Rings: The Two Towers, The"                            │5    │8.7       │
└────────────────────────────────────────────────────────────────────┴─────┴──────────┘