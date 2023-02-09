-- This is how to make a comment in SQL

CREATE TABLE Customer -- The starting point to create a table called Customer. Typcial style for SQL is all caps for SQL keywords, normal capitalization for names of tables and all lowercase for variable names
(
    id NUMBER(5,0), -- The first part is the variable name "id", the secound part is the variable type "NUMBER" which in this case is just numbers and finally the last part formats the variable type in this case it is five digits and no floating digits.
    age NUMBER(3,1), -- This is similar to up top but it has a total of three digits and one of those digits is a floating point digit. id example "12345", age example "20.5"
    first_name VARCHAR(38), -- This variable type is for strings and the only formating is for the number of characters. 38 is chosen because this is the max for most variable types such as VARCHAR. Notice that on the ER design this is one of the components for the variable name. We do not need to store the wider variable but instead just the components that we need so we can easily use those components without having to seperate it from the main variable.
    last_name VARCHAR2(38), -- This variable type is also for strings and the only difference between VARCHAR and VARCHAR2 is that VARCHAR uses ANSI SQL while VARCHAR2 uses Oracle SQL. There is not any real difference in use but realize that there is a lot of overlapping variable types.
    PRIMARY KEY(id) -- This sets the primary key as id, this is how the database checks if a record repeats since no record is allowed to have the same primary key
); -- the semi colin is used to end this command but also tells to the SQL reader to keep reading the script.

CREATE TABLE Phones -- Whenever there is multiple possible variables an entity has that are of the same type, such as a customer having multiple phone numbers, it is good practice to make that type its own table that is then joined to the entity in order to dynamically store everything while still remaining flexible.
(
    cid NUMBER(5,0) NOT NULL, --notice how each variable is seperated with a "," when it is being added in. Another thing to notice is that we can force a collumn to always have some value with NOT NULL after declaring it.
    phone_number NUMBER(10,0) NOT NULL,
    phone_type VARCHAR2(38),
    PRIMARY KEY(phone_number),
    FOREIGN KEY(cid) REFERENCES Customer(id)  -- A foreign key is a variable that is tied directly with another variable in another table so in this instance the customer id from the table Customer and the customer id from Phones are being joined. They have to be the same value in both tables but do not need to have the same name in both tables
);

CREATE TABLE Address
(
	state VARCHAR2(2),
	street VARCHAR2(38),
	zipcode NUMBER(5,0),
	city VARCHAR2(38),
	cid NUMBER(5,0) NOT NULL,
	PRIMARY KEY(state, street, zipcode, city), -- A primary key can be made up of multible variables which means that the database requires a record to be matching all variables at the same time for it to be an error. A primary key can also make up all of the variables
	FOREIGN KEY(cid) REFERENCES Customer(id)
);

CREATE TABLE Redemption -- When there is a one-to-many connection, a best practice is to add the primary key of the on part of the relation to the other table
(
	points NUMBER(38,0),
	id NUMBER(5,0),
	cid NUMBER(5,0),
	PRIMARY KEY(id),
	FOREIGN KEY(cid) REFERENCES Customer(id)
);

CREATE TABLE Rewards
(
	name VARCHAR2(38),
	points NUMBER(38,0),
	PRIMARY KEY(name)
);  -- 5

CREATE TABLE Redemption_Rewards -- A best practice is when you have a many-to-many connection is to create a table that connects the two instead of linking them in the table and then make them both primary keys so only a perfect duplicate triggers the error
(
	redem_id NUMBER(5,0),
	reward_name VARCHAR2(38),
	quantity NUMBER(38,0),
	PRIMARY KEY(redem_id,reward_name),
	FOREIGN KEY(redem_id) REFERENCES Redemption(id),
	FOREIGN KEY(reward_name) REFERENCES Rewards(name)
);

CREATE TABLE Account
(
	account_id NUMBER(5,0),
	points NUMBER(38,0),
	cid NUMBER(5,0) NOT NULL,
	PRIMARY KEY(account_id),
	UNIQUE(cid),
	FOREIGN KEY(cid) REFERENCES Customer(id)  ON DELETE SET NULL -- Here we see that when a customer id is deleted then the record is kepted and the value referenced is made null. 
);

CREATE TABLE Login
(
	user_name VARCHAR2(38),
	password VARCHAR2(38) DEFAULT '!!!!C4ANGE_YOUR_PA22W0RD!!!!', -- When a value is not entered and is not required to be inputted, like here because it is not a primary key, then by default it is given a value of NULL. We can change the default to something more useful like here we give them this wonderful password.
	account_id NUMBER(5,0) NOT NULL,
	PRIMARY KEY(user_name),
	UNIQUE(account_id),
	FOREIGN KEY(account_id) REFERENCES Account(account_id)
);

CREATE TABLE 'Customer Order' -- If the table name has a space in it or it is a keyword for SQL, you have to use ''. This also applies to anything else you do that has a space or a keyword. 
(
	order_id NUMBER(5,0),
	order_cost NUMBER(38,2),
	points NUMBER(38,0),
	order_date TEXT, -- There is a huge number of different variable types that each version of SQL use, in this case with SQLite, there is no actual DATE variable so we are using Text and then when insert into the records we use DATE() to turn the value into the correct format YYYY-MM-DD
	cid NUMBER(5,0) NOT NULL,
	PRIMARY KEY(order_id),
	FOREIGN KEY(cid) REFERENCES Customer(id) 
);

CREATE TABLE Book
(
	cost NUMBER(38,2),
	isbn VARCHAR2(38),
	points NUMBER(38,0),
	PRIMARY KEY(isbn)
);  -- 10

CREATE TABLE Book_In_Order
(
	isbn VARCHAR2(38),
	order_id NUMBER(5,0),
	num_of_books NUMBER(38,0),
	PRIMARY KEY(isbn, order_id), -- When we make changes to the records, like below, in the database, like updating or deleting records, it will of course affect other parts of the table like here in the table Book_In_Order. Normally it will use CASCADE which means that when the record that is being referenced here is deleted or change then the value that is being referenced here is changed or the whole record itself is deleted. We can use NO ACTION, CASCADE (default option), SET NULL and finally SET DEFAULT.
	FOREIGN KEY(isbn) REFERENCES Book(isbn) ON DELETE NO ACTION, -- Here we are seeing that when a book's isbn is changed then nothing will happen to this isbn value.
	FOREIGN KEY(order_id) REFERENCES 'Customer Order'(order_id)
);

CREATE TABLE Store
(
	store_id NUMBER(5,0),
	state VARCHAR2(2),
	street VARCHAR2(38),
	zipcode NUMBER(5,0),
	city VARCHAR2(38),
	UNIQUE (city), -- UNIQUE is used when you want the variable to be different for each record but you don't want it to be the primary key that is sorted. It can also accept null values as well. Here we can use it as a way to make sure we do not have more than one store at a zipcode
	PRIMARY KEY(store_id)
);

CREATE TABLE Book_In_Store
(
	isbn VARCHAR2(38),
	store_id NUMBER(5,0),
	num_of_books NUMBER(38,0),
	PRIMARY KEY(isbn, store_id),
	FOREIGN KEY(isbn) REFERENCES Book(isbn),
	FOREIGN KEY(store_id) REFERENCES Store(store_id)
);

CREATE TABLE Employee
(
	emp_id NUMBER(5,0),
	first_name VARCHAR2(38),
	last_name VARCHAR2(38),
	manager_id NUMBER(5,0),  -- Here we are referencing that an employee can be managed, we could have done this as a seperate table, like for example if an employee can have multiple supervisors but since we do not then we do not need to. We can also use a value to show that the employee does not have a manager by either putting in a spefic manager id or by making the value null. In this implementation we will be making it NULL
	store_id NUMBER(5,0),
	PRIMARY KEY(emp_id),
	FOREIGN KEY(store_id) REFERENCES Store(store_id)
);

-- We have now built all of the tables have now been built so now lets add records into the table

-- Customer Records
INSERT INTO Customer (id, age, first_name, last_name) VALUES (1, 19, 'Matthew', 'White');  -- This is the basic way to add a record to a table. INSERT INTO (Table) -- 15 (Variables) VALUES (Variable Values)
INSERT INTO Customer (id, age, first_name, last_name) VALUES (2, 45, 'Thomas', 'Brown'); -- For most record data types you add in values like this. Number values are just added in like normal but for character types you have to add in ''
INSERT INTO Customer (id, age, first_name, last_name) VALUES (3, 35, 'Mary', 'Goodwin');
INSERT INTO Customer (id, age, first_name, last_name) VALUES (4, 24, 'Deborah', 'Stephenson');
INSERT INTO Customer (id, age, last_name) VALUES (5, 54, 'Watkins'); -- When we use this basic way to insert records we can control what variables are added so in this case this record does not have a first name. This can only be done to variables that are not a part of the primary key and the default value is null but into the table construction you can set to be something else.

-- Phone Records

INSERT INTO Phones VALUES (1, 5056462814, 'Mobile'); -- Another shorter way to insert records where don't put in the variable names  -- 20
INSERT INTO Phones VALUES (2, 2096299448, 'Home'); -- When you are using this shorter way, you must put in values for all variables. If you want some variables to not be added use the basic way and don't add the variable to the list.
INSERT INTO Phones VALUES (3, 2205212544, 'Mobile');
INSERT INTO Phones VALUES (4, 5056582455, 'Mobile');
INSERT INTO Phones VALUES (5, 5056440310, 'Home');
INSERT INTO Phones VALUES (1, 7144184370, 'Work'); -- This are additional phone numbers for customers that have two phone numbers -- 25
INSERT INTO Phones VALUES (2, 5056443471, 'Work');

-- Address

INSERT INTO Address VALUES ('Alaska', '2268 S Tongass Hwy', 99901, 'Ketchikan', 1);
INSERT INTO Address VALUES ('Alaksa', '2425 Hc 1', 99588, 'Glennallen', 1);
INSERT INTO Address VALUES ('Rhode Island', '31 Elmhurst Ave', 02920, 'Cranston', 2);
INSERT INTO Address VALUES ('Tennessee', '130 Pike Ln', 37714, 'Caryville', 3);  --30
INSERT INTO Address VALUES ('Minnesota', '620 Valley Dr', 56537, 'Fergus Falls', 4);
INSERT INTO Address VALUES ('Minnesota', '1004 Princeton Ave', 55379, 'Shakopee', 5);

-- Rewards

INSERT INTO Rewards (points, name) VALUES (100, 'Free Book Marker Set'); -- Using the more basic style also allows you to change the order, it is not very important thing but you can do it.
INSERT INTO Rewards VALUES ('$10 Coupon', 1000);
INSERT INTO Rewards VALUES ('Free Handcrafted Wooden Puzzle', 1500); -- 35
INSERT INTO Rewards VALUES ('Free Coffee and Bagel', 250);
INSERT INTO Rewards VALUES ('Free Notebook and Pencil Set', 250);

-- Redemption

INSERT INTO Redemption VALUES (250, 1, 1);
INSERT INTO Redemption VALUES (1100, 2, 1);
INSERT INTO Redemption VALUES (500, 3, 1);  -- 40
INSERT INTO Redemption VALUES (1600, 4, 2);
INSERT INTO Redemption VALUES (100, 5, 3);
INSERT INTO Redemption VALUES (350, 6, 3);
INSERT INTO Redemption VALUES (250, 7, 4);
INSERT INTO Redemption VALUES (250, 8, 4);  -- 45
INSERT INTO Redemption VALUES (1750, 9, 5); 

-- Redemption_Rewards

INSERT INTO Redemption_Rewards VALUES (1, 'Free Coffee and Bagel', 1);
INSERT INTO Redemption_Rewards VALUES (2, '$10 Coupon', 1);
INSERT INTO Redemption_Rewards VALUES (2, 'Free Book Marker Set', 1);
INSERT INTO Redemption_Rewards VALUES (3, 'Free Coffee and Bagel', 2);  -- 50
INSERT INTO Redemption_Rewards VALUES (4, 'Free Handcrafted Wooden Puzzle',1);
INSERT INTO Redemption_Rewards VALUES (4, 'Free Book Marker Set', 1);
INSERT INTO Redemption_Rewards VALUES (5, 'Free Book Marker Set', 1);
INSERT INTO Redemption_Rewards VALUES (6, 'Free Notebook and Pencil Set', 1);
INSERT INTO Redemption_Rewards VALUES (6, 'Free Book Marker Set', 1);  -- 55
INSERT INTO Redemption_Rewards VALUES (7, 'Free Notebook and Pencil Set', 1);
INSERT INTO Redemption_Rewards VALUES (8, 'Free Coffee and Bagel', 1);
INSERT INTO Redemption_Rewards VALUES (9, 'Free Notebook and Pencil Set', 3);
INSERT INTO Redemption_Rewards VALUES (9, '$10 Coupon', 1);

-- Account

INSERT INTO Account VALUES (10001, 350, 1);  -- 60
INSERT INTO Account VALUES (10002, 700, 2);
INSERT INTO Account VALUES (10003, 1000, 3);
INSERT INTO Account VALUES (10004, 200, 4);
INSERT INTO Account VALUES (10005, 0, 5);

--Login

INSERT INTO Login (user_name, account_id) VALUES ('user_1', 10001); -- Using the more basic style also allows you to not put in certain values and instead that variable will take the default value  -- 65
INSERT INTO Login VALUES ('user_2', 'pass2',10002);
INSERT INTO Login VALUES ('user_3', 'pass3', 10003);
INSERT INTO Login VALUES ('user_4', 'pass4', 10004);
INSERT INTO Login VALUES ('user_5', 'pass5', 10005);

-- Customer Order

INSERT INTO 'Customer Order' VALUES (1, 60.50, 6050, DATE('2022-10-08'), 1); --12  --70
INSERT INTO 'Customer Order' VALUES (2, 35.50, 3550, DATE('2022-05-50'), 1); --3
INSERT INTO 'Customer Order' VALUES (3, 15.75, 1575, DATE('2022-06-17'), 2); --4
INSERT INTO 'Customer Order' VALUES (4, 100, 10000, DATE('2002-03-13'), 2); -- 09
INSERT INTO 'Customer Order' VALUES (5, 25.85, 2585, DATE('2022-10-08'), 3); -- 68
INSERT INTO 'Customer Order' VALUES (6, 78.25, 7885, DATE('2022-07-04'), 1); -- 45  -- 75
INSERT INTO 'Customer Order' VALUES (7, 140, 14000, DATE('2022-06-30'), 5); -- 0x47
-- Book

INSERT INTO Book VALUES (20.50, '978-1-59059-239-7', 2050); -- Practical Common Lisp 1
INSERT INTO Book VALUES (40, '978-0-764-57481-8', 4000); -- Reversing 2
INSERT INTO Book VALUES (35.50, '978-1-59327-283-8', 3550); -- Haskell 3
INSERT INTO Book VALUES (15.75, '9798595265973', 1575); -- Proofs 4  -- 80
INSERT INTO Book VALUES (62.50, '0-393-04002-X', 6250); -- Math History 5
INSERT INTO Book VALUES (13.50, '978-0-7603-3174-3', 1350); -- Welding 6
INSERT INTO Book VALUES (14.95, '978-1-78404-91604', 1495); -- Poetry Civil War 7
INSERT INTO Book VALUES (12.35, '0-7603-1056-4', 1235); -- 4 Wheeler's Bible 8
INSERT INTO Book VALUES (65, '978-0-7858-1453-5', 6500); -- Edgar Allan Poe Collection 9  -- 85
INSERT INTO Book VALUES (35,'978-083761615-5', 3500); -- Physics for Gearheads 0

-- Book_In_Order

INSERT INTO Book_In_Order VALUES ('978-1-59059-239-7', 1, 1);
INSERT INTO Book_In_Order VALUES ('978-0-764-57481-8', 1, 1);
INSERT INTO Book_In_Order VALUES ('978-1-59327-283-8', 2, 1);
INSERT INTO Book_In_Order VALUES ('9798595265973', 3, 1);  -- 90
INSERT INTO Book_In_Order VALUES ('978-083761615-5', 4, 1);
INSERT INTO Book_In_Order VALUES ('978-0-7858-1453-5', 4, 1);
INSERT INTO Book_In_Order VALUES ('978-0-7603-3174-3', 5, 1);
INSERT INTO Book_In_Order VALUES ('0-7603-1056-4', 5, 1);
INSERT INTO Book_In_Order VALUES ('9798595265973', 6, 1);  -- 95
INSERT INTO Book_In_Order VALUES ('0-393-04002-X', 6, 1);
INSERT INTO Book_In_Order VALUES ('978-083761615-5', 7, 4);

-- Store

INSERT INTO Store VALUES (1, 'AK', 'Cambridge St', 99901, 'Ketchikan');
INSERT INTO Store VALUES (2, 'MN', 'McKees Rd', 56537, 'Winchester');

-- Book_In_Store

INSERT INTO Book_In_Store VALUES ('978-1-59059-239-7', 1, 6);  -- 100
INSERT INTO Book_In_Store VALUES ('978-0-764-57481-8', 1, 3);
INSERT INTO Book_In_Store VALUES ('978-1-59327-283-8', 1, 2);
INSERT INTO Book_In_Store VALUES ('9798595265973', 1, 1);
INSERT INTO Book_In_Store VALUES ('0-393-04002-X', 1, 4);
INSERT INTO Book_In_Store VALUES ('978-0-7603-3174-3', 1, 3);  -- 105
INSERT INTO Book_In_Store VALUES ('978-1-78404-91604', 1, 4);
INSERT INTO Book_In_Store VALUES ('0-7603-1056-4', 2, 3);
INSERT INTO Book_In_Store VALUES ('978-0-7858-1453-5', 2, 2);
INSERT INTO Book_In_Store VALUES ('978-083761615-5', 2, 3);
INSERT INTO Book_In_Store VALUES ('9798595265973', 2, 3);  -- 110
INSERT INTO Book_In_Store VALUES ('0-393-04002-X', 2, 2);

-- Employee

INSERT INTO Employee VALUES (1, 'Benjamin', 'Nguyen', NULL, 1);
INSERT INTO Employee VALUES (2, 'Gabbie', 'White', 1, 1);
INSERT INTO Employee VALUES (3, 'Martin', 'Cobian', 2, 1);
INSERT INTO Employee VALUES (4, 'Maria', 'Zamora', 2, 1);  --  115
INSERT INTO Employee VALUES (5, 'Horatio', 'Nelson', 2, 1);
INSERT INTO Employee VALUES (6, 'Jacob,', 'Danvers', 1, 2);
INSERT INTO Employee VALUES (7, 'Billy', 'Creole', 6, 2);
