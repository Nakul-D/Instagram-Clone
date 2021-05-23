const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp();

// Create and Deploy Your Cloud Functions

const usersRef = admin.firestore().collection('users');
const postsRef = admin.firestore().collection('posts');
const followersRef = admin.firestore().collection('followers');
const followingRef = admin.firestore().collection('following');
const commentsRef = admin.firestore().collection('comments');
const activityRef = admin.firestore().collection('activity');

// This function will be triggered when profile is updated
exports.onProfileUpdate = functions.firestore
    .document("/users/{userId}")
    .onUpdate(async (change, context)  => {

        const updatedProfileData = change.after.data();
        const userId = context.params.userId;

        // Getting user's posts
        const postSnapshot = await postsRef
            .doc(userId)
            .collection("posts")
            .get();

        // Updating user's posts
        postSnapshot.forEach(doc => {
            const postId = doc.id;
            postsRef
                .doc(userId)
                .collection("posts")
                .doc(postId)
                .update({
                    "username": updatedProfileData['username'],
                    "profileImgUrl": updatedProfileData["profileImgUrl"],
                });
        });
    })

// This function will be triggered when a new follower is added
exports.onFollowerAdded = functions.firestore
    .document("followers/{userId}/followers/{followerId}")
    .onCreate(async (snapshot, context) => {

        const userId = context.params.userId;
        const followerId = context.params.followerId;
        const timestamp = admin.firestore.Timestamp.now().toDate();

        // Adding follower notification to user's activity feed
        activityRef
            .doc(userId)
            .collection("feed")
            .doc()
            .set({
                "type": "follow",
                "userId": followerId,
                "timestamp": timestamp
            });
    })

// This function will be triggered when a comment is added
exports.onCommentAdded = functions.firestore
    .document("/comments/{postId}/comments/{commentId}")
    .onCreate(async (snapshot, context) => {

        const postId = context.params.postId;
        const commentId = context.params.commentId;

        // Fetching post owner's Id
        const postQuery = await admin.firestore().collectionGroup("posts")
            .where("postId", "==", postId)
            .get();
        const ownerId = postQuery.docs["0"].data()["ownerId"];

        // Fetching userId of the user who commented on the post
        const commentQuery = await commentsRef
            .doc(postId)
            .collection("comments")
            .doc(commentId)
            .get();
        const userId = commentQuery.data()["userId"];
        
        // Fetching timestamp of the comment
        const timestamp = commentQuery.data()["timestamp"];

        // Fetching comment data
        const commentData = commentQuery.data()["comment"];
        
        // Will not add owner's comment to owner's activity feed
        if (userId != ownerId) {
            // Adding comment notification to owner's activity feed
            activityRef
                .doc(ownerId)
                .collection("feed")
                .doc()
                .set({
                    "type": "comment",
                    "userId": userId,
                    "timestamp": timestamp,
                    "postId": postId,
                    "commentData": commentData,
                });
        }
    })

// This function will be triggered when post is likes
exports.onPostLiked = functions.firestore
    .document("/posts/{ownerId}/posts/{postId}")
    .onUpdate(async (change, context) => {

        const ownerId = context.params.ownerId;
        const postId = context.params.postId;

        // Fetching id of the user who liked the post
        const likes = new Map(Object.entries(change.after.data()["like"]));
        const userId = Array.from(likes.keys()).pop();

        // Will not add owner's like to owner's activity feed
        if (userId != ownerId) {
            const isLiked = Array.from(likes.values()).pop();
            if (isLiked == true) {
                const timestamp = admin.firestore.Timestamp.now().toDate();
                // Adding like notification to owner's activity feed
                activityRef
                    .doc(ownerId)
                    .collection("feed")
                    .doc()
                    .set({
                        "type": "like",
                        "userId": userId,
                        "timestamp": timestamp,
                        "postId": postId,
                    });
            }
        }
    })
