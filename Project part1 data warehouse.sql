SET sql_mode = (SELECT REPLACE(@@SQL_MODE, "ONLY_FULL_GROUP_BY", ""));
CREATE OR REPlACE VIEW Customer_info AS
SELECT I.CustomerID, customer_name, Country, employee_name, I.InvoiceID, InvoicelineID, invoice_date,
IL.TrackID, type, UnitPrice, total_purchase_price, ArtistID
FROM(SELECT employee_name, customer_name, Country, cust.CustomerID
          FROM (SELECT CONCAT(Lastname, ", ", FirstName) as employee_name, EmployeeID
                FROM employee) AS emp
       RIGHT JOIN (  
             SELECT CONCAT(LastName, ", ", FirstName) as customer_name, CustomerID, Country, SupportRepID
                    FROM customer) AS cust
	   ON emp.EmployeeID = cust.SupportRepID) AS rep
   LEFT JOIN 
       (SELECT InvoiceID, CustomerID, STR_TO_DATE(InvoiceDate, "%Y-%m-%d") AS invoice_date
        FROM invoice
        GROUP BY InvoiceID, CustomerID
        ORDER BY CustomerID) AS I
        ON rep.CustomerID = I. CustomerID
LEFT JOIN
    (SELECT InvoiceID, InvoicelineID, TrackID, UnitPrice, ROUND(UnitPrice*Quantity,2) AS total_purchase_price
     FROM invoiceline
     GROUP BY InvoicelineID
     ORDER BY InvoiceID, TrackID) AS IL
ON I.InvoiceID = IL.InvoiceID
LEFT JOIN 
    (SELECT TrackID, t.GenreID, g.Name AS type, ArtistID
    FROM Track t
    LEFT JOIN 
		 genre g
    ON t.GenreID = g.GenreID
    LEFT JOIN album a
    ON t.AlbumID = a. AlbumID) AS t_g
ON IL. TrackID = t_g.TrackID
GROUP BY CustomerID, invoicelineid
ORDER BY CustomerID, invoiceID;

SELECT * FROM Customer_info