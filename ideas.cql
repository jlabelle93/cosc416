CREATE (:Person {name: "John Doe"});
CREATE (:Person {name: "Mary Doe"});
CREATE (:Person {name: "John Hoe"});
CREATE (:Person {name: "John Moe"});

MATCH (p:Person {name: "John Doe"}), (p2:Person {name: "Mary Doe"})
MERGE (p)-[:FRIEND_OF]->(p2);

MATCH (p:Person {name: "Mary Doe"}), (p2:Person {name: "John Hoe"})
MERGE (p)-[:FRIEND_OF]->(p2);

MATCH (p:Person {name: "Mary Doe"}), (p2:Person {name: "John Moe"})
MERGE (p)-[:FRIEND_OF]->(p2);

MATCH (:Person {name: "John Doe"})-[:FRIEND_OF*2]->(p:Person)
RETURN p;

///

