/**
 * Parses USN and extracts admission year, suffix, and entry type.
 * Returns null if validation fails.
 */
function parseUsn(usn) {
  if (!usn) return null;
  const upperUsn = usn.trim().toUpperCase();
  const validUsnRegex = /^4MW(\d{2})AI(\d{3})$/;
  const match = upperUsn.match(validUsnRegex);

  if (!match) {
    return null; // Failed validation
  }

  const admissionYY = match[1];
  const suffix = match[2];
  const entryType = suffix.startsWith('4') ? 'lateral_diploma' : 'regular';

  return {
    usn: upperUsn,
    admissionYY,
    suffix,
    entryType,
    configKey: `${admissionYY}_${entryType}`
  };
}

export default parseUsn;
