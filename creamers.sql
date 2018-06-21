/*Creates table with dairy dummy*/
CREATE TABLE dairy (
dim_group_key TEXT,
dairy INTEGER,
PRIMARY KEY(dim_group_key));


/*Creates table with flavor dummy*/
CREATE TABLE flavor (
dim_group_key TEXT,
flavor INTEGER,
PRIMARY KEY(dim_group_key));


/*Creates table with brand dummies
leaves out BA (i.e. 0000)*/
CREATE TABLE brand(
dim_group_key TEXT,
CM INTEGER,
DD INTEGER,
ID INTEGER,
PL INTEGER,
PRIMARY KEY(dim_group_key));


/*creates table with size dummy (000 is 16 oz)*/
CREATE TABLE prod_size (
dim_group_key TEXT,
`s32` INTEGER,
`s64` INTEGER,
`s48` INTEGER,
PRIMARY KEY(dim_group_key));


/* Create the main table in SQL*/
CREATE TABLE group_edps (
dim_group_key TEXT,
dim_cta_key TEXT,
week INTEGER,
price REAL,
edp REAL,
eq_vol REAL,
PRIMARY KEY(dim_cta_key, dim_group_key, week)
FOREIGN KEY (dim_group_key) REFERENCES dairy(dim_group_key)
FOREIGN KEY (dim_group_key) REFERENCES flavor(dim_group_key)
FOREIGN KEY (dim_group_key) REFERENCES brand(dim_group_key)
FOREIGN KEY (dim_group_key) REFERENCES size(dim_group_key)
FOREIGN KEY (dim_cta_key) REFERENCES groups(dim_cta_key)
);



