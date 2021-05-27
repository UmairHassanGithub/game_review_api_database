const   express = require("express"),
        router = express.Router({mergeParams: true}),
        connection = require("../db"),
        passport = require("passport"),
        bcrypt = require("bcrypt");

//View Works_With
router.get("/api/works_with", function(req, res){
    connection.query("CALL View_Works_With()", function(error,  results) {
        if (error) {
            res.status(500);
            res.json({error: error});
        }
        else {
            res.json(results[0]);
        }
    });
});

//Auth Routes

//Register Logic
router.post("/api/register", function(req, res, next) {
    let query = "CALL Get_Account(" + connection.escape(req.body.username) + ")";
    connection.query(query, function (error, results, fields) {
        if (error) {
            res.status(500);
            res.json({error: error});
        }
        if (!results[0].length) {
            bcrypt.hash(connection.escape(req.body.password), 0, (err, hash) => {
                if (err) {
                    res.status(500);
                    res.json({error: err});
                }
                let cmd = "CALL Add_User(" + connection.escape(req.body.username) + ", " + connection.escape(req.body.email) + ", "
                                       + connection.escape(hash) + ", " + connection.escape(req.body.displayName) + ")";

                connection.query(cmd, function(error, results, fields) {
                    if (error) {
                        res.status(500);
                        res.json({error: error});
                    }
                    else {
                        passport.authenticate('local', function (err, user, info) {
                            if (err) {
                                return next(err);
                            }
                            if (!user) {
                                res.status(422);
                                return res.json({ message: "Credentials are incorrect" });
                            }
                            req.logIn(user, function (err) {
                                if (err) { return next(err); }
                                return res.json({ message: "Logged in as " + req.body.username });
                            });
                        })(req, res, next);
                    }
                });
            });
            
        }
        else {
            res.status(500);
            res.json({message: "Username already taken"})
        }
        

    });

});

//Login Logic
router.post("/api/login", function (req, res, next) {
    passport.authenticate('local', function (err, user, info) {
        if (err) { 
            return next(err); 
        }
        if (!user) {
            res.status(422); 
            return res.json({message: "Credentials are incorrect"}); 
        }
        req.logIn(user, function (err) {
            if (err) { return next(err); }
            return res.json({message: "Logged in as " + req.body.username});
        });
    })(req, res, next);
});

//Logout
router.get("/api/logout", function(req, res) {
    req.logout();
    res.json({message: "Logged out"});
});

module.exports = router;