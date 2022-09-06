/* QUESTIONS
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT name FROM Facilities WHERE membercost != 0

/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT(membercost)
FROM Facilities
WHERE membercost = 0

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost < .20 * monthlymaintenance

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
SELECT facid, name, membercost, guestcost, initialoutlay, monthlymaintenance
FROM Facilities
WHERE facid IN(1, 5)

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
SELECT name, monthlymaintenance,
CASE WHEN monthlymaintenance <= 100
THEN 'cheap' ELSE 'expensive'
END AS perception
FROM Facilities;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT firstname, surname, joindate
FROM Members
WHERE joindate = (SELECT MAX(joindate)
FROM Members)

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT CONCAT_WS(' ', Members.firstname, Members.surname, Facilities.name) AS name
FROM Members
INNER JOIN Bookings ON Members.memid = Bookings.memid
INNER JOIN Facilities ON Bookings.facid = Facilities.facid
WHERE Facilities.name LIKE 'Tennis%'
ORDER BY Members.surname

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT starttime from Bookings
WHERE starttime between '2012-09-14 00:00:00' and '2012-09-14 23:59:00'
order by starttime desc;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT Bookings.starttime AS date_and_time,
    CONCAT_WS(' ', Members.firstname, Members.surname) AS member,
    Facilities.membercost AS member_price,
    Facilities.guestcost AS guest_cost

FROM Members
INNER JOIN Bookings ON Members.memid = Bookings.memid
INNER JOIN Facilities ON Bookings.facid = Facilities.facid

WHERE (Bookings.starttime BETWEEN '2012-09-14 00:00:00' AND '2012-09-14 23:59:00')
AND (Facilities.membercost > 30 OR Facilities.guestcost > 30)

ORDER BY starttime DESC;

/* PART 2: SQLite

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
WITH rev AS
    (SELECT Facilities.name,
    CASE WHEN Bookings.memid = 0
    THEN Facilities.guestcost * Bookings.slots
    ELSE Facilities.membercost * Bookings.slots
    END AS revenue FROM Facilities
    INNER JOIN Bookings ON Facilities.facid = Bookings.facid)

SELECT rev.name AS name, SUM(revenue) AS totals FROM rev
GROUP By name HAVING totals < 1000

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
SELECT (m1.surname ||' '|| m1.firstname) AS member_name,
       (m2.surname ||' '|| m2.firstname) AS referred_by
FROM Members as m1
INNER JOIN Members as m2 ON m1.recommendedby = m2.memid

/* Q12: Find the facilities with their usage by member, but not guests */
WITH users AS (SELECT facid, memid FROM Bookings WHERE memid != 0)
SELECT Facilities.name AS fac, COUNT(users.memid) AS count, facilities.facid
FROM Facilities
LEFT JOIN users ON Facilities.facid = users.facid GROUP BY facilities.name

/* Q13: Find the facilities usage by month, but not guests */
WITH usage AS (SELECT memid, strftime('%m', starttime) as month FROM Bookings WHERE memid != 0)
SELECT COUNT(usage.memid) AS cnt, usage.month FROM usage GROUP BY usage.month











