const   express = require("express"),
        router = express.Router({mergeParams: true}),
        connection = require("../db"),
        middleware = require("../middleware/index");

//Show Route
router.get("/:username", middleware.profileExist, function(req, res){
    res.json(res.locals.profile);
});

//Update Route
router.put("/", middleware.isLoggedIn, function (req, res) {
    let user = connection.escape(req.user.Username);
    let pic = req.body.picture;
    if (pic) {
        let picURL;
        try {
            picURL = connection.escape(new URL(pic).href);
        }
        catch (_) {
            res.status(415);
            res.json({ message: "Pic is not a url" });
            return;
        }
        let query = "CALL Edit_Profile_Pic(" + user + ", " + picURL + ")";
        connection.query(query, function(error, results) {
            if (error) {
                console.log(error);
            }
        });
    }
    if (req.body.bio) {
        let bio = connection.escape(req.body.bio);
        let query = "CALL Edit_Profile_Bio(" + user + ", " + bio + ")";
        connection.query(query, function (error, results) {
            if (error) {
                console.log(error);
            }
        });
    }
    res.json({ message: "Edited profile." });
});

//Reviews Written Route
router.get("/:username/reviews", middleware.profileExist, function(req,res){
    let user = connection.escape(req.params.username);
    let query = "CALL Get_Reviews_Written(" + user + ")";
    connection.query(query, function (error, results) {
        if (error) {
            res.status(500);
            res.json({ error: error });
        }
        else {
            res.json(results[0]);
        }
    });
});

module.exports = router;