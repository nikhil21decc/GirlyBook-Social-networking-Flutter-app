const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

 exports.onCreateFollower = functions.firestore.document('/followers/{userId}/userFollowers/{followerId}')
    .onCreate(async (snapshot , context) =>{
     console.log('Follower Created' , snapshot.data());

      const userId = context.params.userId;
      const followerId = context.params.followerId;

      const followedUserPostsRef = admin.firestore().collection('posts')
        .doc(userId).collection('userPost');

      const timelinePostsRef = admin
       .firestore()
       .collection('timeline')
       .doc(followerId)
        .collection('timePosts');

      const querySnapshot = await followedUserPostsRef.get();

       querySnapshot.forEach(doc => {
        if(doc.exists){
          const postId = doc.id;
          const postData = doc.data();
          timelinePostsRef.doc(postId).set(postData);
        }
       })

    });