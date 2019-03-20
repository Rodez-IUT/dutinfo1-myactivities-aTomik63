CREATE OR REPLACE FUNCTION get_default_owner() RETURNS "user" AS $$
	DECLARE
		defaultOwner "user"%rowtype;
		defaultOwnerUsername varchar(500) := 'Default Owner';
		
	BEGIN
		select * into defaultOwner from "user" where username = defaultOwnerUsername;
		if not found then
			insert into "user" (id, username) values(nextval('id_generator'), defaultOwnerUsername);
			select * into defaultOwner from "user" where username = defaultOwnerUsername;
		end if;
		return defaultOwner;
		
	END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fix_activities_without_owner() RETURNS SETOF activity AS $$
	DECLARE
		defaultOwner "user"%rowtype;
	BEGIN
		defaultOwner := get_default_owner();
		RETURN QUERY
		UPDATE activity
		SET owner_id = defaultOwner.id
		WHERE owner_id IS NULL
		RETURNING *;
	END
$$ LANGUAGE plpgsql;