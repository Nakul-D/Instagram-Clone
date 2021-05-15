const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// https://firebase.google.com/docs/functions/write-firebase-functions

const usersRef = admin.firestore().collection('users');
const postsRef = admin.firestore().collection('posts');
const followersRef = admin.firestore().collection('followers');
const followingRef = admin.firestore().collection('following');

// This function will be triggered when profile is updated
exports.onProfileUpdate = functions.firestore
    .document("/users/{userId}")
    .onUpdate(async (change, context)  => {

        // Get the updated profile data
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
