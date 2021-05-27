const   express = require("express"),
        router = express.Router({mergeParams: true}),
        connection = require("../db"),
        middleware = require("../middleware/index");


//Index Route
router.get("/", middleware.gameExist, function(req, res){
    let id = parseInt(req.params.id, 10);
    let query = "CALL Get_Awards(" + connection.escape(id) + ")";
    connection.query(query, function (error, results, fields) {
        if (error) {
            res.status(500);
            res.json({ error: error });
        }
        else {
            res.json(results[0]);
        }
    }); 
});

//Create Route
router.post("/", middleware.gameExist, middleware.isAdmin, function(req, res) {
    if (req.body.name == undefined || req.body.icon == undefined) {
        res.status(422);
        res.json({ message: "Incorrect body" });
    }
    else {
        let id = parseInt(req.params.id, 10);
        let name = connection.escape(req.body.name);
        let icon, iconURL;
        try {
            icon = req.body.icon;
            iconURL = connection.escape(new URL(icon).href);
        }
        catch(_) {
            res.status(415);
            res.json({message: "Icon is not a url"});
            return;
        }
        let query = "CALL Add_Award(" + id + ", " + name + ", " + iconURL + ")";
        connection.query(query, function(error, results) {
            if (error) {
                res.status(500);
                res.json({ error: error });
            }
            else {
                res.json({message: "Added award"});
            }
        });
        
    }
});

module.exports = router;