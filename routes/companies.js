const   express = require("express"),
        router = express.Router({ mergeParams: true }),
        connection = require("../db"),
        middleware = require("../middleware/index");

//Index Route
router.get("/", function (req, res) {
    console.log(req.query);
    if (Object.keys(req.query).length === 0) {
        connection.query("CALL View_Companies()", function (error, results, fields) {
            res.json(results[0]);
        });
    }
    else {
        console.log(req.query.search);
        let search = connection.escape(req.query.search);
        if (typeof search === "string" && search) {
            let query = "CALL Search_Company(" + search + ")";
            connection.query(query, function (error, results, fields) {
                if (error) {
                    res.status(500);
                    res.json({ error: error });
                } else {
                    res.json(results[0]);
                }
            });
        }
        else {
            res.status(422);
            res.json({ message: "Not a valid query!" });
        }
    }


});


//Show Route
router.get("/:name", middleware.companyExist, function (req, res) {
    let name = connection.escape(req.params.name);
    if (typeof name === "string" && name) {
        let query = "CALL View_Company(" + name + ")";
        connection.query(query, function (error, results, fields) {
            if (error) {
                res.status(500);
                res.json({ error: error });
            }
            else {
                res.json(results[0]);    
            }
        });
    }
});


//Create Route
router.post("/", middleware.isAdmin, function(req, res) {
    if (req.body.name && req.body.bio && req.body.est && req.body.type && req.body.dFlag && req.body.pFlag) {
        let name = connection.escape(req.body.name);
        let bio = connection.escape(req.body.bio);
        let est = connection.escape(req.body.est);
        let type = connection.escape(req.body.type);
        let dFlag = (connection.escape(req.body.dFlag) == "'True'");
        let pFlag = (connection.escape(req.body.pFlag) == "'True'");

        let query = "CALL Add_Company(" + name + ", " + bio + ", " + est + ", " + type + ", " + dFlag + ", " + pFlag + ")";
        connection.query(query, function(error, results) {
            if (error) {
                res.status(500);
                res.json({error: error});
            }
            else {
                res.json({message: "Added company to db"});
            }
        });
    }
    else {
        res.status(422);
        res.json({ message: "Body is not well defined" });
    }
});

//Update Route
router.put("/:name", middleware.companyExist, middleware.isAdmin, function (req, res) {
    let name = connection.escape(req.params.name);
    if (req.body.bio) {
        let bio = connection.escape(req.body.bio);

        let query = "CALL Edit_Company_Bio(" + name + "," + bio + ")";
        connection.query(query, function(error, results) {
            if (error) {
                res.status(500);
                res.json({error:error});
            }
            else {
                res.json({message: "Company bio edited"});
            }
        });
    }
    else {
        res.status(422);
        res.json({ message: "Body is not well defined" });
    }    
});

//Delete Route

module.exports = router;