CREATE OR REPLACE FUNCTION find_all_activities_for_owner(ownername varchar(500)) RETURNS SETOF activity AS $$
	SELECT a.*
	FROM activity a
	JOIN "user" u
	ON owner_id = u.id
	WHERE ownername = u.username  
$$ LANGUAGE SQL;