/**
 * Loads an event and applies the "coordinator = own events only" rule (spec §5/§7).
 * Returns { event } on success or { status, error } to send back.
 */
export async function getEventForStaff(db, eventId, req) {
  if (!eventId || typeof eventId !== 'string') {
    return { status: 400, error: '"eventId" is required.' };
  }

  const snap = await db.collection('events').doc(eventId).get();
  if (!snap.exists) {
    return { status: 404, error: 'Event not found.' };
  }

  const event = snap.data();
  if (req.role === 'coordinator' && event.createdBy !== req.uid) {
    return { status: 403, error: 'Coordinators can only do this for events they created.' };
  }

  return { event };
}
