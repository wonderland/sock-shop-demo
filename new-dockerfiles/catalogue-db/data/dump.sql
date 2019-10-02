CREATE USER IF NOT EXISTS 'catalogue_user' IDENTIFIED BY 'default_password';

GRANT ALL ON socksdb.* TO 'catalogue_user';

CREATE TABLE IF NOT EXISTS sock (
	sock_id varchar(40) NOT NULL, 
	name varchar(20), 
	description varchar(200), 
	price float, 
	count int, 
	image_url_1 varchar(40), 
	image_url_2 varchar(40), 
	PRIMARY KEY(sock_id)
);

CREATE TABLE IF NOT EXISTS tag (
	tag_id MEDIUMINT NOT NULL AUTO_INCREMENT, 
	name varchar(20), 
	PRIMARY KEY(tag_id)
);

CREATE TABLE IF NOT EXISTS sock_tag (
	sock_id varchar(40), 
	tag_id MEDIUMINT NOT NULL, 
	FOREIGN KEY (sock_id) 
		REFERENCES sock(sock_id), 
	FOREIGN KEY(tag_id)
		REFERENCES tag(tag_id)
);

INSERT INTO sock VALUES ("6d62d909-f957-430e-8689-b5129c0bb75e", "NetApp Endurance", "For the perfect data workout. Recommended for your next data center migration.", 17.15, 33, "/catalogue/images/endurance.jpg", "/catalogue/images/endurance.jpg");
INSERT INTO sock VALUES ("a0a4f044-b040-410d-8ead-4de0446aec7e", "HCI Nerd", "Hybrid Cloud Infrastructure - revenge of the nerds.", 7.99, 115, "/catalogue/images/hci.jpg", "/catalogue/images/hci.jpg");
INSERT INTO sock VALUES ("808a2de1-1aaa-4c25-a9b9-6612e8f29a38", "Control Freak", "Control those IOPS.",  17.32, 738, "/catalogue/images/solidfire.png", "/catalogue/images/solidfire2.jpg");
INSERT INTO sock VALUES ("510a0d7e-8e83-4193-b483-e27e09ddc34d", "Nation", "Social Media at its best. Twitter like never before with these socks! ",  15.00, 820, "/catalogue/images/nation.jpg", "/catalogue/images/nation.jpg");
INSERT INTO sock VALUES ("03fef6ac-1896-4ce8-bd69-b798f85c6e0b", "HCI", "Are you ready?",  99.99, 1, "/catalogue/images/hci_next.jpg", "/catalogue/images/hci_next.jpg");

INSERT INTO tag (name) VALUES ("red");
INSERT INTO tag (name) VALUES ("solidfire");
INSERT INTO tag (name) VALUES ("hci");
INSERT INTO tag (name) VALUES ("action");
INSERT INTO tag (name) VALUES ("blue");
INSERT INTO tag (name) VALUES ("nerd");
INSERT INTO tag (name) VALUES ("sport");


INSERT INTO sock_tag VALUES ("6d62d909-f957-430e-8689-b5129c0bb75e", "4");
INSERT INTO sock_tag VALUES ("6d62d909-f957-430e-8689-b5129c0bb75e", "7");
INSERT INTO sock_tag VALUES ("a0a4f044-b040-410d-8ead-4de0446aec7e", "3");
INSERT INTO sock_tag VALUES ("a0a4f044-b040-410d-8ead-4de0446aec7e", "5");
INSERT INTO sock_tag VALUES ("a0a4f044-b040-410d-8ead-4de0446aec7e", "6");
INSERT INTO sock_tag VALUES ("808a2de1-1aaa-4c25-a9b9-6612e8f29a38", "2");
INSERT INTO sock_tag VALUES ("808a2de1-1aaa-4c25-a9b9-6612e8f29a38", "1");
INSERT INTO sock_tag VALUES ("808a2de1-1aaa-4c25-a9b9-6612e8f29a38", "7");
INSERT INTO sock_tag VALUES ("510a0d7e-8e83-4193-b483-e27e09ddc34d", "5");
INSERT INTO sock_tag VALUES ("03fef6ac-1896-4ce8-bd69-b798f85c6e0b", "3");




