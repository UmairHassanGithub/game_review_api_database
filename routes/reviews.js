const   express = require("express"),
        router = express.Router({mergeParams: true}),
        connection = require("../db"),
        middleware = require("../middleware/index");
        

//Index
router.get("/", middleware.gameExist, function(req, res){
    let id = parseInt(req.params.id, 10);
    let query = "CALL View_Review(" + connection.escape(id) + ")";
    connection.query(query, function(error, results, fields){
        if (error) {
            res.status(500);
            res.json({error: error});
        }
        else {
            res.json(results[0]);
        }
    });
});

//Show Route
router.get("/:review_id", middleware.gameExist, function(req, res) {
    let id = parseInt(req.params.id, 10);
    let review_id = parseInt(req.params.review_id, 10);
    if (!Number.isNaN(review_id)) {
        let query = "CALL View_Review_By_ID(" + connection.escape(id) + ", " + connection.escape(review_id) + ")";
        connection.query(query, function (error, results, fields) {
            if (error) {
                res.status(500);
                res.json({error: error});
            }
            else {
                res.json(results[0]);
            }
        });
    }
    else {
        res.status(422);
        res.json({ message: "Review ID needs to be a number" });
    }
});

//Create Route
router.post("/", middleware.gameExist, middleware.isLoggedIn, function(req, res){
    
    if (req.body.content == undefined || req.body.rating == undefined) {
        res.status(422);
        res.json({message: "Incorrect body"});
    }
    else {
        let id = parseInt(req.params.id, 10);
        let rating = parseInt(req.body.rating, 10);
        let content = req.body.content;
        if (!Number.isNaN(rating) && typeof content == "string") {
            let query = "CALL Add_Review("+ connection.escape(id) + ", " + connection.escape(req.user.Username) + ", " +
            rating + ", " + connection.escape(content) + ")"; 

            connection.query(query, function(error, results, fields) {
                if (error) {
                    res.status(500);
                    res.json({error: error});
                }
                else {
                    res.json({message: "Sucessfully added review"});
                }
            });
        }
        else {
            res.status(422);
            res.json({message: "Body is not well-defined"});
        }
    }
    
    
});

//Like Review Route
router.post("/:review_id/likes", middleware.gameExist, middleware.isLoggedIn, function(req, res) {
    let id = parseInt(req.params.id, 10);
    let review_id = parseInt(req.params.review_id, 10);
    if (!Number.isNaN(review_id)) {
        let query = "CALL Like_Review(" + connection.escape(id) + ", " + connection.escape(review_id) + ", " + connection.escape(req.user.Username)  +")";
        connection.query(query, function(error, results, fields) {
            if (error) {
                res.status(500);
                res.json({ error: error });
            }
            else {
                res.json({message: "Liked review"});
            }
        });
    }
    else {
        res.status(422);
        res.json({ message: "Review ID needs to be a number" });
    }
});

//Get Likes of Review Route
router.get("/:review_id/likes", middleware.gameExist, function(req, res){
    let id = parseInt(req.params.id, 10);
    let review_id = parseInt(req.params.review_id, 10);
    if (!Number.isNaN(review_id)) {
        let query = "CALL Get_Likes_Review(" + connection.escape(id) + ", " + connection.escape(review_id) + ")";
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
    else {
        res.status(422);
        res.json({ message: "Review ID needs to be a number" });
    }
});




module.exports = router;