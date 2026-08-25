/**
 * ══════════════════════════════════════════════════════════════
 *   Resend Email Configuration — Unit Tests
 *
 *   Regression tests for the configuration helpers every email path
 *   depends on:
 *     - sendEmail / sendBatchEmails fall back to the resend.from
 *       override via getConfiguredResendFrom() (previously these
 *       hardcoded the default and ignored the override)
 *     - the from-fallback default matches the documented default
 *     - missing Resend key fails closed with "not configured"
 *     - every send is logged to the EmailLogs audit collection
 * ══════════════════════════════════════════════════════════════
 */

const { expect } = require("chai");
const sinon = require("sinon");
const proxyquire = require("proxyquire").noCallThru();

const DEFAULT_RESEND_FROM = "Pulse <noreply@thestackone.com>";

// ── Mock builders (same shapes as staff_invitation.test.js) ──

let serverTimestampStub;
let mockConfig = {};
let axiosPostStub;
let firestoreCollectionStub;

function buildMockAdmin() {
  serverTimestampStub = sinon.stub().returns("SERVER_TIMESTAMP");

  const docRef = {
    id: "log-doc",
    set: sinon.stub().resolves(),
    update: sinon.stub().resolves(),
    get: sinon.stub().resolves({ exists: false }),
  };

  firestoreCollectionStub = sinon.stub().returns({
    add: sinon.stub().resolves({ id: "log-id" }),
    doc: sinon.stub().returns(docRef),
    where: sinon.stub().returnsThis(),
    limit: sinon.stub().resolves({ docs: [] }),
    get: sinon.stub().resolves({ docs: [] }),
  });

  const firestore = () => ({
    collection: firestoreCollectionStub,
    doc: sinon.stub().returns(docRef),
    FieldValue: { serverTimestamp: serverTimestampStub },
  });
  // index.js also uses admin.firestore.FieldValue.serverTimestamp()
  // directly off the namespace.
  firestore.FieldValue = { serverTimestamp: serverTimestampStub };

  return {
    initializeApp: sinon.stub(),
    firestore,
  };
}

function buildMockFunctions() {
  const HttpsError = class extends Error {
    constructor(code, message) {
      super(message);
      this.code = code;
      this.name = "HttpsError";
    }
  };

  const callableBuilder = {
    https: { onCall: (fn) => fn, onRequest: (fn) => fn, HttpsError },
    firestore: {
      document: () => ({
        onCreate: (fn) => fn,
        onUpdate: (fn) => fn,
        onDelete: (fn) => fn,
      }),
    },
    pubsub: {
      schedule: () => ({ timeZone: () => ({ onRun: (fn) => fn }) }),
    },
    auth: { user: () => ({ onDelete: (fn) => fn }) },
  };

  return {
    config: () => mockConfig,
    region: () => callableBuilder,
    https: callableBuilder.https,
    firestore: callableBuilder.firestore,
    pubsub: callableBuilder.pubsub,
    auth: callableBuilder.auth,
    HttpsError,
  };
}

function loadModule(config) {
  mockConfig = config || {};
  axiosPostStub = sinon.stub().resolves({ data: { id: "msg_test_1" } });
  const mockAxios = { post: axiosPostStub, default: { post: axiosPostStub } };

  delete require.cache[require.resolve("../index")];
  return proxyquire("../index", {
    "firebase-admin": buildMockAdmin(),
    "firebase-functions": buildMockFunctions(),
    axios: mockAxios,
  });
}

function authContext() {
  return { auth: { uid: "user-1" } };
}

// ══════════════════════════════════════════════════════════════
//   Tests
// ══════════════════════════════════════════════════════════════

describe("Resend configuration", function () {
  afterEach(function () {
    sinon.restore();
    mockConfig = {};
  });

  describe("sendEmail from-fallback", function () {
    it("uses the resend.from override when configured", async function () {
      const module = loadModule({
        resend: { key: "re_test", from: "Pulse <noreply@newdomain.com>" },
      });

      await module.sendEmail(
        { to: "x@y.com", subject: "Hi", html: "<p>Hi</p>" },
        authContext()
      );

      expect(axiosPostStub.calledOnce).to.equal(true);
      const payload = axiosPostStub.firstCall.args[1];
      expect(payload.from).to.equal("Pulse <noreply@newdomain.com>");
    });

    it("falls back to the documented default when no override is set", async function () {
      const module = loadModule({ resend: { key: "re_test" } });

      await module.sendEmail(
        { to: "x@y.com", subject: "Hi", html: "<p>Hi</p>" },
        authContext()
      );

      const payload = axiosPostStub.firstCall.args[1];
      expect(payload.from).to.equal(DEFAULT_RESEND_FROM);
    });

    it("prefers an explicit from argument over config", async function () {
      const module = loadModule({
        resend: { key: "re_test", from: "Pulse <noreply@newdomain.com>" },
      });

      await module.sendEmail(
        {
          to: "x@y.com",
          subject: "Hi",
          html: "<p>Hi</p>",
          from: "Custom <custom@pulse.dev>",
        },
        authContext()
      );

      const payload = axiosPostStub.firstCall.args[1];
      expect(payload.from).to.equal("Custom <custom@pulse.dev>");
    });

    it("rejects unauthenticated calls", async function () {
      const module = loadModule({ resend: { key: "re_test" } });

      let error = null;
      try {
        await module.sendEmail(
          { to: "x@y.com", subject: "Hi", html: "<p>Hi</p>" },
          { auth: null }
        );
      } catch (e) {
        error = e;
      }
      expect(error).to.not.equal(null);
      expect(error.code).to.equal("unauthenticated");
    });

    it("fails closed when the Resend key is missing", async function () {
      const module = loadModule({});

      let error = null;
      try {
        await module.sendEmail(
          { to: "x@y.com", subject: "Hi", html: "<p>Hi</p>" },
          authContext()
        );
      } catch (e) {
        error = e;
      }
      expect(error).to.not.equal(null);
      expect(error.code).to.equal("internal");
      expect(error.message).to.include("Email service not configured");
    });

    it("validates required fields", async function () {
      const module = loadModule({ resend: { key: "re_test" } });

      let error = null;
      try {
        await module.sendEmail({ to: "x@y.com" }, authContext());
      } catch (e) {
        error = e;
      }
      expect(error).to.not.equal(null);
      expect(error.code).to.equal("invalid-argument");
    });

    it("logs the send to the EmailLogs audit collection", async function () {
      const module = loadModule({ resend: { key: "re_test" } });

      await module.sendEmail(
        { to: "x@y.com", subject: "Hi", html: "<p>Hi</p>" },
        authContext()
      );

      // Firestore admin mock exposes collection("EmailLogs").add(...)
      const emailLogsCalls = firestoreCollectionStub
        .getCalls()
        .filter((c) => c.args[0] === "EmailLogs");
      expect(emailLogsCalls.length).to.be.at.least(1);
      const addCalls = emailLogsCalls
        .map((c) => c.returnValue.add.getCalls())
        .flat();
      expect(addCalls.length).to.be.at.least(1);
      const entry = addCalls[0].args[0];
      expect(entry.status).to.equal("sent");
      expect(entry.sentBy).to.equal("user-1");
    });
  });

  describe("sendBatchEmails from-fallback", function () {
    it("uses the resend.from override for every entry", async function () {
      const module = loadModule({
        resend: { key: "re_test", from: "Pulse <noreply@newdomain.com>" },
      });

      const result = await module.sendBatchEmails(
        {
          emails: [
            { to: "a@y.com", subject: "A", html: "<p>A</p>" },
            { to: "b@y.com", subject: "B", text: "B" },
          ],
        },
        authContext()
      );

      expect(axiosPostStub.callCount).to.equal(2);
      for (const call of axiosPostStub.getCalls()) {
        expect(call.args[1].from).to.equal("Pulse <noreply@newdomain.com>");
      }
      expect(result.success).to.equal(true);
    });

    it("defaults entries without a from to the documented default", async function () {
      const module = loadModule({ resend: { key: "re_test" } });

      await module.sendBatchEmails(
        { emails: [{ to: "a@y.com", subject: "A", html: "<p>A</p>" }] },
        authContext()
      );

      const payload = axiosPostStub.firstCall.args[1];
      expect(payload.from).to.equal(DEFAULT_RESEND_FROM);
    });

    it("rejects empty batches without sending", async function () {
      const module = loadModule({ resend: { key: "re_test" } });

      let error = null;
      try {
        await module.sendBatchEmails({ emails: [] }, authContext());
      } catch (e) {
        error = e;
      }
      expect(error).to.not.equal(null);
      expect(error.code).to.equal("invalid-argument");
      expect(axiosPostStub.callCount).to.equal(0);
    });
  });
});
