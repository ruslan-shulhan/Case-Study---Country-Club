/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

---------------------->start_query
SELECT name
FROM Facilities
WHERE membercost > 0;
<----------------------end_query

/* Q2: How many facilities do not charge a fee to members? */

---------------------->start_query
SELECT COUNT(name) AS no_charge
FROM Facilities
WHERE membercost = 0;
<----------------------end_query

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

---------------------->start_query
SELECT facid,
		name,
		membercost,
		monthlymaintenance
FROM Facilities
WHERE membercost > 0
AND (membercost / monthlymaintenance) * 100 < 20;
<----------------------end_query

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

---------------------->start_query
SELECT *
FROM Facilities
WHERE facid IN (1, 5);
<----------------------end_query

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

---------------------->start_query
SELECT name,
		monthlymaintenance,
		CASE WHEN monthlymaintenance > 100 THEN 'expensive'
			ELSE 'cheap' END AS facility_cost
FROM Facilities;
<----------------------end_query

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

---------------------->start_query
SELECT firstname,
		surname
FROM Members
WHERE joindate = (
	SELECT MAX(joindate)
    FROM Members
)
<----------------------end_query

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

---------------------->start_query
SELECT DISTINCT f.name,
		CONCAT(m.firstname, ' ', m.surname) AS full_name
FROM Bookings AS b
INNER JOIN Facilities AS f
ON b.facid = f.facid
INNER JOIN Members AS m
ON b.memid = m.memid
WHERE f.facid IN (0, 1)
<----------------------end_query

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

---------------------->start_query
SELECT 	f.name AS facility,
		CONCAT(m.firstname, " ", m.surname) AS name,
		SUM(CASE WHEN m.surname LIKE 'GUEST' THEN (b.slots * f.guestcost)
			ELSE (b.slots * f.membercost) END) AS cost
FROM Bookings AS b
INNER JOIN Members AS m
ON b.memid = m.memid
INNER JOIN Facilities AS f
ON b.facid = f.facid
WHERE b.starttime LIKE '2012-09-14%'
GROUP BY b.memid
HAVING cost > 30
ORDER BY cost DESC
<----------------------end_query

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

---------------------->start_query
SELECT subquery.name,
	CONCAT(m.firstname, " ", m.surname) AS name,
	CASE WHEN m.surname LIKE 'GUEST' THEN SUM(subquery.guestcost)
		ELSE SUM(subquery.membercost) END AS cost
FROM (
	SELECT b.facid,
    		b.memid,
    		f.name,
    		(f.guestcost * b.slots) AS guestcost,
    		(f.membercost * b.slots) AS membercost
    FROM Bookings AS b
    INNER JOIN Facilities AS f
    ON b.facid = f.facid
    WHERE starttime LIKE '2012-09-14%'
) AS subquery
INNER JOIN Members AS m
ON m.memid = subquery.memid
GROUP BY subquery.memid
HAVING cost > 30
ORDER BY cost DESC
<----------------------end_query

/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

---------------------->start_query
        SELECT subquery.name,
        SUM(subquery.total_cost) AS revenue
        FROM (
            SELECT b.facid,
                    f.name,
                    CASE WHEN m.firstname LIKE 'GUEST' THEN (b.slots * f.guestcost)
                        ELSE (b.slots * f.membercost) END AS total_cost
                    
            FROM Bookings AS b
            INNER JOIN Facilities AS f
            ON b.facid = f.facid
            INNER JOIN Members AS m
            ON m.memid = b.memid
        ) AS subquery
        GROUP BY subquery.facid
        HAVING revenue < 1000
        ORDER BY revenue
<----------------------end_query

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

---------------------->start_query
        SELECT subquery_1.member,
                subquery_2.recommendedby
        FROM (
            SELECT *,
            m.surname|| ' ' || m.firstname AS member,
            m.recommendedby
            FROM Members AS m
            WHERE m.recommendedby >= 0
        ) AS subquery_1
        INNER JOIN (
            SELECT m.memid,
                    m.surname || " " || m.firstname AS recommendedby
            FROM Members AS m
        ) AS subquery_2
        ON subquery_1.recommendedby = subquery_2.memid
        ORDER BY subquery_1.member
<----------------------end_query

/* Q12: Find the facilities with their usage by member, but not guests */

---------------------->start_query
        SELECT subquery_1.facid,
                f.name,
                subquery_1.total_members
                
        FROM (
            SELECT *,
                    b.facid,
                    COUNT(b.memid) AS total_members
            FROM Bookings AS b
            WHERE b.memid NOT IN (
                SELECT m.memid
                FROM Members AS m
                WHERE m.firstname LIKE "GUEST"
            )
            GROUP BY b.facid
            ORDER BY b.facid
        ) AS subquery_1
        INNER JOIN Facilities AS f
        ON f.facid = subquery_1.facid
        ORDER BY subquery_1.total_members DESC
<----------------------end_query

/* Q13: Find the facilities usage by month, but not guests */

---------------------->start_query
        SELECT subquery_1.facid,
            f.name AS facility,
            MAX(subquery_1.counter) AS most_attended,
            subquery_1.month AS month
        FROM (
            SELECT *,
                strftime('%m', b.starttime) AS month,
                COUNT(b.memid) AS counter
                
            FROM Bookings AS b
            WHERE b.memid NOT IN (
                SELECT memid
                FROM Members
                WHERE firstname LIKE 'GUEST'
            )
            GROUP BY b.facid, month
            ORDER BY b.facid
            
        ) AS subquery_1
        INNER JOIN Facilities AS f
        ON subquery_1.facid = f.facid
        GROUP BY subquery_1.month
        ORDER BY subquery_1.month
<----------------------end_query
































