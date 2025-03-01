const functions = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

exports.myFunction = functions.onDocumentCreated(
  "chat/{messageId}",
  (event) => {
    // Log 1: Function triggered
    console.log("🔥 Function triggered for document:", event.params.messageId);
    
    try {
      // Log 2: Document data received
      const data = event.data.data();
      console.log("📄 Document data:", JSON.stringify(data, null, 2));

      // Log 3: FCM message construction
      const fcmMessage = {
        notification: {
          title: data["username"],
          body: data["text"],
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
        topic: "chat"
      };
      console.log("📨 Constructed FCM message:", JSON.stringify(fcmMessage, null, 2));

      // Send FCM and log result
      return admin.messaging().send(fcmMessage)
        .then((response) => {
          // Log 4: Success case
          console.log("✅ FCM sent successfully. Message ID:", response);
          console.log("🚀 Full FCM response:", JSON.stringify(response, null, 2));
          return null;
        })
        .catch((error) => {
          // Log 5: Error case
          console.error("❌ FCM failed to send");
          console.error("🔥 Error details:", JSON.stringify(error, null, 2));
          throw error; // Re-throw to mark function execution as failed
        });
    } catch (error) {
      // Log 6: Top-level error
      console.error("💥 Critical error in function execution");
      console.error("🛑 Error details:", JSON.stringify(error, null, 2));
      throw error;
    }
  }
);