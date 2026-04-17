const { initializeTestEnvironment, RulesTestEnvironment } = require("@firebase/rules-unit-testing");
const { doc, collection, getDocs, query, where, setDoc, getDoc, updateDoc, deleteDoc } = require("firebase/firestore");
const fs = require("fs");

let testEnv;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: "test-project",
    firebaseRules: fs.readFileSync("firestore.rules", "utf8"),
  });
});

afterAll(async () => {
  await testEnv.cleanup();
});

describe("Firestore Security Rules", () => {
  describe("Users Collection", () => {
    test("User can read their own document", async () => {
      const db = testEnv.authenticatedContext("user-1").firestore();
      const userRef = doc(db, "users", "user-1");

      // Setup: Create the user document
      const adminDb = testEnv.unauthenticatedContext().firestore();
      await setDoc(userRef, {
        displayName: "User 1",
        email: "user1@example.com",
        role: "resident",
        verified: true,
      }, { merge: true });

      // Test: User can read their own doc
      await expect(getDoc(userRef)).not.toThrow();
    });

    test("User cannot change their own 'verified' field", async () => {
      const db = testEnv.authenticatedContext("user-1").firestore();
      const userRef = doc(db, "users", "user-1");

      // Test: Should NOT be able to update verified field
      await expect(
        updateDoc(userRef, { verified: true })
      ).rejects.toThrow();
    });

    test("User cannot change their own 'role' field", async () => {
      const db = testEnv.authenticatedContext("user-1").firestore();
      const userRef = doc(db, "users", "user-1");

      // Test: Should NOT be able to update role field
      await expect(
        updateDoc(userRef, { role: "admin" })
      ).rejects.toThrow();
    });

    test("User cannot read another user's private fields", async () => {
      const db = testEnv.authenticatedContext("user-1").firestore();
      const otherUserRef = doc(db, "users", "user-2");

      // Test: Cannot read another user's doc
      await expect(getDoc(otherUserRef)).rejects.toThrow();
    });
  });

  describe("Fines Collection", () => {
    test("Admin can read fines from their community", async () => {
      const adminDb = testEnv.authenticatedContext("admin-1").firestore();
      const finesRef = collection(adminDb, "communities/comm-1/fines");

      // Test: Admin can query fines
      const q = query(finesRef, where("status", "==", "pending"));
      await expect(getDocs(q)).not.toThrow();
    });

    test("Resident can only read their own fines", async () => {
      const residentDb = testEnv.authenticatedContext("resident-1").firestore();
      const fineRef = doc(residentDb, "communities/comm-1/fines/fine-1");

      // Test: Trying to read should work only if resident-1 is the owner
      // This would require the actual rule implementation to check residentUid
      await expect(getDoc(fineRef)).rejects.toThrow();
    });
  });

  describe("Subscriptions Collection", () => {
    test("Client cannot write to subscriptions collection", async () => {
      const db = testEnv.authenticatedContext("user-1").firestore();
      const subRef = doc(db, "subscriptions", "sub-1");

      // Test: User cannot create a subscription
      await expect(
        setDoc(subRef, {
          communityId: "comm-1",
          plan: "premium",
          status: "active"
        })
      ).rejects.toThrow();
    });

    test("Client cannot read subscriptions collection", async () => {
      const db = testEnv.authenticatedContext("user-1").firestore();
      const subRef = doc(db, "subscriptions", "sub-1");

      // Test: User cannot read subscriptions
      await expect(getDoc(subRef)).rejects.toThrow();
    });
  });

  describe("Payment Intents Collection", () => {
    test("User can read their own payment_intents", async () => {
      const db = testEnv.authenticatedContext("user-1").firestore();
      const paymentRef = doc(db, "payment_intents", "intent-1");

      // Setup: Create a payment intent for user-1
      const adminDb = testEnv.unauthenticatedContext().firestore();
      await setDoc(paymentRef, {
        uid: "user-1",
        amount: 50000,
        currency: "COP",
        status: "pending",
      }, { merge: true });

      // Test: User can read their own payment intent
      await expect(getDoc(paymentRef)).not.toThrow();
    });

    test("User cannot create payment_intents from client", async () => {
      const db = testEnv.authenticatedContext("user-1").firestore();
      const paymentRef = doc(db, "payment_intents", "intent-new");

      // Test: Should not be able to create
      await expect(
        setDoc(paymentRef, {
          uid: "user-1",
          amount: 50000,
          currency: "COP",
        })
      ).rejects.toThrow();
    });
  });

  describe("Community Isolation", () => {
    test("Admin of community A cannot read community B data", async () => {
      const adminDb = testEnv.authenticatedContext("admin-a").firestore();

      // Assuming admin-a belongs to comm-a and tries to read comm-b data
      const fineRef = doc(adminDb, "communities/comm-b/fines/fine-1");

      // Test: Admin A cannot access community B
      await expect(getDoc(fineRef)).rejects.toThrow();
    });
  });

  describe("Anonymous Access", () => {
    test("Anonymous user cannot access protected collections", async () => {
      const db = testEnv.unauthenticatedContext().firestore();
      const userRef = doc(db, "users", "any-user");

      // Test: Cannot access users collection without auth
      await expect(getDoc(userRef)).rejects.toThrow();
    });
  });
});
