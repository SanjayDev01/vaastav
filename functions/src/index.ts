import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'
//import { user } from 'firebase-functions/lib/providers/auth'
const { CloudTasksClient } = require('@google-cloud/tasks')
admin.initializeApp()

// Payload of JSON data to send to Cloud Tasks, will be received by the HTTP callback
interface ExpirationTaskPayload {
    docPath: string
}

exports.onCreatePost =
    functions.firestore.document('/posts/{userId}/userPosts/{postId}').onCreate(async snapshot => {
        const expisresIn = 86400
        const expirationAtSeconds = Date.now() / 1000 + expisresIn
        // Get the project ID from the FIREBASE_CONFIG env var
        const project = JSON.parse(process.env.FIREBASE_CONFIG!).projectId
        const location = 'asia-east2'
        const queue = 'junglee-post'
        const tasksClient = new CloudTasksClient()
        const queuePath: string = tasksClient.queuePath(project, location, queue)
        const url = `https://us-central1-junglee-d1ea2.cloudfunctions.net/jungleePost`
        const docPath = snapshot.ref.path
        const payload: ExpirationTaskPayload = { docPath }
        const task = {
            httpRequest: {
                httpMethod: 'POST',
                url,
                body: Buffer.from(JSON.stringify(payload)).toString('base64'),
                headers: {
                    'Content-Type': 'application/json',
                },
            },
            scheduleTime: {
                seconds: expirationAtSeconds
            }
        }
        await tasksClient.createTask({ parent: queuePath, task })
    })
exports.onCreateGps =
    functions.firestore.document('/gps/{gpsId}/userPosts/{postId}').onCreate(async snapshot => {
        const expisresIn = 86400
        const expirationAtSeconds = Date.now() / 1000 + expisresIn
        // Get the project ID from the FIREBASE_CONFIG env var
        const project = JSON.parse(process.env.FIREBASE_CONFIG!).projectId
        const location = 'asia-east2'
        const queue = 'junglee-gps'
        const tasksClient = new CloudTasksClient()
        const queuePath: string = tasksClient.queuePath(project, location, queue)
        const url = `https://us-central1-junglee-d1ea2.cloudfunctions.net/jungleeGps`
        const docPath = snapshot.ref.path
        const payload: ExpirationTaskPayload = { docPath }
        const task = {
            httpRequest: {
                httpMethod: 'POST',
                url,
                body: Buffer.from(JSON.stringify(payload)).toString('base64'),
                headers: {
                    'Content-Type': 'application/json',
                },
            },
            scheduleTime: {
                seconds: expirationAtSeconds
            }
        }
        await tasksClient.createTask({ parent: queuePath, task })
    })
exports.jungleeGps = functions.https.onRequest(async (req, res) => {
    const payload = req.body as ExpirationTaskPayload
    try {
        await admin.firestore().doc(payload.docPath).delete()
        res.send(200)
    }
    catch (error) {
        console.error(error)
        res.status(500).send(error)
    }
})
exports.jungleePost = functions.https.onRequest(async (req, res) => {
    const payload = req.body as ExpirationTaskPayload
    try {
        await admin.firestore().doc(payload.docPath).delete()
        res.send(200)
    }
    catch (error) {
        console.error(error)
        res.status(500).send(error)
    }
})
exports.onDeletePost = functions.runWith({memory : "256MB"}).firestore.document("/posts/{userId}/userPosts/{postId}").onDelete(async (snapshot, context) => {
    const userId = context.params.userId
    const deleteViews = admin.firestore().collection("allViews").doc(userId).collection("allViewers")
    const deletev = admin.firestore().collection("posts").doc(userId)
    const query = await deleteViews.get()
    await deletev.delete()
    query.forEach(async (doc) => {
        if (doc.exists) {
            await doc.ref.delete()
        }
    })


})
exports.onDeleteStory = functions.firestore.document("/userStory/{userId}/userPosts/{storyId}").onDelete(async (snapshot, context) => {
    const storyId = context.params.storyId
    const bucket = admin.storage().bucket();
    return bucket.deleteFiles({
        prefix: `post_${storyId}`

    })
})
exports.onCreateFav = functions.firestore.document("/myFav/{currentUserId}/user/{userID}/posts/{postID}").onCreate(async (snapshot, context) => {
    const userID = context.params.userID
    const postID = context.params.postID
    const currentUserId = context.params.currentUserId
    const doc = admin.firestore().collection("posts").doc(userID).collection("userPosts").doc(postID)
    const docRef = await doc.get()

    const docSnap = docRef.data()
    if (docSnap) {
        await admin.firestore().collection("usersFav").doc(currentUserId).collection("userPosts").doc(postID).set(docSnap)
    }
})
exports.onCreateFav1 =
    functions.firestore.document('/usersFav/{currentId}/userPosts/{postId}').onCreate(async snapshot => {
        const expisresIn = 172800
        const expirationAtSeconds = Date.now() / 1000 + expisresIn
        // Get the project ID from the FIREBASE_CONFIG env var
        const project = JSON.parse(process.env.FIREBASE_CONFIG!).projectId
        const location = 'asia-east2'
        const queue = 'junglee-Fav'
        const tasksClient = new CloudTasksClient()
        const queuePath: string = tasksClient.queuePath(project, location, queue)
        const url = `https://us-central1-junglee-d1ea2.cloudfunctions.net/jungleeFav`
        const docPath = snapshot.ref.path
        const payload: ExpirationTaskPayload = { docPath }
        const task = {
            httpRequest: {
                httpMethod: 'POST',
                url,
                body: Buffer.from(JSON.stringify(payload)).toString('base64'),
                headers: {
                    'Content-Type': 'application/json',
                },
            },
            scheduleTime: {
                seconds: expirationAtSeconds
            }
        }
        await tasksClient.createTask({ parent: queuePath, task })
    })

exports.jungleeFav = functions.https.onRequest(async (req, res) => {
    const payload = req.body as ExpirationTaskPayload
    try {
        await admin.firestore().doc(payload.docPath).delete()
        res.send(200)
    }
    catch (error) {
        console.error(error)
        res.status(500).send(error)
    }
})
exports.onCreateFav2 =
    functions.firestore.document("/userStory/{userId}/userPosts/{storyId}").onCreate(async snapshot => {
        const expisresIn = 259200
        const expirationAtSeconds = Date.now() / 1000 + expisresIn
        // Get the project ID from the FIREBASE_CONFIG env var
        const project = JSON.parse(process.env.FIREBASE_CONFIG!).projectId
        const location = 'asia-east2'
        const queue = 'junglee-user'
        const tasksClient = new CloudTasksClient()
        const queuePath: string = tasksClient.queuePath(project, location, queue)
        const url = `https://us-central1-junglee-d1ea2.cloudfunctions.net/jungleeUser`
        const docPath = snapshot.ref.path
        const payload: ExpirationTaskPayload = { docPath }
        const task = {
            httpRequest: {
                httpMethod: 'POST',
                url,
                body: Buffer.from(JSON.stringify(payload)).toString('base64'),
                headers: {
                    'Content-Type': 'application/json',
                },
            },
            scheduleTime: {
                seconds: expirationAtSeconds
            }
        }
        await tasksClient.createTask({ parent: queuePath, task })
    })

exports.jungleeUser = functions.https.onRequest(async (req, res) => {
    const payload = req.body as ExpirationTaskPayload
    try {
        await admin.firestore().doc(payload.docPath).delete()
        res.send(200)
    }
    catch (error) {
        console.error(error)
        res.status(500).send(error)
    }
})
exports.onDeleteMyFav = functions.firestore.document("/myFav/{currentUserId}/user/{userID}/posts/{postID}").onDelete(async (snapshot, context) => {
    const postID = context.params.postID
    const currentUserId = context.params.currentUserId

    const myFav = admin.firestore().collection("usersFav").doc(currentUserId).collection("userPosts").doc(postID)
    await myFav.delete()
})


