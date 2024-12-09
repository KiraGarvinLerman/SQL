# review data for any visible issues
SELECT * FROM RAW_MOCK_DATA rmd
LIMIT 20;

# see that: 
# - product_name is actually the customer's salutation
# - date is a static string
# - postcode has an erroneous comma

# we're going to build out the database to include:
--   1. **Customers**: `customer_id`, `salutation`, `first_name`, `last_name`, `email`, `age`, `gender`, `city`, `state`, `zipcode`
--   2. **Products**: `product_id`, `product_name`, `category`, `price`.
--   3. **Orders**: `order_id`, `customer_id`, `purchase_date`, `total_amount`.
--   4. **Order Details**: `order_id`, `product_id`, `quantity`, `price_per_unit`.


# begin separation
CREATE TABLE customers AS
SELECT customer_id, product_name AS salutation, first_name, last_name, email, age, gender, city, state, REPLACE(CONCAT(postcode), ',', '') AS postcode
FROM RAW_MOCK_DATA rmd;

# confirm that all customers have a valid email
SELECT REGEXP_LIKE(email,'[A-Z][A-Z0-9._-]+@[A-Z0-9_-]+\.[A-Z]{2,4}') AS valid, COUNT(*) 
FROM customers
GROUP BY valid;

# separate product data
CREATE TABLE products AS	
SELECT DISTINCT product_id , category , product AS product_name, price
FROM RAW_MOCK_DATA rmd
ORDER BY product_id;


# separate order overview data and create a primary key
CREATE TABLE orders(order_id MEDIUMINT NOT NULL AUTO_INCREMENT, PRIMARY KEY(order_id) ) AS	
SELECT purchase_date , customer_id, product_id , price*quantity AS total_amount
FROM RAW_MOCK_DATA rmd;

# separate order details and connect it back to our new `order_id`
CREATE TABLE order_details AS  
SELECT o.order_id, rmd.product_id, rmd.quantity, rmd.price AS price_per_unit, o.total_amount
FROM RAW_MOCK_DATA rmd JOIN orders o 
WHERE o.customer_id = rmd.customer_id 

# let's convert the date from a string to make it more useful
# if we would continue to receive '/' format it would be better to create an additional column, 
# but let's assume we're setting up a new system
UPDATE orders
set purchase_date = str_to_date(purchase_date, '%m/%d/%Y');

# let's finish formating postcode as char5 to prevent data issues
# check if we have any postcode+4 
SELECT CHAR_LENGTH(postcode) AS length FROM RAW_MOCK_DATA rmd GROUP BY length;

# we are working with a 5-digit zipcode for this dataset
ALTER TABLE customers
MODIFY COLUMN postcode CHAR(5); # switch FROM int TO 5 characters A-Z
UPDATE customers SET postcode =LPAD(postcode, 5, '0'); # pad zips that begin with 0

# let's make sure the tables are connected
ALTER TABLE customers 
MODIFY COLUMN customer_id int auto_increment NOT NULL;

ALTER TABLE customers 
ADD PRIMARY KEY (customer_id);

ALTER TABLE	orders 
ADD FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

ALTER TABLE	orders 
ADD FOREIGN KEY (product_id) REFERENCES products(product_id);

ALTER TABLE products 
ADD PRIMARY KEY (product_id);

ALTER TABLE	order_details 
ADD FOREIGN KEY (order_id) REFERENCES orders(order_id);

ALTER TABLE order_details 
ADD FOREIGN KEY (product_id) REFERENCES products(product_id);