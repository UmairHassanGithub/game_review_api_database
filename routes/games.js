const   express = require("express"),
        router = express.Router(),
        connection = require("../db"),
        middleware = require("../middleware/index");



//Index Route
router.get("/", function (req, res) {
    if (Object.keys(req.query).length === 0) {
        connection.query("CALL View_All_Games()", function (error, results, fields) {
            if (error) {
                res.status(500);
                res.json({error: error});
            } else {
                res.json(results[0]);
            }
        });
    } else if (req.query.title != undefined) {
        var pattern = req.query.title;
        var qresult = "CALL Search_Game_Title(" + connection.escape(pattern) + ")";
        connection.query(qresult, function (error, results, fields) {
            if (error) {
                res.status(500);
                res.json({error: error});
            } else {
                res.json(results[0]);
            }
        });
    } else if (req.query.score != undefined) {
        var score = req.query.score;
        if (req.query.order == undefined || req.query.order == 1) {
            var qresult = "CALL Search_Game_Rating(" + score + ",1)";
        }
        else {
            var qresult = "CALL Search_Game_Rating(" + score + ",0)";
        }
        connection.query(qresult, function (error, results, fields) {
            if (error) {
                res.status(500);
                res.json({error: error});
            } else {
                res.json(results[0]);
            }
        });
    } else if (req.query.genre != undefined) {
        var genre = req.query.genre;
        var qresult = "CALL Search_Game_Genre(" + connection.escape(genre) + ")";
        connection.query(qresult, function (error, results, fields) {
            if (error) {
                res.status(500);
                res.json({error: error});
            } else {
                res.json(results[0]);
            }
        });
    }
    else {
        console.log(req.query.title);
    }


});

//Create Route
router.post("/", middleware.isAdmin, function(req, res){
    if (req.body.title && req.body.desc && req.body.genre && req.body.cDate && req.body.pDate && req.body.pubName && req.body.devName) {
        let title = connection.escape(req.body.title);
        let adminUser = connection.escape(req.user.Username);
        let adminID = res.locals.adminID;
        let desc = connection.escape(req.body.desc);
        let genre = connection.escape(req.body.genre);
        let cDate = connection.escape(req.body.cDate);
        let pDate = connection.escape(req.body.pDate);
        let pName = connection.escape(req.body.pubName);
        let dName = connection.escape(req.body.devName);

        let query = "CALL Add_Game(" + title + ", " + adminUser + ", " + adminID + ", " + desc + ", " + genre + ", " +
                                        cDate + ", " + pDate + ", " + pName + ", " + dName + ")";
        connection.query(query, function(error, results){
            if (error) {
                res.status(500);
                res.json({error: error});
            }
            else {
                res.json({message: "Added game to db"});
            }
        });
    }
    else {
        res.status(422);
        res.json({message: "Body is not well defined"})
    }
});

//Show Route
router.get("/:id", middleware.gameExist, function (req, res) {
    let id = parseInt(req.params.id, 10);
    let query = "CALL View_Game_By_ID(" + connection.escape(id) + ")";
    connection.query(query, function (error, results, fields) {
        if (error) {
            res.status(500);
            res.json({error: error});
        }
        else {
            res.json(results[0]);
        }
    });
});

//Update Route
router.put("/:id", middleware.gameExist, middleware.isAdmin, function(req, res) {
    let id = parseInt(req.params.id, 10);
    if (req.body.title) {
        let query = "CALL Edit_Game_Title(" + connection.escape(id) + ", " + connection.escape(req.body.title) + ")";
        connection.query(query, function (error, results, fields) {
            if (error) {
                res.status(500);
                res.json({error: error});
            }
        });
    }
    if (req.body.desc) {
        let query = "CALL Edit_Game_Descr(" + connection.escape(id) + ", " + connection.escape(req.body.desc) + ")";
        connection.query(query, function (error, results, fields) {
            if (error) {
                res.status(500);
                res.json({error: error});
            }
        });

    }
    
    res.json({message: "Edited game."});
});


//Delete Route
router.delete("/:id", middleware.gameExist, middleware.isAdmin, function(req, res){
    let id = parseInt(req.params.id, 10);
    let adminUser = connection.escape(req.user.Username);
    let adminID = res.locals.adminID;
    let query = "CALL Remove_Game(" + id + ", " + adminUser + ", " + adminID + ")";
    connection.query(query, function(error, results) {
        if (error) {
            res.status(500);
            res.json({error: error});
        }
        else {
            res.json({ message: "Deleted game" });
        }
    });
});

//Works With Route
router.post("/:id", middleware.gameExist, middleware.isAdmin, function(req, res) {
    let id = parseInt(req.params.id, 10);
    if (req.body.dev && req.body.pub) {
        let dev = connection.escape(req.body.dev);
        let pub = connection.escape(req.body.pub);

        let query = "CALL Add_Works_With(" + dev + "," + pub + "," + id + ")";
        connection.query(query, function(error, results) {
            if (error) {
                res.status(500);
                res.json({error: error});
            }
            else {
                res.json({message: "Added to works with table"});
            }
        });
    }
    else {
        res.status(422);
        res.json({ message: "Body is not well defined" })
    }
});

module.exports = router;
