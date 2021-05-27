DROP DATABASE IF EXISTS game_review;
CREATE DATABASE IF NOT EXISTS game_review;
USE game_review;

DROP TABLE IF EXISTS Game;
CREATE TABLE Game (
    ID int unsigned NOT NULL AUTO_INCREMENT,
    Title varchar(255) NOT NULL,
    Admin_username varchar(255) NOT NULL,
    Employee_id int unsigned NOT NULL,
    Added_date timestamp  DEFAULT CURRENT_TIMESTAMP,
    Description text,
    Score double DEFAULT 0,
    Genre varchar(255),
    Create_date date,
    Publish_date date,
    Pub_name varchar(255),
    Dev_name varchar(255),
    deleted bool DEFAULT False,
    PRIMARY KEY (ID)
);

DROP TABLE IF EXISTS Company;
CREATE TABLE Company (
    Name varchar(255) NOT NULL,
    Bio text,
    Established date,
    Type varchar(255),
    Dev_flag bool,
    Pub_flag bool,
    PRIMARY KEY (Name)
);

DROP TABLE IF EXISTS Works_with;
CREATE TABLE Works_with (
    Dev_name varchar(255) NOT NULL,
    Pub_name varchar(255) NOT NULL,
    Game_ID int unsigned NOT NULL,
    CONSTRAINT pk_Works PRIMARY KEY (Dev_name, Pub_name, Game_ID)
);

DROP TABLE IF EXISTS Review;
CREATE TABLE Review (
    Game_ID int unsigned NOT NULL,
    Review_ID int NOT NULL /*AUTO_INCREMENT*/,
    Username varchar(255),
    Rating int,
    Content text,
    Date timestamp  DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_Review PRIMARY KEY (Game_ID, Review_ID),
    INDEX (Review_ID)
);

DELIMITER //
CREATE TRIGGER newReviewID BEFORE INSERT ON Review
FOR EACH ROW BEGIN
    SET NEW.Review_ID = (
       SELECT IFNULL(MAX(Review_ID), 0) + 1
       FROM Review
       WHERE Game_ID = NEW.Game_ID
    );
END//
DELIMITER ;

DROP TABLE IF EXISTS User;
CREATE TABLE User (
    Username varchar(255) NOT NULL,
    Display_name varchar(255) UNIQUE,
    PRIMARY KEY (Username)
);

DROP TABLE IF EXISTS Profile;
CREATE TABLE Profile(
    Username varchar(255) NOT NULL,
    Profile_picture varchar(255),
    Bio text,
    PRIMARY KEY (Username)
);

DROP TABLE IF EXISTS Likes;
CREATE TABLE Likes (
    Game_ID int unsigned NOT NULL,
    Review_ID int NOT NULL,
    Account_Username varchar(255) NOT NULL,
    CONSTRAINT pk_Likes PRIMARY KEY (Game_ID, Review_ID, Account_Username)
);

DROP TABLE IF EXISTS Admin;
CREATE TABLE Admin (
    Username varchar(255) NOT NULL,
    Employee_id int unsigned NOT NULL /*AUTO_INCREMENT*/,
    INDEX (Employee_id),
    CONSTRAINT pk_admin PRIMARY KEY (Username, Employee_id)
);

DELIMITER //
CREATE TRIGGER newEmpID BEFORE INSERT ON Admin
FOR EACH ROW BEGIN
    SET NEW.Employee_id = (
       SELECT IFNULL(MAX(Employee_id), 0) + 1
       FROM Admin
    );
END//
DELIMITER ;

DROP TABLE IF EXISTS Account;
CREATE TABLE Account (
    Username varchar(255) NOT NULL,
    Email varchar(255),
    Password varchar(255) NOT NULL,
    PRIMARY KEY (Username)
);

DROP TABLE IF EXISTS Awards;
CREATE TABLE Awards (
    Game_ID int unsigned NOT NULL,
    Name varchar(255) NOT NULL,
    icon varchar(255),
    CONSTRAINT pk_awards PRIMARY KEY (Game_ID, Name)
);

DROP TABLE IF EXISTS Removes;
CREATE TABLE Removes (
    Game_ID int unsigned NOT NULL,
    Admin_username varchar(255) NOT NULL,
    Employee_id int unsigned NOT NULL,
    Remove_date timestamp  DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_Removes PRIMARY KEY (Game_ID, Admin_username, Employee_id)
);

ALTER TABLE Admin
    ADD CONSTRAINT fk_admin_username FOREIGN KEY (Username) REFERENCES Account(Username) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE Game
    ADD CONSTRAINT fk_game_adminuser FOREIGN KEY (Admin_username) REFERENCES Admin(Username) ON DELETE RESTRICT ON UPDATE CASCADE,
    ADD CONSTRAINT fk_game_adminid FOREIGN KEY (Employee_id) REFERENCES Admin(Employee_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ADD CONSTRAINT fk_game_publisher FOREIGN KEY (Pub_name) REFERENCES Company(Name) ON DELETE RESTRICT ON UPDATE CASCADE,
    ADD CONSTRAINT fk_game_developer FOREIGN KEY (Dev_name) REFERENCES Company(Name) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE Works_with
    ADD CONSTRAINT fk_works_dev FOREIGN KEY (Dev_name) REFERENCES Company (Name) ON DELETE RESTRICT ON UPDATE CASCADE,
    ADD CONSTRAINT fk_works_pub FOREIGN KEY (Pub_name) REFERENCES Company (Name) ON DELETE RESTRICT ON UPDATE CASCADE,
    ADD CONSTRAINT fk_works_game FOREIGN KEY (Game_ID) REFERENCES Game (ID) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE Review
    ADD CONSTRAINT fk_review_game FOREIGN KEY (Game_ID) REFERENCES Game (ID) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE User
    ADD CONSTRAINT fk_user_username FOREIGN KEY (Username) REFERENCES Account (Username) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE Profile
    ADD CONSTRAINT fk_profile_username FOREIGN KEY (Username) REFERENCES User (Username) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE Likes
    ADD CONSTRAINT fk_lIkes_game FOREIGN KEY (Game_ID) REFERENCES Review(Game_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_likes_review FOREIGN KEY (Review_ID) REFERENCES Review(Review_ID) ON DELETE RESTRICT ON UPDATE CASCADE,
    ADD CONSTRAINT fk_likes_account FOREIGN KEY (Account_Username) REFERENCES User(Username) ON DELETE RESTRICT ON UPDATE CASCADE;


ALTER TABLE Awards
    ADD CONSTRAINT fk_awards_game FOREIGN KEY (Game_ID) REFERENCES Game (ID) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE Removes
    ADD CONSTRAINT fk_removes_game FOREIGN KEY (Game_ID) REFERENCES Game (ID) ON DELETE RESTRICT ON UPDATE CASCADE,
    ADD CONSTRAINT fk_removes_admin FOREIGN KEY (Admin_username) REFERENCES Admin (Username) ON DELETE RESTRICT ON UPDATE CASCADE,
    ADD CONSTRAINT fk_removes_employee FOREIGN KEY (Employee_id) REFERENCES Admin (Employee_id) ON DELETE RESTRICT ON UPDATE CASCADE;

-- STORED PROCEDURES
-- Add a new review to the database
DELIMITER //
CREATE PROCEDURE Add_Review (
    IN vGame_ID int,
    IN vUsername varchar(255),
    IN vRating int,
    IN vContent varchar(255)
)
BEGIN
    INSERT INTO Review (Game_ID,  Username, Rating, Content)
    VALUES(vGame_ID, vUsername, vRating, vContent);

    SELECT AVG(Rating)
    FROM Review
    WHERE Game_ID = vGame_ID
    LIMIT 1000
    INTO @score;
    
    UPDATE Game
    SET Score = @score
    WHERE ID = vGame_ID;
END//
DELIMITER ;

-- Add a company to the database, type refers to the type of company (ex. AAA)
DELIMITER //
CREATE PROCEDURE Add_Company (
    IN vName varchar(255),
    IN vBio text,
    IN vEstablished date,
    IN vType varchar(255),
    IN vDev_flag bool,
    IN vPub_flag bool
)
BEGIN
    INSERT INTO Company (Name, Bio, Established, Type, Dev_flag, Pub_flag)
    VALUES (vName, vBio, vEstablished, vType, vDev_flag, vPub_flag);
END//
DELIMITER ;

-- Add a game to the database
DELIMITER //
CREATE PROCEDURE Add_Game (
    IN vTitle varchar(255),
    IN vAdmin_username varchar(255),
    IN vEmployee_id int,
    IN vDescription text,
    IN vGenre varchar(255),
    IN vCreate_date date,
    IN vPublish_date date,
    IN vPub_name varchar(255),
    IN vDev_name varchar(255)
)
BEGIN
    INSERT INTO Game (Title, Admin_username, Employee_id, Description, Genre, Create_date, Publish_date, Pub_Name, Dev_Name)
    VALUES( vTitle, vAdmin_username, vEmployee_id, vDescription, vGenre, vCreate_date, vPublish_date, vPub_name, vDev_name);
END//
DELIMITER ;

-- Modifies user bio in the database
DELIMITER //
CREATE PROCEDURE Edit_Profile_Bio (
    IN vUsername varchar(255),
    IN vBio text
)
BEGIN
    UPDATE Profile
    SET Bio = vBio
    WHERE Username = vUsername;
END//
DELIMITER ;

-- Changes user profile pic in the database, expects vPic to be a url
DELIMITER //
CREATE PROCEDURE Edit_Profile_Pic (
    IN vUsername varchar(255),
    IN vPic varchar(255)
)
BEGIN
    UPDATE Profile
    SET Profile_picture = vPic
    WHERE Username = vUsername;
END//
DELIMITER ;

-- Modifies a game’s description in the database
DELIMITER //
CREATE PROCEDURE Edit_Game_Descr (
    IN vID int,
    IN vDescription text
)
BEGIN
    UPDATE Game
    SET Description = vDescription
    WHERE ID = vID;
END//
DELIMITER ;

-- Modifies a game’s title in the database
DELIMITER //
CREATE PROCEDURE Edit_Game_Title (
    IN vID int,
    IN vTitle varchar(255)
)
BEGIN
    UPDATE Game
    SET Title = vTitle
    WHERE ID = vID;
END//
DELIMITER ;

-- Modifies a game’s score in the database
DELIMITER //
CREATE PROCEDURE Edit_Game_Score (
    IN vID int,
    IN vScore int
)
BEGIN
    UPDATE Game
    SET Score = vScore
    WHERE ID = vID;
END//
DELIMITER ;

-- Modifies a company’s bio in the database
DELIMITER //
CREATE PROCEDURE Edit_Company_Bio (
    IN vName varchar(255),
    IN vBio text
)
BEGIN
    UPDATE Company
    SET Bio = vBio
    WHERE Name = vName;
END//
DELIMITER ;

-- Views a profile in the database
DELIMITER //
CREATE PROCEDURE View_Profile (
    IN vUsername varchar(255)
)
BEGIN
    SELECT *
    FROM Profile
    WHERE Username = vUsername
    LIMIT 1000;
END//
DELIMITER ;

-- Return all non-deleted games
DELIMITER //
CREATE PROCEDURE View_All_Games ()
BEGIN
    SELECT *
    FROM Game
    WHERE deleted = False
    ORDER BY Title ASC
    LIMIT 1000;
END//
DELIMITER ;

-- View game with inputted ID
DELIMITER //
CREATE PROCEDURE View_Game_By_ID (
    IN vID int
)
BEGIN
    SELECT *
    FROM Game
    WHERE ID = vID AND deleted = False
    LIMIT 1000;
END//
DELIMITER ;

-- Search for games based on inputted pattern of the title
DELIMITER //
CREATE PROCEDURE Search_Game_Title (
    IN pattern varchar(255)
)
BEGIN
    SELECT *
    FROM Game
    WHERE Title LIKE CONCAT("%", pattern, "%") AND deleted = False
    ORDER BY Title DESC
    LIMIT 1000;
END//
DELIMITER ;

-- Search for games base on score of game, order flag is used to sort the order to sort the games found (ascending or descending)
DELIMITER //
CREATE PROCEDURE Search_Game_Rating (
    IN minRating int,
    IN orderFlag int
)
BEGIN
    IF (orderFlag = 0)  THEN
        SELECT *
        FROM Game
        WHERE Score >= minRating AND deleted = False
        ORDER BY Score ASC
        LIMIT 1000;

    ELSE
        SELECT *
        FROM Game
        WHERE Score >= minRating AND deleted = False
        ORDER BY Score DESC
        LIMIT 1000;

    END IF;
END//
DELIMITER ;

-- Search for games based on inputted genre
DELIMITER //
CREATE PROCEDURE Search_Game_Genre (
    IN vGenre varchar(255)
)
BEGIN
    SELECT *
    FROM Game
    WHERE Genre LIKE CONCAT("%", vGenre, "%") AND deleted = False
    ORDER BY Title DESC
    LIMIT 1000;
END//
DELIMITER ;

-- Views a review of a game in the database
DELIMITER //
CREATE PROCEDURE View_Review (
    IN vGame_ID int
)
BEGIN
    SELECT *
    FROM Review
    WHERE Game_ID = vGame_ID
    LIMIT 1000;
END//
DELIMITER ;

-- View a specific review given game ID and review ID
DELIMITER //
CREATE PROCEDURE View_Review_By_ID (
    IN vGame_ID int,
    IN vReview_ID int
)
BEGIN
    SELECT *
    FROM Review
    WHERE Game_ID = vGame_ID AND Review_ID = vReview_ID
    LIMIT 1000;
END//
DELIMITER ;

-- Searches for a company with inputted name in the database
DELIMITER //
CREATE PROCEDURE Search_Company (
    IN pattern varchar(255)
)
BEGIN
    SELECT *
    FROM Company
    WHERE Name LIKE CONCAT("%", pattern, "%")
    ORDER BY Name DESC
    LIMIT 1000;
END//
DELIMITER ;

-- Views a company in the database specified by vName
DELIMITER //
CREATE PROCEDURE View_Company(
    IN vName varchar(255)
)
BEGIN
    SELECT *
    FROM Company
    WHERE Name = vName
    LIMIT 1000;
END//
DELIMITER ;

-- View all companies in the database
DELIMITER //
CREATE PROCEDURE View_Companies()
BEGIN
    SELECT *
    FROM Company
    LIMIT 1000;
END//
DELIMITER ;

-- Remove a game from the database by setting the game’s deleted flag
DELIMITER //
CREATE PROCEDURE Remove_Game (
    IN vGame_ID int,
    IN vAdmin_username varchar(255),
    IN vEmployee_id int
)
BEGIN
    UPDATE Game
    SET deleted = True
    WHERE (ID = vGame_ID);
    INSERT INTO Removes (Game_ID, Admin_username, Employee_id)
    VALUES (vGame_ID, vAdmin_username, vEmployee_id);
END//
DELIMITER ;

-- Adds a review to the Likes relation
DELIMITER //
CREATE PROCEDURE Like_Review (
    IN vGame_ID int,
    IN vReview_ID int,
    IN vAccount_Username varchar(255)
)
BEGIN
    INSERT INTO Likes (Game_ID, Review_ID, Account_Username)
    VALUES (vGame_ID, vReview_ID, vAccount_Username);
END//
DELIMITER ;

-- Get the data from the Likes table for a specific review
DELIMITER //
CREATE PROCEDURE Get_Likes_Review (
    IN vGame_ID int,
    IN vReview_ID int
)
BEGIN
    SELECT *
    FROM Likes
    WHERE Game_ID = vGame_ID AND Review_ID = vReview_ID
    LIMIT 1000;
END//
DELIMITER ;

-- Return all the reviews written by a specific user
DELIMITER //
CREATE PROCEDURE Get_Reviews_Written (
    IN vAccount_Username varchar(255)
)
BEGIN
    SELECT *
    FROM Review
    WHERE Username = vAccount_Username
    LIMIT 1000;
END//
DELIMITER ;

-- Add a developer and publisher to the Works_With table for a specific game
DELIMITER //
CREATE PROCEDURE Add_Works_With (
    IN vDev_name varchar(255),
    IN vPub_name varchar(255),
    IN vGame_ID int
)
BEGIN
    INSERT INTO Works_With (Dev_name, Pub_name, Game_ID)
    VALUES (vDev_name, vPub_name, vGame_ID);
END//
DELIMITER ;

-- Returns data about a user account specified by vUsername
DELIMITER //
CREATE PROCEDURE Get_Account (
    IN vUsername varchar(255)
)
BEGIN
    SELECT * 
    FROM Account
    WHERE Username = vUsername
    LIMIT 1000;
END//
DELIMITER ;

-- Returns data about a Admin account specified by vUsername
DELIMITER //
CREATE PROCEDURE Get_Admin (
    IN vUsername varchar(255)
)
BEGIN
    SELECT * 
    FROM Admin
    WHERE Username = vUsername
    LIMIT 1000;
END//
DELIMITER ;

-- Add a new user account to the database, give that new user an empty profile
DELIMITER //
CREATE PROCEDURE Add_User (
    IN vUsername varchar(255),
    IN vEmail varchar(255),
    IN vPassword varchar(255),
    IN vDisplayName varchar(255)
)
BEGIN
    INSERT INTO Account (Username, Email, Password)
    VALUES (vUsername, vEmail, vPassword);

    INSERT INTO User (Username, Display_name)
    VALUES (vUsername, vDisplayName);

    INSERT INTO Profile (Username)
    VALUES (vUsername);
END//
DELIMITER ;

-- An to the Award table a new award for a game. vIcon is expected to be a url
DELIMITER //
CREATE PROCEDURE Add_Award (
    IN gameID int,
    IN name varchar(255),
    IN vIcon varchar(255)
)
BEGIN
    INSERT INTO Awards (Game_ID, Name, icon)
    VALUES (gameID, name, vIcon);
END//
DELIMITER ;

-- Get the awards for a game specified by gameID
DELIMITER //
CREATE PROCEDURE Get_Awards (
    IN gameID int
)
BEGIN
    SELECT * 
    FROM Awards
    WHERE Game_ID = gameID
    LIMIT 1000;
END//
DELIMITER ;

-- Returns the data in the Works_With table
DELIMITER //
CREATE PROCEDURE View_Works_With ()
BEGIN
    SELECT *
    FROM Works_With
    LIMIT 1000;
END//
DELIMITER ;

-- Seed the database
DELIMITER //
CREATE PROCEDURE seedDB()
BEGIN
    INSERT INTO Account (Username, Email, Password)
    VALUES ("admin", "admin@email.com", "$2b$10$5EVpsOcPPs7QTrmJBMr5lOtQ6NDffF08X2EFdZiWSO40IjBQ2PxU6"); -- password is "1234"

    INSERT INTO Admin (Username)
    VALUES ("admin");

    CALL Add_User("will", "will@email.com", "$2b$10$9w/CnJPizhhG/D0OWLhKq.RFNPn4FcZdHVLPA9GG/Tms6j5yQxPty", "will"); -- password is "password"

    CALL Add_User("rob", "rob@email.com", "$2b$10$9w/CnJPizhhG/D0OWLhKq.RFNPn4FcZdHVLPA9GG/Tms6j5yQxPty", "rob"); -- password is "password"
    CALL Edit_Profile_Bio("rob", "A normal guy.");
    CALL Edit_Profile_Pic("rob", "https://upload.wikimedia.org/wikipedia/en/thumb/f/f1/Team_Liquid_logo.svg/1200px-Team_Liquid_logo.svg.png");


    CALL Add_Company("Valve", "Valve was founded in 1996 by former Microsoft employees Gabe Newell and Mike Harrington. In 2003, Valve launched Steam, which accounted for around half of digital PC game sales by 2011. By 2012, Valve employed around 250 people and was reportedly worth over US$3 billion, making it the most profitable company per employee in the United States.", 
                                "1996-08-24", "AAA", True, True);
    CALL Add_Company("Innersloth", "A three person indie game developer based in Redmond, WA.", "2015-01-01", "Indie", True, True);
    CALL Add_Company("Respawn Entertainment", "Respawn Entertainment, LLC is an American video game development studio founded by Jason West and Vince Zampella. West and Zampella previously co-founded Infinity Ward and created the Call of Duty franchise, where they were responsible for its development until 2010. The studio created the Titanfall series, as well as the free-to-play battle royale game Apex Legends. Respawn was acquired by Electronic Arts on December 1, 2017, and developed Star Wars Jedi: Fallen Order, which was released in November 2019.",
                                "2010-04-12", "AAA", True, False);
    CALL Add_Company("Electronic Arts", "It is the second-largest gaming company in the Americas and Europe by revenue and market capitalization after Activision Blizzard and ahead of Take-Two Interactive, CD Projekt, and Ubisoft as of May 2020.",
                                "1982-05-27", "AAA", True, True);

    SELECT Employee_id
    FROM Admin
    WHERE Username="admin"
    INTO @id;

    CALL Add_Game("Counter-Strike: Global Offensive", "admin", @id, "Counter-Strike: Global Offensive (CS: GO) expands upon the team-based action gameplay that it pioneered when it was launched 19 years ago.", 
                    "First-Person Shooter", "2012-08-21", "2012-08-21", "Valve", "Valve");
    CALL Add_Game("Among Us", "admin", @id, "An online and local party game of teamwork and betrayal for 4-10 players...in space!",
                    "Casual, Party", "2018-11-16", "2018-11-16", "Innersloth", "Innersloth");
    CALL Add_Game("Apex Legends", "admin", @id, "Apex Legends is the award-winning, free-to-play Battle Royale team shooter from Respawn Entertainment.",
                    "First-Person Shooter, Battle Royale", "2019-02-04", "2019-02-04", "Respawn Entertainment", "Electronic Arts");
    CALL Add_Game("Half-Life 3", "admin", @id, "It's never going to come out.", "N/A", "2077-04-20", "2077-04-20", "Valve", "Valve");

    CALL Add_Award(3, "2019 Golden Joystick Awards - Best Multiplayer", "https://estnn.com/wp-content/uploads/2019/11/apex-golden-joystick-1024x576.jpg");

    CALL Add_Works_With("Respawn Entertainment", "Electronic Arts", 3);

    CALL Add_Review(1, "rob", 10, "This is the most enjoyable competitive game I've played. It's brought me 6 years of fun!");

    CALL Like_Review(1, 1, "will");

    CALL Remove_Game(4, "admin", 1);


END//
DELIMITER ;


CALL seedDB();

-- Add new user
CREATE USER IF NOT EXISTS 'game_review_user'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON game_review . * TO 'game_review_user'@'localhost';
FLUSH PRIVILEGES;
