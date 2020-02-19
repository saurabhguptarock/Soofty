const functions = require("firebase-functions");

const admin = require("firebase-admin");
const serviceAccount = require("./services-account.json");

const defaultStorage = admin.storage();
const message = admin.messaging();
exports.onMusicUpload = functions.storage.object().onFinalize(async object => {
  const fileName = object.name;
  const bucket = defaultStorage.bucket();
  const file = bucket.file(object.name);
  const results = await file.getSignedUrl({
    action: "read",
    expires: "03-17-2025"
  });
  const url = results[0];

  if (fileName.split("/")[0] == "Music Files") {
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
  } else if (fileName.split("/")[0] == "Music Thumbnails") {
    let docss = await admin
      .firestore()
      .collection("musicTiles")
      .get();
    for (let i = 0; i < docss.docs.length; i++) {
      if (
        docss.docs[i].data()["name"] == fileName.split("/")[1].split(".")[0]
      ) {
        docss.docs[i].ref.update({ img: url });
        console.log(`Updated Document ${docss.docs[i].id}.`);
        break;
      }
    }
  }
});

exports.onNewMusicUpload = functions.firestore
  .document("collectibles/{collectible}")
  .onCreate(async snapshot => {
    const data = snapshot.data();
    const payload = {
      notification: {
        title: "New Music Added",
        body: `${data.numberOfMusic} new Music added, Check it now.`,
        clickAction: "FLUTTER_NOTIFICATION_CLICK"
      }
    };
    return message.sendToTopic("seeNewMusic", payload);
  });
