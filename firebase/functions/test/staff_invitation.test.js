/**
 * ══════════════════════════════════════════════════════════════
 *   Staff Invitation Cloud Functions — Unit Tests
 *   Tests: sendStaffInvitation, verifyStaffInvitation,
 *          completeStaffInvitation
 * ══════════════════════════════════════════════════════════════
 */

const { expect } = require("chai");
const sinon = require("sinon");
const proxyquire = require("proxyquire").noCallThru();

// ── Shared stubs ──
let serverTimestampStub;

function makeDocRef(id) {
  return {
    id,
    path: `Collection/${id}`,
    set: sinon.stub(),
    update: sinon.stub(),
    get: sinon.stub(),
  };
}

function makeDocRefWithGet(id, snapshot) {
  const ref = makeDocRef(id);
  ref.get = sinon.stub().resolves(snapshot);
  return ref;
}

function makeAddStub(returnId) {
  const ref = makeDocRef(returnId || "new-doc-id");
  return sinon.stub().resolves(ref);
}

function makeWhereChain(depth) {
  if (depth <= 0) {
    return {
      limit: sinon.stub().returns({
        get: sinon.stub().resolves({ empty: true, docs: [] }),
      }),
    };
  }
  const next = makeWhereChain(depth - 1);
  return {
    where: sinon.stub().returns(next),
    limit: sinon.stub().returns({
      get: sinon.stub().resolves({ empty: true, docs: [] }),
    }),
  };
}

function makeCollectionMock(overrides = {}) {
  const defaultAdd = makeAddStub();
  const defaultGet = sinon.stub().resolves({ empty: true, docs: [] });
  const whereChain = makeWhereChain(5);

  const mock = {
    doc: sinon.stub().callsFake((id) => makeDocRef(id)),
    add: defaultAdd,
    where: whereChain.where,
    ...overrides,
  };
  return mock;
}

// ── Build mock firebase-admin ──
function buildMockAdmin(overrides = {}) {
  serverTimestampStub = sinon.stub().returns("SERVER_TIMESTAMP");

  const defaultFirestore = {
    collection: sinon.stub().callsFake((name) =>
      makeCollectionMock(overrides[name])
    ),
    doc: sinon.stub().callsFake((path) => makeDocRef(path.split("/").pop())),
    runTransaction: sinon.stub().callsFake(async (fn) =>
      fn({
        get: sinon.stub(),
        set: sinon.stub(),
        update: sinon.stub(),
      })
    ),
    FieldValue: { serverTimestamp: serverTimestampStub },
  };

  // Wrap .returns() so FieldValue is always present on the returned object
  const firestoreStub = sinon.stub().returns(defaultFirestore);
  const origReturns = firestoreStub.returns.bind(firestoreStub);
  firestoreStub.returns = function (val) {
    if (val && typeof val === "object" && !val.FieldValue) {
      val.FieldValue = { serverTimestamp: serverTimestampStub };
    }
    return origReturns(val);
  };

  return {
    initializeApp: sinon.stub(),
    firestore: Object.assign(firestoreStub, {
      FieldValue: { serverTimestamp: serverTimestampStub },
    }),
  };
}

// ── Build mock firebase-functions ──
let mockConfig = {};

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
      document: (p) => ({ onCreate: (fn) => fn, onUpdate: (fn) => fn, onDelete: (fn) => fn }),
    },
    pubsub: { schedule: (e) => ({ timeZone: (t) => ({ onRun: (fn) => fn }) }) },
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

// ── Build mock axios ──
let axiosPostStub;

function buildMockAxios() {
  axiosPostStub = sinon.stub().resolves({ data: { id: "msg_test_12345" } });
  return { post: axiosPostStub, default: { post: axiosPostStub } };
}

// ── Load functions under test ──
function loadFunctions(mockAdmin, mockFunctions, mockAxios) {
  delete require.cache[require.resolve("../index")];
  return proxyquire("../index", {
    "firebase-admin": mockAdmin,
    "firebase-functions": mockFunctions,
    axios: mockAxios,
  });
}

// ══════════════════════════════════════════════════════════════
//   sendStaffInvitation tests
// ══════════════════════════════════════════════════════════════

describe("sendStaffInvitation", function () {
  const validData = {
    staffId: "staff-001",
    email: "newstaff@pharmacy.com",
    name: "John Banda",
    role: "Cashier",
    pharmacyName: "MediCare Lusaka",
    pharmacyId: "pharm-001",
  };
  const mockAuth = { uid: "owner-001" };

  function setupSuccessFlow() {
    mockConfig = {
      resend: { key: "re_test_key_12345", from: "Duniya <noreply@thestackone.com>" },
      app: { url: "https://thestackone.com/app.html" },
    };

    const invDoc = makeDocRef("inv-doc-id");
    invDoc.update = sinon.stub();

    const staffDoc = makeDocRefWithGet("staff-001", {
      exists: true,
      data: () => ({
        OwnerRef: { id: "owner-001" },
        Email: "newstaff@pharmacy.com",
      }),
    });
    staffDoc.update = sinon.stub();

    const mockAdmin = buildMockAdmin({
      Staff: { doc: sinon.stub().returns(staffDoc) },
      StaffInvitations: { add: sinon.stub().resolves(invDoc) },
      EmailLogs: { add: sinon.stub().resolves({ id: "log-id" }) },
    });
    mockAdmin.firestore.returns({
      collection: sinon.stub().callsFake((name) => {
        if (name === "Staff") return { doc: sinon.stub().returns(staffDoc), add: sinon.stub() };
        if (name === "StaffInvitations") return { doc: sinon.stub().returns(invDoc), add: sinon.stub().resolves(invDoc) };
        if (name === "EmailLogs") return { doc: sinon.stub().returns(makeDocRef("log")), add: sinon.stub().resolves({ id: "log-id" }) };
        return makeCollectionMock();
      }),
      doc: sinon.stub().callsFake((path) => makeDocRef(path.split("/").pop())),
      runTransaction: sinon.stub().callsFake(async (fn) => fn({ get: sinon.stub(), set: sinon.stub(), update: sinon.stub() })),
      FieldValue: { serverTimestamp: serverTimestampStub },
    });

    return { mockAdmin, invDoc, staffDoc };
  }

  // ── Authentication ──

  it("should reject unauthenticated requests", async function () {
    const { mockAdmin } = setupSuccessFlow();
    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), buildMockAxios());
    try {
      await loaded.sendStaffInvitation({}, { auth: null });
      expect.fail("Should have thrown");
    } catch (err) {
      expect(err.code).to.equal("unauthenticated");
    }
  });

  // ── Input validation ──

  it("should reject when staffId is missing", async function () {
    const { mockAdmin } = setupSuccessFlow();
    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), buildMockAxios());
    try {
      await loaded.sendStaffInvitation({ email: "a@b.com", name: "A", role: "Cashier" }, { auth: mockAuth });
      expect.fail("Should have thrown");
    } catch (err) {
      expect(err.code).to.equal("invalid-argument");
      expect(err.message).to.include("staffId");
    }
  });

  it("should reject when email is missing", async function () {
    const { mockAdmin } = setupSuccessFlow();
    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), buildMockAxios());
    try {
      await loaded.sendStaffInvitation({ staffId: "s1", name: "A", role: "Cashier" }, { auth: mockAuth });
      expect.fail("Should have thrown");
    } catch (err) {
      expect(err.code).to.equal("invalid-argument");
    }
  });

  it("should reject when name is missing", async function () {
    const { mockAdmin } = setupSuccessFlow();
    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), buildMockAxios());
    try {
      await loaded.sendStaffInvitation({ staffId: "s1", email: "a@b.com", role: "Cashier" }, { auth: mockAuth });
      expect.fail("Should have thrown");
    } catch (err) {
      expect(err.code).to.equal("invalid-argument");
    }
  });

  it("should reject when role is missing", async function () {
    const { mockAdmin } = setupSuccessFlow();
    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), buildMockAxios());
    try {
      await loaded.sendStaffInvitation({ staffId: "s1", email: "a@b.com", name: "A" }, { auth: mockAuth });
      expect.fail("Should have thrown");
    } catch (err) {
      expect(err.code).to.equal("invalid-argument");
    }
  });

  // ── Staff record validation ──

  it("should reject when staff record is not found", async function () {
    const staffDoc = makeDocRefWithGet("staff-001", { exists: false });
    const mockAdmin = buildMockAdmin();
    mockAdmin.firestore.returns({
      collection: sinon.stub().callsFake(() => ({
        doc: sinon.stub().returns(staffDoc),
        add: sinon.stub().resolves({ id: "inv-id", update: sinon.stub() }),
      })),
      doc: sinon.stub().callsFake((p) => makeDocRef(p.split("/").pop())),
      runTransaction: sinon.stub().callsFake(async (fn) => fn({ get: sinon.stub(), set: sinon.stub(), update: sinon.stub() })),
      FieldValue: { serverTimestamp: serverTimestampStub },
    });
    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), buildMockAxios());
    try {
      await loaded.sendStaffInvitation(validData, { auth: mockAuth });
      expect.fail("Should have thrown");
    } catch (err) {
      expect(err.code).to.equal("not-found");
    }
  });

  it("should reject when inviter is not the owner", async function () {
    const staffDoc = makeDocRefWithGet("staff-001", {
      exists: true,
      data: () => ({ OwnerRef: { id: "other-owner-999" }, Email: "newstaff@pharmacy.com" }),
    });
    const mockAdmin = buildMockAdmin();
    mockAdmin.firestore.returns({
      collection: sinon.stub().callsFake(() => ({
        doc: sinon.stub().returns(staffDoc),
        add: sinon.stub().resolves({ id: "inv-id", update: sinon.stub() }),
      })),
      doc: sinon.stub().callsFake((p) => makeDocRef(p.split("/").pop())),
      runTransaction: sinon.stub().callsFake(async (fn) => fn({ get: sinon.stub(), set: sinon.stub(), update: sinon.stub() })),
      FieldValue: { serverTimestamp: serverTimestampStub },
    });
    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), buildMockAxios());
    try {
      await loaded.sendStaffInvitation(validData, { auth: mockAuth });
      expect.fail("Should have thrown");
    } catch (err) {
      expect(err.code).to.equal("permission-denied");
    }
  });

  it("should reject when email does not match", async function () {
    const staffDoc = makeDocRefWithGet("staff-001", {
      exists: true,
      data: () => ({ OwnerRef: { id: "owner-001" }, Email: "different@email.com" }),
    });
    const mockAdmin = buildMockAdmin();
    mockAdmin.firestore.returns({
      collection: sinon.stub().callsFake(() => ({
        doc: sinon.stub().returns(staffDoc),
        add: sinon.stub().resolves({ id: "inv-id", update: sinon.stub() }),
      })),
      doc: sinon.stub().callsFake((p) => makeDocRef(p.split("/").pop())),
      runTransaction: sinon.stub().callsFake(async (fn) => fn({ get: sinon.stub(), set: sinon.stub(), update: sinon.stub() })),
      FieldValue: { serverTimestamp: serverTimestampStub },
    });
    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), buildMockAxios());
    try {
      await loaded.sendStaffInvitation(validData, { auth: mockAuth });
      expect.fail("Should have thrown");
    } catch (err) {
      expect(err.code).to.equal("invalid-argument");
      expect(err.message).to.include("email must match");
    }
  });

  // ── Successful invitation ──

  it("should create invitation and send email via Resend", async function () {
    const { mockAdmin, invDoc, staffDoc } = setupSuccessFlow();
    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), buildMockAxios());

    const result = await loaded.sendStaffInvitation(validData, { auth: mockAuth });

    expect(result.success).to.be.true;
    expect(result.messageId).to.equal("msg_test_12345");
    expect(result.invitationId).to.equal("inv-doc-id");

    // Resend called
    expect(axiosPostStub.calledOnce).to.be.true;
    const [url, payload, cfg] = axiosPostStub.firstCall.args;
    expect(url).to.include("resend.com/emails");
    expect(payload.to).to.deep.equal(["newstaff@pharmacy.com"]);
    expect(payload.subject).to.include("MediCare Lusaka");
    expect(payload.subject).to.include("Cashier");
    expect(cfg.headers.Authorization).to.include("Bearer re_test_key");

    // Staff record updated (called twice: sending -> sent)
    expect(staffDoc.update.calledTwice).to.be.true;
    const firstUpdate = staffDoc.update.firstCall.args[0];
    expect(firstUpdate.invitationStatus).to.equal("sending");
    expect(firstUpdate.invitationId).to.equal("inv-doc-id");
    const secondUpdate = staffDoc.update.secondCall.args[0];
    expect(secondUpdate.invitationStatus).to.equal("sent");
  });

  it("should use configured Resend from address", async function () {
    const { mockAdmin } = setupSuccessFlow();
    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), buildMockAxios());

    await loaded.sendStaffInvitation(validData, { auth: mockAuth });

    const [, payload] = axiosPostStub.firstCall.args;
    expect(payload.from).to.equal("Duniya <noreply@thestackone.com>");
  });

  it("should normalize email to lowercase", async function () {
    const { mockAdmin } = setupSuccessFlow();
    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), buildMockAxios());

    await loaded.sendStaffInvitation({ ...validData, email: "NEWSTAFF@PHARMACY.COM" }, { auth: mockAuth });

    const [, payload] = axiosPostStub.firstCall.args;
    expect(payload.to).to.deep.equal(["newstaff@pharmacy.com"]);
  });

  it("should include invitation URL with token and email in HTML", async function () {
    const { mockAdmin } = setupSuccessFlow();
    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), buildMockAxios());

    await loaded.sendStaffInvitation(validData, { auth: mockAuth });

    const [, payload] = axiosPostStub.firstCall.args;
    expect(payload.html).to.include("/#/accept-invitation?token=");
    expect(payload.html).to.include("Accept Invitation");
    expect(payload.html).to.include("John Banda");
    expect(payload.html).to.include("MediCare Lusaka");
    expect(payload.html).to.include("Cashier");
  });

  it("should handle Resend API failure gracefully", async function () {
    const { mockAdmin, invDoc } = setupSuccessFlow();
    const failAxios = { post: sinon.stub().rejects({ response: { data: { message: "Invalid API key" } } }), default: {} };
    failAxios.default = failAxios;
    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), failAxios);

    try {
      await loaded.sendStaffInvitation(validData, { auth: mockAuth });
      expect.fail("Should have thrown");
    } catch (err) {
      expect(err.code).to.equal("internal");
      expect(err.message).to.include("Unable to send the invitation email");
    }

    // Staff record should be updated with failed status
    const staffDoc = makeDocRefWithGet("staff-001", {
      exists: true,
      data: () => ({ OwnerRef: { id: "owner-001" }, Email: "newstaff@pharmacy.com" }),
    });
    // invDoc.update should have been called with failed status
    expect(invDoc.update.called).to.be.true;
  });

  it("should throw when Resend API key is not configured", async function () {
    mockConfig = { resend: {}, app: { url: "https://thestackone.com/app.html" } };

    const invDoc = makeDocRef("inv-doc-id");
    invDoc.update = sinon.stub();
    const staffDoc = makeDocRefWithGet("staff-001", {
      exists: true,
      data: () => ({ OwnerRef: { id: "owner-001" }, Email: "newstaff@pharmacy.com" }),
    });
    staffDoc.update = sinon.stub();

    const mockAdmin = buildMockAdmin();
    mockAdmin.firestore.returns({
      collection: sinon.stub().callsFake((name) => {
        if (name === "Staff") return { doc: sinon.stub().returns(staffDoc), add: sinon.stub() };
        if (name === "StaffInvitations") return { doc: sinon.stub().returns(invDoc), add: sinon.stub().resolves(invDoc) };
        return { doc: sinon.stub().returns(makeDocRef("x")), add: sinon.stub().resolves({ id: "x" }) };
      }),
      doc: sinon.stub().callsFake((p) => makeDocRef(p.split("/").pop())),
      runTransaction: sinon.stub().callsFake(async (fn) => fn({ get: sinon.stub(), set: sinon.stub(), update: sinon.stub() })),
      FieldValue: { serverTimestamp: serverTimestampStub },
    });

    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), buildMockAxios());
    try {
      await loaded.sendStaffInvitation(validData, { auth: mockAuth });
      expect.fail("Should have thrown");
    } catch (err) {
      expect(err.code).to.equal("internal");
      expect(err.message).to.include("not configured");
    }
  });

  it("should set 7-day expiry on the invitation", async function () {
    mockConfig = {
      resend: { key: "re_test_key_12345", from: "Duniya <noreply@thestackone.com>" },
      app: { url: "https://thestackone.com/app.html" },
    };
    const invDoc = makeDocRef("inv-doc-id");
    invDoc.update = sinon.stub();

    const staffDoc = makeDocRefWithGet("staff-001", {
      exists: true,
      data: () => ({ OwnerRef: { id: "owner-001" }, Email: "newstaff@pharmacy.com" }),
    });
    staffDoc.update = sinon.stub();

    let createdInvitation = null;
    const mockAdmin = buildMockAdmin();
    mockAdmin.firestore.returns({
      collection: sinon.stub().callsFake((name) => {
        if (name === "Staff") return { doc: sinon.stub().returns(staffDoc), add: sinon.stub() };
        if (name === "StaffInvitations") return {
          doc: sinon.stub().returns(invDoc),
          add: sinon.stub().callsFake(async (data) => { createdInvitation = data; return invDoc; }),
        };
        if (name === "EmailLogs") return { doc: sinon.stub().returns(makeDocRef("log")), add: sinon.stub().resolves({ id: "log-id" }) };
        return makeCollectionMock();
      }),
      doc: sinon.stub().callsFake((p) => makeDocRef(p.split("/").pop())),
      runTransaction: sinon.stub().callsFake(async (fn) => fn({ get: sinon.stub(), set: sinon.stub(), update: sinon.stub() })),
      FieldValue: { serverTimestamp: serverTimestampStub },
    });

    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), buildMockAxios());
    await loaded.sendStaffInvitation(validData, { auth: mockAuth });

    expect(createdInvitation).to.not.be.null;
    expect(createdInvitation.token).to.be.a("string");
    expect(createdInvitation.token.length).to.equal(64);
    expect(createdInvitation.status).to.equal("pending");
    expect(createdInvitation.email).to.equal("newstaff@pharmacy.com");
    expect(createdInvitation.expiresAt).to.be.a("date");
    const sevenDaysMs = 7 * 24 * 60 * 60 * 1000;
    const diff = createdInvitation.expiresAt.getTime() - Date.now();
    expect(diff).to.be.greaterThan(sevenDaysMs - 60000);
    expect(diff).to.be.lessThan(sevenDaysMs + 60000);
  });
});

// ══════════════════════════════════════════════════════════════
//   verifyStaffInvitation tests
// ══════════════════════════════════════════════════════════════

describe("verifyStaffInvitation", function () {
  const mockAuth = {};

  it("should reject when token is missing", async function () {
    const mockAdmin = buildMockAdmin();
    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), buildMockAxios());
    try {
      await loaded.verifyStaffInvitation({ email: "a@b.com" }, mockAuth);
      expect.fail("Should have thrown");
    } catch (err) {
      expect(err.code).to.equal("invalid-argument");
    }
  });

  it("should reject when email is missing", async function () {
    const mockAdmin = buildMockAdmin();
    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), buildMockAxios());
    try {
      await loaded.verifyStaffInvitation({ token: "abc" }, mockAuth);
      expect.fail("Should have thrown");
    } catch (err) {
      expect(err.code).to.equal("invalid-argument");
    }
  });

  it("should return invalid when no matching invitation exists", async function () {
    const mockAdmin = buildMockAdmin();
    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), buildMockAxios());
    const result = await loaded.verifyStaffInvitation({ token: "nonexistent", email: "nobody@email.com" }, mockAuth);
    expect(result.valid).to.be.false;
    expect(result.reason).to.include("not found");
  });

  it("should return valid details for a matching pending invitation", async function () {
    const futureDate = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
    const mockDoc = {
      exists: true,
      data: () => ({
        name: "John Banda",
        role: "Cashier",
        pharmacyName: "MediCare Lusaka",
        pharmacyId: "pharm-001",
        email: "john@pharmacy.com",
        status: "pending",
        expiresAt: { toDate: () => futureDate },
      }),
    };

    const getStub = sinon.stub().resolves({ empty: false, docs: [mockDoc] });
    const limitStub = sinon.stub().returns({ get: getStub });
    const where3 = sinon.stub().returns({ limit: limitStub });
    const where2 = sinon.stub().returns({ where: where3 });
    const where1 = sinon.stub().returns({ where: where2 });

    const mockAdmin = buildMockAdmin();
    mockAdmin.firestore.returns({
      collection: sinon.stub().callsFake(() => ({
        doc: sinon.stub().callsFake((id) => makeDocRef(id)),
        add: sinon.stub().resolves({ id: "inv-id", update: sinon.stub() }),
        where: where1,
      })),
      doc: sinon.stub().callsFake((p) => makeDocRef(p.split("/").pop())),
      runTransaction: sinon.stub().callsFake(async (fn) => fn({ get: sinon.stub(), set: sinon.stub(), update: sinon.stub() })),
      FieldValue: { serverTimestamp: serverTimestampStub },
    });

    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), buildMockAxios());
    const result = await loaded.verifyStaffInvitation(
      { token: "valid-token", email: "john@pharmacy.com" },
      mockAuth
    );

    expect(result.valid).to.be.true;
    expect(result.name).to.equal("John Banda");
    expect(result.role).to.equal("Cashier");
    expect(result.pharmacyName).to.equal("MediCare Lusaka");
    expect(result.email).to.equal("john@pharmacy.com");
  });

  it("should return invalid for expired invitations", async function () {
    const pastDate = new Date(Date.now() - 1000);
    const mockDoc = {
      exists: true,
      data: () => ({
        name: "John",
        role: "Cashier",
        email: "john@pharmacy.com",
        status: "pending",
        expiresAt: { toDate: () => pastDate },
      }),
    };

    const getStub = sinon.stub().resolves({ empty: false, docs: [mockDoc] });
    const limitStub = sinon.stub().returns({ get: getStub });
    const where3 = sinon.stub().returns({ limit: limitStub });
    const where2 = sinon.stub().returns({ where: where3 });
    const where1 = sinon.stub().returns({ where: where2 });

    const mockAdmin = buildMockAdmin();
    mockAdmin.firestore.returns({
      collection: sinon.stub().callsFake(() => ({
        doc: sinon.stub().callsFake((id) => makeDocRef(id)),
        add: sinon.stub().resolves({ id: "inv-id", update: sinon.stub() }),
        where: where1,
      })),
      doc: sinon.stub().callsFake((p) => makeDocRef(p.split("/").pop())),
      runTransaction: sinon.stub().callsFake(async (fn) => fn({ get: sinon.stub(), set: sinon.stub(), update: sinon.stub() })),
      FieldValue: { serverTimestamp: serverTimestampStub },
    });

    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), buildMockAxios());
    const result = await loaded.verifyStaffInvitation(
      { token: "expired-token", email: "john@pharmacy.com" },
      mockAuth
    );

    expect(result.valid).to.be.false;
    expect(result.reason).to.include("expired");
  });
});

// ══════════════════════════════════════════════════════════════
//   completeStaffInvitation tests
// ══════════════════════════════════════════════════════════════

describe("completeStaffInvitation", function () {
  it("should reject unauthenticated requests", async function () {
    const mockAdmin = buildMockAdmin();
    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), buildMockAxios());
    try {
      await loaded.completeStaffInvitation({ invitationId: "inv-1" }, { auth: null });
      expect.fail("Should have thrown");
    } catch (err) {
      expect(err.code).to.equal("unauthenticated");
    }
  });

  it("should reject when invitationId is missing", async function () {
    const mockAdmin = buildMockAdmin();
    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), buildMockAxios());
    const ctx = { auth: { uid: "user-1", token: { email: "u@p.com" } } };
    try {
      await loaded.completeStaffInvitation({}, ctx);
      expect.fail("Should have thrown");
    } catch (err) {
      expect(err.code).to.equal("invalid-argument");
    }
  });

  it("should reject when invitation is not found", async function () {
    const mockAdmin = buildMockAdmin();
    const txStub = { get: sinon.stub().resolves({ exists: false }), set: sinon.stub(), update: sinon.stub() };
    mockAdmin.firestore.returns({
      collection: sinon.stub().callsFake(() => ({
        doc: sinon.stub().callsFake((id) => makeDocRef(id)),
        add: sinon.stub(),
      })),
      doc: sinon.stub().callsFake((p) => makeDocRef(p.split("/").pop())),
      runTransaction: sinon.stub().callsFake(async (fn) => fn(txStub)),
      FieldValue: { serverTimestamp: serverTimestampStub },
    });
    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), buildMockAxios());
    const ctx = { auth: { uid: "user-1", token: { email: "u@p.com" } } };
    try {
      await loaded.completeStaffInvitation({ invitationId: "inv-1" }, ctx);
      expect.fail("Should have thrown");
    } catch (err) {
      expect(err.code).to.equal("not-found");
    }
  });

  it("should reject when invitation is already accepted", async function () {
    const mockAdmin = buildMockAdmin();
    const txStub = {
      get: sinon.stub().resolves({
        exists: true,
        data: () => ({
          status: "accepted",
          email: "u@p.com",
          staffId: "staff-001",
          expiresAt: { toDate: () => new Date(Date.now() + 86400000) },
        }),
      }),
      set: sinon.stub(),
      update: sinon.stub(),
    };
    mockAdmin.firestore.returns({
      collection: sinon.stub().callsFake(() => ({
        doc: sinon.stub().callsFake((id) => makeDocRef(id)),
        add: sinon.stub(),
      })),
      doc: sinon.stub().callsFake((p) => makeDocRef(p.split("/").pop())),
      runTransaction: sinon.stub().callsFake(async (fn) => fn(txStub)),
      FieldValue: { serverTimestamp: serverTimestampStub },
    });
    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), buildMockAxios());
    const ctx = { auth: { uid: "user-1", token: { email: "u@p.com" } } };
    try {
      await loaded.completeStaffInvitation({ invitationId: "inv-1" }, ctx);
      expect.fail("Should have thrown");
    } catch (err) {
      expect(err.code).to.equal("failed-precondition");
    }
  });

  it("should reject when email does not match", async function () {
    const mockAdmin = buildMockAdmin();
    const txStub = {
      get: sinon.stub().resolves({
        exists: true,
        data: () => ({
          status: "pending",
          email: "correct@p.com",
          staffId: "staff-001",
          expiresAt: { toDate: () => new Date(Date.now() + 86400000) },
        }),
      }),
      set: sinon.stub(),
      update: sinon.stub(),
    };
    mockAdmin.firestore.returns({
      collection: sinon.stub().callsFake(() => ({
        doc: sinon.stub().callsFake((id) => makeDocRef(id)),
        add: sinon.stub(),
      })),
      doc: sinon.stub().callsFake((p) => makeDocRef(p.split("/").pop())),
      runTransaction: sinon.stub().callsFake(async (fn) => fn(txStub)),
      FieldValue: { serverTimestamp: serverTimestampStub },
    });
    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), buildMockAxios());
    const ctx = { auth: { uid: "user-1", token: { email: "wrong@p.com" } } };
    try {
      await loaded.completeStaffInvitation({ invitationId: "inv-1" }, ctx);
      expect.fail("Should have thrown");
    } catch (err) {
      expect(err.code).to.equal("permission-denied");
    }
  });

  it("should reject expired invitations", async function () {
    const mockAdmin = buildMockAdmin();
    const txStub = {
      get: sinon.stub().resolves({
        exists: true,
        data: () => ({
          status: "pending",
          email: "u@p.com",
          staffId: "staff-001",
          expiresAt: { toDate: () => new Date(Date.now() - 1000) },
        }),
      }),
      set: sinon.stub(),
      update: sinon.stub(),
    };
    mockAdmin.firestore.returns({
      collection: sinon.stub().callsFake(() => ({
        doc: sinon.stub().callsFake((id) => makeDocRef(id)),
        add: sinon.stub(),
      })),
      doc: sinon.stub().callsFake((p) => makeDocRef(p.split("/").pop())),
      runTransaction: sinon.stub().callsFake(async (fn) => fn(txStub)),
      FieldValue: { serverTimestamp: serverTimestampStub },
    });
    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), buildMockAxios());
    const ctx = { auth: { uid: "user-1", token: { email: "u@p.com" } } };
    try {
      await loaded.completeStaffInvitation({ invitationId: "inv-1" }, ctx);
      expect.fail("Should have thrown");
    } catch (err) {
      expect(err.code).to.equal("deadline-exceeded");
    }
  });

  it("should accept invitation and update staff record", async function () {
    const mockAdmin = buildMockAdmin();
    const txStub = {
      get: sinon.stub().resolves({
        exists: true,
        data: () => ({
          status: "pending",
          email: "u@p.com",
          staffId: "staff-001",
          expiresAt: { toDate: () => new Date(Date.now() + 86400000) },
        }),
      }),
      set: sinon.stub(),
      update: sinon.stub(),
    };
    mockAdmin.firestore.returns({
      collection: sinon.stub().callsFake(() => ({
        doc: sinon.stub().callsFake((id) => makeDocRef(id)),
        add: sinon.stub(),
      })),
      doc: sinon.stub().callsFake((p) => makeDocRef(p.split("/").pop())),
      runTransaction: sinon.stub().callsFake(async (fn) => fn(txStub)),
      FieldValue: { serverTimestamp: serverTimestampStub },
    });
    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), buildMockAxios());
    const ctx = { auth: { uid: "user-1", token: { email: "u@p.com" } } };

    const result = await loaded.completeStaffInvitation({ invitationId: "inv-1" }, ctx);
    expect(result.success).to.be.true;

    // Invitation updated to accepted
    expect(txStub.update.calledOnce).to.be.true;
    const invData = txStub.update.firstCall.args[1];
    expect(invData.status).to.equal("accepted");
    expect(invData.deliveryStatus).to.equal("accepted");
    expect(invData.acceptedByUid).to.equal("user-1");

    // Staff record set with merge
    expect(txStub.set.calledOnce).to.be.true;
    const staffData = txStub.set.firstCall.args[1];
    expect(staffData.invitationStatus).to.equal("accepted");
    expect(staffData.status).to.equal("active");
    expect(staffData.UserRef).to.not.be.undefined;
  });
});

// ══════════════════════════════════════════════════════════════
//   Email template content tests
// ══════════════════════════════════════════════════════════════

describe("Invitation email content", function () {
  function setupContentTest() {
    mockConfig = {
      resend: { key: "re_test_key_12345", from: "Duniya <noreply@thestackone.com>" },
      app: { url: "https://thestackone.com/app.html" },
    };

    const invDoc = makeDocRef("inv-doc-id");
    invDoc.update = sinon.stub();
    const staffDoc = makeDocRefWithGet("staff-001", {
      exists: true,
      data: () => ({ OwnerRef: { id: "owner-001" }, Email: "test@pharmacy.com" }),
    });
    staffDoc.update = sinon.stub();

    const mockAdmin = buildMockAdmin();
    mockAdmin.firestore.returns({
      collection: sinon.stub().callsFake((name) => {
        if (name === "Staff") return { doc: sinon.stub().returns(staffDoc), add: sinon.stub() };
        if (name === "StaffInvitations") return { doc: sinon.stub().returns(invDoc), add: sinon.stub().resolves(invDoc) };
        if (name === "EmailLogs") return { doc: sinon.stub().returns(makeDocRef("log")), add: sinon.stub().resolves({ id: "log-id" }) };
        return makeCollectionMock();
      }),
      doc: sinon.stub().callsFake((p) => makeDocRef(p.split("/").pop())),
      runTransaction: sinon.stub().callsFake(async (fn) => fn({ get: sinon.stub(), set: sinon.stub(), update: sinon.stub() })),
      FieldValue: { serverTimestamp: serverTimestampStub },
    });

    return { mockAdmin };
  }

  it("should include pharmacy name in subject and body", async function () {
    const { mockAdmin } = setupContentTest();
    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), buildMockAxios());

    await loaded.sendStaffInvitation(
      { staffId: "staff-001", email: "test@pharmacy.com", name: "Test User", role: "Pharmacist", pharmacyName: "SuperPharm Ndola", pharmacyId: "p2" },
      { auth: { uid: "owner-001" } }
    );

    const [, payload] = axiosPostStub.firstCall.args;
    expect(payload.subject).to.include("SuperPharm Ndola");
    expect(payload.html).to.include("SuperPharm Ndola");
    expect(payload.html).to.include("Pharmacist");
    expect(payload.html).to.include("Test User");
  });

  it("should handle empty pharmacy name gracefully", async function () {
    const { mockAdmin } = setupContentTest();
    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), buildMockAxios());

    await loaded.sendStaffInvitation(
      { staffId: "staff-001", email: "test@pharmacy.com", name: "Test User", role: "Cashier", pharmacyName: "", pharmacyId: "" },
      { auth: { uid: "owner-001" } }
    );

    const [, payload] = axiosPostStub.firstCall.args;
    expect(payload.html).to.include("a pharmacy");
  });

  it("should include Accept Invitation CTA button", async function () {
    const { mockAdmin } = setupContentTest();
    const loaded = loadFunctions(mockAdmin, buildMockFunctions(), buildMockAxios());

    await loaded.sendStaffInvitation(
      { staffId: "staff-001", email: "test@pharmacy.com", name: "Jane Doe", role: "Sales Assistant", pharmacyName: "HealthPlus", pharmacyId: "p3" },
      { auth: { uid: "owner-001" } }
    );

    const [, payload] = axiosPostStub.firstCall.args;
    expect(payload.html).to.include("Accept Invitation");
    expect(payload.html).to.include("Sales Assistant");
    expect(payload.html).to.include("Jane Doe");
  });
});
