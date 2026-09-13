importScripts('https://www.gstatic.com/firebasejs/10.8.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.8.1/firebase-messaging-compat.js');

const firebaseConfig = {
  apiKey: "AIzaSyAUq0Fwz6ubqzKP2Gmn430g8F-cn1Ajc3g",
  authDomain: "aikya-platform.firebaseapp.com",
  projectId: "aikya-platform",
  storageBucket: "aikya-platform.firebasestorage.app",
  messagingSenderId: "287187127448",
  appId: "1:287187127448:web:8191d0f72f3eae13c514ed",
  measurementId: "G-WTT4W33VXZ"
};

firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  
  const notificationTitle = payload.notification?.title || 'Aikya Update';
  const notificationOptions = {
    body: payload.notification?.body,
    icon: '/icon-192x192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
