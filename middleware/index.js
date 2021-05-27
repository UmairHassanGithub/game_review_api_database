const connection = require("../db");

let middlewareObj = {};


middlewareObj.isLoggedIn = function(req, res, next) {
    if (!req.user) {
        res.status(401);
        res.json({message: "You need to be logged in to access this"});
        return;
    }
    return next();
}

middlewareObj.isAdmin = function(req, res, next) {
    if (!req.user) {
        res.status(401);
        res.json({ message: "You need to be logged in to access this" });
        return;
    }
    else {
        //Check user is an admin
        let user = connection.escape(req.user.Username);
        let query = "CALL Get_Admin(" + user + ")";
        connection.query(query, function(error, results) {
            if (error) {res.json({error: error});}
            if (!results[0].length) {
                res.status(403);
                res.json({message: "You are not an adminstrator"});
                return;
            }
            else {
                res.locals.adminID = results[0][0].Employee_id;
                return next();
            }
        });
    }
}

middlewareObj.gameExist = function(req, res, next) {
    let id = parseInt(req.params.id, 10);
    if (!Number.isNaN(id)) {
        let query = "CALL View_Game_By_ID(" + connection.escape(id) + ")";
        connection.query(query, function (error, results, fields) {
            if (error) {res.json({error: error});}
            if (!results[0].length) {
                //Game not found
                res.status(404);
                res.json({message: "This game does not exist"});
                return;
            }
            else {
                return next();
            }
        });
    }
    else {
        res.status(400);
        res.json({ message: "Not a valid id!" });
    }
}

middlewareObj.companyExist = function(req, res, next) {
    let name = connection.escape(req.params.name);
    let query = "CALL View_Company(" + name + ")";
    connection.query(query, function (error, results, fields) {
        if (error) {res.json({error: error});}
        if (!results[0].length) {
            //Company not found
            res.status(404);
            res.json({message: "This company does not exist"});
            return;
        }
        else {
            return next();
        }
    });
}

middlewareObj.profileExist = function(req, res, next) {
    let user = connection.escape(req.params.username);
    let query = "CALL View_Profile(" + user + ")";
    connection.query(query, function (error, results) {
        if (error) {
            res.status(500);
            res.json({ error: error });
        }
        if (!results[0].length) {
            //No profile found
            res.status(404);
            res.json({message: "This profile does not exist"});
        }
        else {
            res.locals.profile = results[0];
            return next();
        }
    });
}

module.exports = middlewareObj;