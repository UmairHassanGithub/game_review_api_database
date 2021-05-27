const   mysql = require("mysql");


const connection = mysql.createConnection({
    host: "localhost",
    user: "game_review_user",
    password: "password",
    database: "game_review"
});

connection.connect(error => {
    if (error) throw error;
    console.log("Sucessfully connected to MySQL database!");
});


module.exports = connection;