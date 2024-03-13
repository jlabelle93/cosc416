
// Q1: How do the recommendations obtained in Part 1 and Part 2 differ?
// Part 1 recommendations
// Either Drama or Comedy
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
// Both Drama AND Comedy
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

// Part 2 Recommendations
// Either War or Film-Noir
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

// Q2: Discuss possible reasons for these differences.
// Interestingly there is one case of overlap between the two methods and that is the recommendation
// that Darlene watch Band of Brothers based on her preference for genres she's watched and her preference
// based on ratings given to genres. That being said, that seems to be the only overlap in a top 5 scenario.
// I think a big reason for the differences in the two parts is Darlene may watch many Drama and Comedy movies,
// but she tends to consistently rate movies in the War genre specifically higher than movies in the Drama genre.
// We can even demonstrate that with the following query:
MATCH (p:User{name: 'Darlene Garcia'})-[r:RATED]->(:Movie)-[:IN_GENRE]->(g:Genre)
WHERE g.name IN ['Drama', 'Comedy', 'War', 'Film-Noir']
RETURN g.name As Genre, round(avg(r.rating), 2) AS Rating
ORDER BY Rating DESC;

╒═══════════╤══════╕
│Genre      │Rating│
╞═══════════╪══════╡
│"War"      │3.9   │
├───────────┼──────┤
│"Film-Noir"│3.74  │
├───────────┼──────┤
│"Drama"    │3.45  │
├───────────┼──────┤
│"Comedy"   │3.13  │
└───────────┴──────┘

// We can make a guess that War films generally resonate more with Darlene than say, a Comedy. Whether this is due to
// consistencies or other qualifiers in the genres themselves, I can't say for certain.\

// Q3: What approach would work better in the real-life scenario? Why?
// In the real-life scenario, for this case specifically, I think accounting for ratings gives us a more accurate reflection
// of recommendations we can make to Darlene based on her preferences. Ideally, we would be able to loop Film-Noir into the 
// list of recommendations as well but there is no overlap between War and Film-Noir (at least that Darlene has not seen). While
// ratings are a very subjective metric, it is easier to determine how a user might "feel" about movies they watch instead of solely
// relying on the number of movies in a particular genre they have consumed. I feel like using the ratings method also avoids some of the
// bias that might be at play due to the prevalence of Drama films. It is, however, not a perfect method.

// Q4: Come up with a better way to create recommendations by combining both methods.


// Q5: Merge Cypher queries of Part 1 and Part 2 to create the final list of recommendations
