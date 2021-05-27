const   express = require("express"),
        bodyParser = require("body-parser"),
        mysql = require("mysql"),
        app = express(),
        connection = require("./db"),
        passport = require("passport"),
        LocalStrategy = require("passport-local"),
        bcrypt = require("bcrypt");


//Routes
const   gameRoutes = require("./routes/games"),
        reviewRoutes = require("./routes/reviews"),
        companyRoutes = require("./routes/companies"),
        indexRoutes = require ("./routes/index"),
        awardRoutes = require("./routes/awards"),
        profileRoutes = require("./routes/profile");

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: true}));


//Passport Setup
app.use(require("express-session")({
    secret: "This is my secret",
    resave: false,
    saveUninitialized: false
}));
app.use(passport.initialize());
app.use(passport.session());
passport.serializeUser(function(user, done){
    done(null, user.Username);
});
passport.deserializeUser(function(username, done){

    done(null, {Username: username});
});
passport.use(new LocalStrategy(function(username, password, done){
    let query = "CALL Get_Account(" + connection.escape(username) + ")";
    connection.query(query, function(error, results, fields){
        if (error) {
            console.log(error);
            return done(error);
        }
        if (!results[0].length) {
            return done(null, false, {message: "No user found"});
        }

        bcrypt.compare(connection.escape(password), results[0][0].Password, function(err, res) {
            if (res == true) {
                return done(null, results[0][0]);
            }
            else {
                return done(null, false, { message: "Wrong password" });
            }
        });
        
    });
}));


//Use Routes
app.use("/api/games/", gameRoutes);
app.use("/api/games/:id/reviews", reviewRoutes);
app.use("/api/companies/", companyRoutes);
app.use("/api/games/:id/awards", awardRoutes);
app.use("/api/profile", profileRoutes);
app.use(indexRoutes); 

//Start server
app.listen(3000, function(){
    console.log("Server started on port 3000");
})


