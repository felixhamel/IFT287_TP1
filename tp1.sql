/***********************************************************
 DQL SELECT
 Schéma MRD:	"MRD_TP1"
 Auteurs:	Alexandre Blais - UdeS
		Félix Hamel - UdeS
***********************************************************/

/* Requête #1 */
-- 1. Affichez tous les joueurs de toutes les équipes. 
--    Affichez les champs suivants : EquipeId, EquipeNom, JoueurId, JoueurNom, JoueurPrenom, Numero, DateDebut, DateFin (dans le format YYYY-MM-DD). 
--    Triez par EquipeId, Numero. Utilisez la clause WHERE pour faire la jointure.

SELECT 
  equipe.equipeid AS "EquipeId", 
  equipe.equipenom AS "EquipeNom", 
  joueur.joueurid AS "JoueurId", 
  joueur.joueurnom AS "JoueurNom", 
  joueur.joueurprenom AS "JoueurPrenom", 
  faitpartie.numero AS "Numero", 
  faitpartie.datedebut AS "DateDebut", 
  to_char(faitpartie.datefin, 'YYYY-MM-DD') AS "DateFin"
FROM 
  equipe, 
  faitpartie, 
  joueur
WHERE 
  faitpartie.joueurid = joueur.joueurid AND
  faitpartie.equipeid = equipe.equipeid
ORDER BY
  equipe.equipeid ASC,
  faitpartie.numero ASC;
  
/* ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// */
  
/* Requête #2 */
  -- 2. La même requête qu’au numéro 1, mais utilisez la clause JOIN pour exprimer la jointure.

SELECT 
  equipe.equipeid AS "EquipeId", 
  equipe.equipenom AS "EquipeNom", 
  joueur.joueurid AS "JoueurId", 
  joueur.joueurnom AS "JoueurNom", 
  joueur.joueurprenom AS "JoueurPrenom", 
  faitpartie.numero AS "Numero", 
  faitpartie.datedebut AS "DateDebut", 
  to_char(faitpartie.datefin, 'YYYY-MM-DD') AS "DateFin"
FROM 
  faitpartie
INNER JOIN joueur
  ON faitpartie.joueurid = joueur.joueurid
INNER JOIN equipe
  ON faitpartie.equipeid = equipe.equipeid
ORDER BY
  equipe.equipeid ASC,
  faitpartie.numero ASC;

 /* ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// */

 /* Requête #3 */
 -- 3. La même requête qu’au numéro 1, sauf que si un joueur n’a pas d’équipe, il doit quand même apparaître.

SELECT 
  equipe.equipeid AS "EquipeId", 
  equipe.equipenom AS "EquipeNom", 
  joueur.joueurid AS "JoueurId", 
  joueur.joueurnom AS "JoueurNom", 
  joueur.joueurprenom AS "JoueurPrenom", 
  faitpartie.numero AS "Numero", 
  faitpartie.datedebut AS "DateDebut", 
  to_char(faitpartie.datefin, 'YYYY-MM-DD') AS "DateFin"
FROM 
  faitpartie
RIGHT JOIN joueur
  ON joueur.joueurid = faitpartie.joueurid
LEFT JOIN equipe
  ON faitpartie.equipeid = equipe.equipeid
ORDER BY
  equipe.equipeid ASC,
  faitpartie.numero ASC;

/* ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// */

/* Requête #4 */
-- 4. Affichez, pour chaque match le nombre de joueurs participants. Tous les matchs doivent apparaître. Affichez les champs suivants : MatchId, nombre de joueurs. Triez par MatchId.

SELECT 
  match.matchid AS "MatchId", 
  COUNT(participe.joueurid) AS "NombreDeJoueurs"
FROM 
  match
INNER JOIN participe
  ON participe.matchid = match.matchid
WHERE 
  match.matchid = participe.matchid
GROUP BY
  match.matchid
ORDER BY
  match.matchid ASC;

/* ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// */

/* Requête #5 */
-- 5. Affichez pour chaque match le nombre de joueurs participants par équipe. 
--    Tous les matchs doivent apparaître. 
--    Affichez les champs suivants : MatchId, Equipe (il faut afficher les joueurs ayant participé dans l’équipe locale ainsi que les joueurs ayant participé dans l’équipe visiteur), nombre de joueurs. Triez par MatchId, Equipe.

SELECT
  match.matchid AS "MatchId",
  equipelocal.equipenom AS "EquipeNomLocal",
  (SELECT COUNT(faitpartie.joueurid)
		FROM faitpartie
		INNER JOIN participe
		   ON participe.joueurid = faitpartie.joueurid
		WHERE faitpartie.equipeid = equipelocal.equipeid AND participe.matchid = match.matchid) AS "NombreJoueursEquipeLocal",
  equipevisiteur.equipenom  AS "EquipeNomVisiteur",
  (SELECT COUNT(faitpartie.joueurid)
		FROM faitpartie
		INNER JOIN participe
		   ON participe.joueurid = faitpartie.joueurid
		WHERE faitpartie.equipeid = equipevisiteur.equipeid AND participe.matchid = match.matchid) AS "NombreJoueursEquipeVisiteur"
	
FROM
  match
INNER JOIN equipe as equipelocal
  ON equipelocal.equipeid = match.equipelocal
INNER JOIN equipe as equipevisiteur
  ON equipevisiteur.equipeid = match.equipevisiteur
ORDER BY
  matchid ASC,
  equipelocal.equipenom ASC,
  equipevisiteur.equipenom ASC;

/* ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// */

/* Requête #6 */
-- 6. Affichez le nombre de matchs qu’un arbitre a arbitrés. 
--    Montrez les champs suivants : ArbitreId, nom et prénom de l’arbitre, nombre de matchs. 
--    Triez par ArbitreId.

SELECT 
  arbitre.arbitreid AS "ArbitreId", 
  arbitre.arbitrenom AS "ArbitreNom", 
  arbitre.arbitreprenom AS "ArbitrePrenom", 
  COUNT(arbitrer.matchid) AS "NombreDeMatchs"
FROM 
  arbitre
LEFT JOIN arbitrer
  ON arbitrer.arbitreid = arbitre.arbitreid
GROUP BY
  arbitre.arbitreid
ORDER BY
  arbitre.arbitreid ASC;

/* ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// */

/* Requête #7 */
-- 7. Affichez le calendrier de la saison. 
--    Montrez les champs suivants : MatchId, EquipeLocal, EquipeVisiteur, TerrainId, MatchDate (avec le format MM-JJ), MatchHeure (avec le format HH24 :MM), Nom du Terrain, PointsLocal, PointsVisiteur) 
--    ou le message « À venir » si le match n’a pas encore été joué.

SELECT 
  match.matchid AS "MatchId", 
  (SELECT equipe.equipenom FROM equipe WHERE match.equipelocal = equipe.equipeid) AS "EquipeLocal", 
  (SELECT equipe.equipenom FROM equipe WHERE match.equipevisiteur = equipe.equipeid) AS "EquipeVisiteur", 
  terrain.terrainnom AS "Terrain",
  to_char(match.matchdate, 'MM-DD') AS "MatchDate", 
  to_char(match.matchheure, 'HH24:MM') AS "MatchHeure", 
  terrain.terrainnom AS "TerrainNom",
  CASE WHEN match.pointslocal IS NOT NULL THEN 
	CAST(concat(match.pointslocal, '-', match.pointsvisiteur) AS text)
  ELSE 'À venir'
  END AS "Pointage"
FROM 
  match, 
  terrain
WHERE 
  match.terrainid = terrain.terrainid
GROUP BY
  match.matchid,
  terrain.terrainid;
  
/* ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// */

/* Requête #8 */
-- 8. La même requête qu’au numéro 7, sauf qu’il faut afficher seulement les matchs qui n’ont pas encore eu lieu. 
--    Utilisez les points null pour savoir si le match a été joué.

SELECT 
  match.matchid AS "MatchId", 
  (SELECT equipe.equipenom FROM equipe WHERE equipe.equipeid = match.equipelocal) AS "EquipeLocal", 
  (SELECT equipe.equipenom FROM equipe WHERE equipe.equipeid = match.equipevisiteur) AS "EquipeVisiteur", 
   terrain.terrainnom AS "Terrain",
  to_char(match.matchdate, 'MM-DD') AS "MatchDate", 
  to_char(match.matchheure, 'HH24:MM') AS "MatchHeure", 
  terrain.terrainnom AS "TerrainNom", 
  CASE WHEN match.pointslocal IS NOT NULL THEN 
	CAST(concat(match.pointslocal, '-', match.pointsvisiteur) AS text)
  ELSE 'À venir'
  END AS "Pointage"
FROM 
  match
INNER JOIN terrain
  ON terrain.terrainid = match.terrainid
WHERE 
  match.pointslocal IS NULL
  AND match.pointsvisiteur IS NULL
GROUP BY
  match.matchid,
  terrain.terrainid;
  
/* ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// */

/* Requête #9 */
-- 9. Affichez le match dans lequel il y a eu la plus grande quantité de points marqués entre les deux équipes.
--	   Affichez les informations comme suit : MatchId, Nom de l’équipe local, nom de l’équipe visiteur,
--	   Nom du terrain, MatchDate (avec le format JJ-MM-AAAA), nombre de points de l’équipe locale, nombre de points de l’équipe visiteur, nombre total de points.

SELECT
  match.matchid AS "NumeroMatch",
  (SELECT
    equipe.equipenom
   FROM equipe
   WHERE 
    equipe.equipeid = match.equipelocal) AS "NomEquipeLocal",
  (SELECT
     equipe.equipenom
   FROM equipe
   WHERE
     equipe.equipeid = match.equipevisiteur) AS "NomEquipeVisiteur",
  terrain.terrainnom AS "NomTerrain",
  to_char(match.matchdate, 'DD-MM-YYYY') AS "DateMatch",
  match.pointslocal AS "PointsEquipeLocale",
  match.pointsvisiteur AS "PointsEquipeVisiteur",
  match.pointslocal + match.pointsvisiteur AS "TotalPoints"
FROM
  match
  INNER JOIN terrain
    ON terrain.terrainid = match.terrainid
WHERE
  (match.pointslocal + match.pointsvisiteur) IS NOT NULL
GROUP BY
  match.matchid,
  terrain.terrainnom
ORDER BY
  "TotalPoints" DESC
LIMIT 1;

/* ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// */

/* Requête #10 */
-- 10. Affichez le match où le plus grand nombre de joueurs ont participé. 
--     Affichez les informations suivantes : MatchId, nom de l’équipe local, nom de l’équipe visiteur, nombre de joueurs de l’équipe locale, nombre de joueurs de l’équipe visiteur, nombre total de joueurs.

SELECT
  *, -- Garder tout les champs de la sous-requête
  (matchinfo."NombreJoueursEquipeLocal" + matchinfo."NombreJoueursEquipeVisiteur") AS "NombreJoueursTotal"
FROM
  (SELECT
     match.matchid,
    (SELECT equipe.equipenom FROM equipe WHERE match.equipelocal = equipe.equipeid) AS "EquipeLocalNom",
    (SELECT equipe.equipenom FROM equipe WHERE match.equipevisiteur = equipe.equipeid) AS "EquipeVisiteurNom",
    (SELECT COUNT(faitpartie.joueurid)
   FROM faitpartie
   INNER JOIN participe
     ON participe.joueurid = faitpartie.joueurid
   WHERE faitpartie.equipeid = match.equipelocal AND participe.matchid = match.matchid) AS "NombreJoueursEquipeLocal",
   (SELECT COUNT(faitpartie.joueurid)
    FROM faitpartie
    INNER JOIN participe
      ON participe.joueurid = faitpartie.joueurid
    WHERE faitpartie.equipeid = match.equipevisiteur AND participe.matchid = match.matchid) AS "NombreJoueursEquipeVisiteur"
    FROM match) AS matchinfo
ORDER BY "NombreJoueursTotal" DESC
LIMIT 1;
