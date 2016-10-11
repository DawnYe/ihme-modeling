import db_tools


##############################################################################
# location stuff
##############################################################################


def get_current_location_set(loc_set_id=35, gbd_round_id=3):
    """return the most detailed location ids from the computation set"""
    epi_api = db_tools.MySQLEngine(host="modeling-epi-db.ihme.washington.edu",
                                   default_schema="epi")
    v = epi_api.query(
        "SELECT shared.active_location_set_version({ls},{gbd}) AS v".format(
            ls=loc_set_id, gbd=gbd_round_id)
    )["v"].item()
    loc_df = epi_api.query(
        "call shared.view_location_hierarchy_history({v})".format(v=v))
    return loc_df


def get_most_detailed_location_ids(loc_set_id=35, gbd_round_id=3):
    loc_df = get_current_location_set(loc_set_id, gbd_round_id)
    loc_ids = loc_df.ix[loc_df["most_detailed"] == 1, "location_id"].tolist()
    return loc_ids


##############################################################################
# location stuff
##############################################################################

def get_age_group_set(age_group_set_id):
    q = """
    SELECT
        age_group_id, age_group_years_start, age_group_years_end
    FROM
        shared.age_group_set_list
    JOIN
        shared.age_group USING (age_group_id)
    WHERE
        age_group_set_id = {age_group_set_id}
    """.format(age_group_set_id=age_group_set_id)
    age_df = db_tools.query(q, database="shared")
    return age_df
