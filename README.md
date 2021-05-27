# game_review_api_database
# cpsc471-project
### Members
* Robert Toh (30040821)
* William Chan (30041834)
* Umair Hassan (30047693)

 
### Requirements
* Node.js
* MySQLv8.0 or above
* MySQL Workbench -> alternatively, you may use a MySQL shell, but our instructions will assume otherwise

### Setup
1. Make sure Node.js, MySQL and MySQL Workbench are installed. 
2. Download the github repository/source code.
3. Open the root/main folder in a terminal and type _npm install_ to install the required packages.
4. In MySQL Workbench, import _dbschema.sql_ under the Data Import/Restore under the Administration tab 
5. Start the MySQL server under Startup/Shutdown
6. Start the API server by typing _node api.js_ into the terminal

    1. If an error appears specifying "_Client does not support authentication protocol requested by server_", you will need to reconfigure the MySQL server to use legacy authentication.
    2. If for some reason you cannot connect to the database with the preconfigured user in _dbschema.sql_, edit the credentials in _db.js_ to a user that works for you.
7. Send requests to the API - refer to https://documenter.getpostman.com/view/13660620/TVmMgdUo for documentation on using the API.
