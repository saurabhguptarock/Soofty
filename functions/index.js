const functions = require("firebase-functions");

const admin = require("firebase-admin");
const serviceAccount = require("./services-account.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://soofty-b9cb5.firebaseio.com",
  storageBucket: "soofty-b9cb5.appspot.com",
  projectId: "soofty-b9cb5"
});

const defaultStorage = admin.storage();

exports.onMusicUpload = functions.storage.object().onFinalize(async object => {
  const fileName = object.name;
  const bucket = defaultStorage.bucket();
  const file = bucket.file(object.name);
  const results = await file.getSignedUrl({
    action: "read",
    expires: "03-17-2025"
  });
  const url = results[0];

  admin
    .firestore()
    .collection("musicTiles")
    .add({
      img: "",
      name: fileName.split("/")[1].split(".")[0],
      audioUrl: url,
      uid: ""
    })
    .then(id => {
      id.update({ uid: id.id });
    });
});
