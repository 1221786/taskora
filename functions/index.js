const {onCall, HttpsError} = require('firebase-functions/v2/https');
const {defineSecret} = require('firebase-functions/params');
const {initializeApp} = require('firebase-admin/app');
const {getAuth} = require('firebase-admin/auth');
const {getFirestore, Timestamp, FieldValue} = require('firebase-admin/firestore');
const logger = require('firebase-functions/logger');
const crypto = require('node:crypto');
const sgMail = require('@sendgrid/mail');

initializeApp();
const db = getFirestore();
const sendgridKey = defineSecret('SENDGRID_API_KEY');
const codePepper = defineSecret('RESET_CODE_PEPPER');
const senderEmail = defineSecret('RESET_SENDER_EMAIL');
const genericResponse = {message: 'If this address is registered, a verification code has been sent.'};
const normalizeEmail = (value) => typeof value === 'string' ? value.trim().toLowerCase() : '';
const digest = (value) => crypto.createHash('sha256').update(value).digest('hex');
const codeDigest = (email, code) => crypto.createHmac('sha256', codePepper.value()).update(`${email}:${code}`).digest('hex');

exports.sendPasswordResetCode = onCall({secrets: [sendgridKey, codePepper, senderEmail], maxInstances: 5}, async (request) => {
  logger.info('sendPasswordResetCode started');
  let mailKey;
  let pepper;
  let fromAddress;
  try {
    mailKey = sendgridKey.value();
    pepper = codePepper.value();
    fromAddress = senderEmail.value();
  } catch (error) {
    logger.error('Password reset secrets could not be read', {message: error.message});
    throw new HttpsError('failed-precondition', 'Password reset email service is missing its Firebase secrets.');
  }
  if (!mailKey || !pepper || !fromAddress) {
    logger.error('Password reset email service has an empty secret', {
      hasSendgridKey: Boolean(mailKey),
      hasCodePepper: Boolean(pepper),
      hasSenderAddress: Boolean(fromAddress),
    });
    throw new HttpsError('failed-precondition', 'Password reset email service is missing its Firebase secrets.');
  }
  const email = normalizeEmail(request.data?.email);
  if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) throw new HttpsError('invalid-argument', 'Enter a valid email address.');

  // Apply a per-address cooldown before account lookup, including unknown addresses.
  const ref = db.collection('passwordResetChallenges').doc(digest(email));
  const now = Timestamp.now();
  const existing = await ref.get();
  if (existing.exists && existing.get('sentAt')?.toMillis() > now.toMillis() - 60_000) return genericResponse;

  let user;
  try { user = await getAuth().getUserByEmail(email); }
  catch (error) {
    if (error.code === 'auth/user-not-found') return genericResponse;
    logger.error('Password reset account lookup failed', {authErrorCode: error.code});
    throw new HttpsError('internal', 'Unable to send the verification code.');
  }
  logger.info('Password reset account lookup completed');

  const code = crypto.randomInt(0, 10000).toString().padStart(4, '0');
  const expiresAt = Timestamp.fromMillis(now.toMillis() + 10 * 60_000);
  await ref.set({email, uid: user.uid, codeHash: codeDigest(email, code), sentAt: now, expiresAt, attempts: 0, resetTicketHash: FieldValue.delete()}, {merge: true});
  logger.info('Reset code challenge stored; sending email');

  sgMail.setApiKey(mailKey);
  try {
    await sgMail.send({
      to: email,
      from: fromAddress,
      subject: 'Your Taskora password reset code',
      text: `Your Taskora verification code is ${code}. It expires in 10 minutes. If you did not request this, ignore this email.`,
      html: `<p>Your Taskora verification code is:</p><p style="font-size:28px;font-weight:bold;letter-spacing:8px">${code}</p><p>It expires in 10 minutes. If you did not request this, ignore this email.</p>`,
    });
  } catch (error) {
    await ref.delete().catch((cleanupError) => logger.error('Failed to clear unsent reset code', cleanupError));
    logger.error('Password reset email delivery failed', {
      statusCode: error.response?.statusCode,
      message: error.message,
    });
    throw new HttpsError('unavailable', 'Unable to send the code right now. Try again later.');
  }
  logger.info('Reset code email accepted by SendGrid');
  return genericResponse;
});

exports.verifyPasswordResetCode = onCall({secrets: [codePepper], maxInstances: 5}, async (request) => {
  logger.info('verifyPasswordResetCode started');
  const email = normalizeEmail(request.data?.email);
  const code = typeof request.data?.code === 'string' ? request.data.code.trim() : '';
  if (!/^\d{4}$/.test(code)) throw new HttpsError('invalid-argument', 'Enter the 4-digit code.');
  const ref = db.collection('passwordResetChallenges').doc(digest(email));
  const snap = await ref.get();
  const data = snap.data();
  if (!data || data.expiresAt.toMillis() < Date.now() || data.attempts >= 5) {
    logger.warn('Password reset code unavailable or expired');
    throw new HttpsError('failed-precondition', 'This code expired. Request a new one.');
  }
  const actual = Buffer.from(codeDigest(email, code));
  const expected = Buffer.from(data.codeHash);
  if (actual.length !== expected.length || !crypto.timingSafeEqual(actual, expected)) {
    await ref.update({attempts: FieldValue.increment(1)});
    logger.warn('Password reset code mismatch');
    throw new HttpsError('permission-denied', 'The code is incorrect. Check it and try again.');
  }
  const ticket = crypto.randomBytes(32).toString('base64url');
  await ref.update({codeHash: FieldValue.delete(), attempts: 5, resetTicketHash: digest(ticket), ticketExpiresAt: Timestamp.fromMillis(Date.now() + 5 * 60_000)});
  logger.info('Password reset code verified');
  return {resetTicket: ticket};
});

exports.completePasswordReset = onCall({maxInstances: 5}, async (request) => {
  logger.info('completePasswordReset started');
  const ticket = typeof request.data?.resetTicket === 'string' ? request.data.resetTicket : '';
  const password = typeof request.data?.password === 'string' ? request.data.password : '';
  if (password.length < 8) throw new HttpsError('invalid-argument', 'Password must be at least 8 characters.');
  const hash = digest(ticket);
  const ref = db.collection('passwordResetChallenges').doc(
    digest(normalizeEmail(request.data?.email)),
  );
  const user = await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const data = snap.data();
    if (!ticket || !data || data.resetTicketHash !== hash || !data.ticketExpiresAt || data.ticketExpiresAt.toMillis() < Date.now()) {
      throw new HttpsError('permission-denied', 'Verification expired. Request a new code.');
    }
    tx.delete(ref);
    return data.uid;
  });
  try {
    await getAuth().updateUser(user, {password});
  } catch (error) {
    logger.error('Firebase Auth password update failed', {authErrorCode: error.code, message: error.message});
    throw new HttpsError('internal', 'Firebase Authentication could not update the password.');
  }
  logger.info('Firebase Auth password updated');
  return {message: 'Password updated successfully.'};
});
