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