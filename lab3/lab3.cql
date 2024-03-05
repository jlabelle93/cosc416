// Schema
CREATE (Employee:Employee {employeeId: "", firstName: "", lastName: "", city: "", state: "", country: "", birthDate: "", hireDate: "", title: ""})-[:REPORTS_TO]->(Employee)-[:SUPPORTS]->(:Customer {customerId: "", firstName: "", lastName: "", city: "", state: "", country: ""})<-[:BILLED_TO]-(Invoice:Invoice {invoiceId: "", billingCity: "", billingState: "", billingCountry: "", total: ""}),
(:Genre {genreId: "", name: ""})<-[:TYPE_OF]-(Track:Track {trackId: "", name: "", composer: "", millisecond: "", bytes: "", unitPrice: ""})<-[:CONTAINS]-(:InvoiceLine {invoiceLineId: "", trackId: ""})-[:PART_OF]->(Invoice),
(Artist:Artist {artistId: "", name: ""})-[:RELEASES]->(:Album {albumId: "", title: ""})-[:MADE_UP_OF]->(Track)<-[:COMPOSES]-(:Composer {name: ""}),
(Artist)-[:PERFORMS]->(Track);

// Index Creation
CREATE INDEX artistId_idx
FOR (n:Artist)
ON (n.artistId);

CREATE INDEX albumId_idx
FOR (n:Album)
ON (n.albumId);

CREATE INDEX genreId_idx
FOR (g:Genre)
ON (g.genreId);

CREATE INDEX trackId_idx
FOR (n:Track)
ON (n.trackId);

CREATE INDEX employeeId_idx
FOR (e:Employee)
ON (e.employeeId);

CREATE INDEX customerId_idx
FOR (c:Customer)
ON (c.customerId);

CREATE INDEX invoiceId_idx
FOR (i:Invoice)
ON (i.invoiceId);

CREATE INDEX invoiceLineId_idx
FOR (i:InvoiceLine)
ON (i.invoiceLineId);

// Imports
LOAD CSV WITH HEADERS FROM 'file:///Artist.csv' AS ROW
CREATE (:Artist {artistId: toInteger(ROW.ArtistId), name: ROW.Name});

LOAD CSV WITH HEADERS FROM 'file:///Album.csv' AS ROW
MERGE (al:Album {albumId: toInteger(ROW.AlbumId), title: ROW.Title})
WITH al, toInteger(ROW.ArtistId) AS artistId
MATCH (art:Artist {artistId: artistId})
MERGE (al)<-[:RELEASES]-(art);

LOAD CSV WITH HEADERS FROM'file:///Genre.csv' AS ROW
CREATE (g:Genre {genreId: toInteger(ROW.GenreId), name: ROW.Name});

LOAD CSV WITH HEADERS FROM 'file:///Track.csv' AS ROW 
CREATE (t:Track {trackId: toInteger(ROW.TrackId), name: ROW.Name, composer: ROW.Composer, millisecond: toFloat(ROW.Milliseconds), bytes: toInteger(ROW.Bytes), unitPrice: toFloat(ROW.UnitPrice)})
WITH t, toInteger(ROW.AlbumId) AS albumId, toInteger(ROW.GenreId) AS genreId, ROW.Composer AS composers
MATCH (al:Album {albumId: albumId}), (g:Genre {genreId: genreId})
MERGE (g)<-[:TYPE_OF]-(t)<-[:MADE_UP_OF]-(al)
WITH t, composers WHERE NOT composers IS NULL
WITH t, apoc.text.split(composers, '[,\/;\&]| and | - ')AS composerList
CALL {
    WITH t, composerList
    UNWIND [composerList] AS c
    MERGE (t)<-[:COMPOSES]-(:Composer {name: c})
};

CREATE (c:Composer {name: "AC/DC"})
WITH c
MATCH (t:Track {composer: "AC/DC"})
MERGE (t)<-[:COMPOSES]-(c);

LOAD CSV WITH HEADERS FROM 'file:///Employee.csv' AS ROW
CREATE (e:Employee {employeeId: toInteger(ROW.EmployeeId), firstName: ROW.FirstName, lastName: ROW.LastName, city: ROW.City, state: ROW.State, country: ROW.Country, birthDate: date(datetime({epochmillis: apoc.date.parse(ROW.BirthDate, "ms", "yyyy-MM-dd")})), hireDate: date(datetime({epochmillis: apoc.date.parse(ROW.HireDate, "ms", "yyyy-MM-dd")})), title: ROW.Title})
WITH e, toInteger(ROW.ReportsTo) AS mgrId
MATCH (m:Employee {employeeId: mgrId})
MERGE (e)-[:REPORTS_TO]->(m);

LOAD CSV WITH HEADERS FROM 'file:///Customer.csv' AS ROW
CREATE (c:Customer {customerId: toInteger(ROW.CustomerId), firstName: ROW.FirstName, lastName: ROW.LastName, city: ROW.City, state: ROW.State, country: ROW.Country})
WITH c, toInteger(ROW.SupportRepId) AS employeeId
MATCH (e:Employee {employeeId: employeeId})
MERGE (c)<-[:SUPPORTS]-(e);

LOAD CSV WITH HEADERS FROM 'file:///Invoice.csv' AS ROW
CREATE (i:Invoice {invoiceId: toInteger(ROW.InvoiceId), billingCity: ROW.BillingCity, billingState: ROW.BillingState, billingCountry: ROW.BillingCountry, total: toFloat(ROW.Total)})
WITH i, toInteger(ROW.CustomerId) AS customerId
MATCH (c:Customer {customerId: customerId})
MERGE (i)-[:BILLED_TO]->(c);

LOAD CSV WITH HEADERS FROM 'file:///InvoiceLine.csv' AS ROW
CREATE (il:InvoiceLine {invoiceLineId: toInteger(ROW.InvoiceId), trackId: toInteger(ROW.TrackId)})
WITH il, toInteger(ROW.InvoiceId) AS invoiceId
MATCH (i:Invoice {invoiceId: invoiceId})
MERGE (il)-[:PART_OF]->(i)
WITH il
MATCH (t:Track {trackId: il.trackId})
MERGE (t)<-[:CONTAINS]-(il);

CALL {
    MATCH (p)
    RETURN labels(p) AS type, count(p) AS cnt 
    UNION
    MATCH ()-[r]->()
    RETURN type(r) AS type, count(r) AS cnt
} RETURN type, cnt
ORDER BY cnt DESC;

CALL db.schema.nodeTypeProperties();

CALL db.schema.relTypeProperties();

call db.schema.visualization;

MATCH (g:Genre)<-[:TYPE_OF]-(:Track)<-[:CONTAINS]-(:InvoiceLine)-[:PART_OF]->(:Invoice)-[:BILLED_TO]->(c:Customer) 
RETURN c.firstName+" "+c.lastName AS Customer, g.name AS Genre, COUNT (g.name) AS Instances 
ORDER BY Instances DESC;

MATCH (g:Genre)<-[:TYPE_OF]-(:Track)<-[:CONTAINS]-(:InvoiceLine)-[:PART_OF]->(:Invoice)-[:BILLED_TO]->(c:Customer) 
RETURN c.firstName+" "+c.lastName AS Customer, COLLECT(g.name) AS Genres
ORDER BY Instances DESC;

MATCH (i:Invoice)-[:BILLED_TO]->(c:Customer) 
RETURN c.firstName+" "+c.lastName AS Customer, "$"+round(SUM(i.total), 2) AS Purchases
ORDER BY Purchases DESC
LIMIT 5;

MATCH (g:Genre)<-[:TYPE_OF]-(:Track)<-[:CONTAINS]-(:InvoiceLine)-[:PART_OF]->(:Invoice)-[:BILLED_TO]->(c:Customer)<-[:SUPPORTS]-(e:Employee)
WITH e, g.name AS genres, COUNT(g.name) AS counts ORDER BY counts DESC
RETURN e.firstName+" "+e.lastName AS Employee, COLLECT({genre: genres, sales: counts}) AS List;