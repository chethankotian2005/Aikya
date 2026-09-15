import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ASSETS_DIR = path.join(__dirname, '..', '..', 'assets');
const SEAL_PATH = path.join(ASSETS_DIR, 'sode-group-seal.png');
const LOGO_PATH = path.join(ASSETS_DIR, 'smvitm-logo.jpeg');

const INSTITUTE_NAME = 'SHRI MADHWA VADIRAJA INSTITUTE OF TECHNOLOGY AND MANAGEMENT';
const INSTITUTE_LINE_2 = "An Autonomous Institute Affiliated to VTU, Belagavi — A Unit of Shri Sode Vadiraja Mutt Education Trust®, Udupi";
const INSTITUTE_LINE_3 = "Approved by AICTE, New Delhi | Accredited by NAAC with 'A' Grade";
const INSTITUTE_ADDRESS = 'Vishwothama Nagar, Bantakal – 574115, Udupi District, Karnataka';
const DEPT_FOOTER = 'Tel: 7483031199 | 0820-2589182/9183, EXT:267 | Email: ml@sode-edu.in | Web: sode-edu.in/SMVITM/departments/artificial-intelligence-and-machine-learning';
const DEPT_NAME = 'DEPARTMENT OF ARTIFICIAL INTELLIGENCE AND MACHINE LEARNING';

// Matches the department's official letterhead (institute seal, name,
// accreditation line, address in the header; department contact info in
// the footer) — every generated PDF (event report, accreditation
// compilation) should look like an official department document, not a
// plain markdown dump. See /template refference.docx for the source.
//
// PDFKit's 'pageAdded' event fires *during* internal pagination — drawing
// flowing/wrapping text from inside that handler risks triggering another
// page break mid-draw, which corrupts PDFKit's internal state (observed:
// "Maximum call stack size exceeded"). The documented-safe pattern is to
// buffer all pages, draw the body with no header awareness, then make a
// second pass over every already-created page stamping the letterhead on
// each — see stampLetterheadOnAllPages() below.
export const PDF_MARGINS = { top: 135, bottom: 75, left: 60, right: 60 };

export function createLetterheadDoc(PDFDocument, { title, author = 'AIKYA — AI & ML Department' } = {}) {
  return new PDFDocument({
    size: 'A4',
    margins: PDF_MARGINS,
    bufferPages: true,
    info: { Title: title, Author: author, Creator: 'AIKYA' },
  });
}

function drawHeaderFooter(doc) {
  const { width, margins } = doc.page;
  const contentWidth = width - margins.left - margins.right;

  try {
    doc.image(SEAL_PATH, margins.left, 20, { width: 46 });
  } catch { /* asset missing — header text still renders */ }
  try {
    doc.image(LOGO_PATH, width - margins.right - 46, 20, { width: 46 });
  } catch { /* asset missing — header text still renders */ }

  doc
    .fontSize(11)
    .font('Helvetica-Bold')
    .fillColor('#0E1B3D')
    .text(INSTITUTE_NAME, margins.left + 52, 18, { width: contentWidth - 104, align: 'center', lineBreak: true });
  doc
    .fontSize(7)
    .font('Helvetica')
    .fillColor('#4A5A7A')
    .text(INSTITUTE_LINE_2, margins.left + 52, 44, { width: contentWidth - 104, align: 'center', lineBreak: true })
    .text(INSTITUTE_LINE_3, margins.left + 52, 58, { width: contentWidth - 104, align: 'center', lineBreak: true })
    .text(INSTITUTE_ADDRESS, margins.left + 52, 70, { width: contentWidth - 104, align: 'center', lineBreak: true });

  doc.moveTo(margins.left, 95).lineTo(width - margins.right, 95).strokeColor('#1F5C99').lineWidth(1).stroke();

  const footerRuleY = doc.page.height - margins.bottom + 18;
  doc.moveTo(margins.left, footerRuleY).lineTo(width - margins.right, footerRuleY).strokeColor('#1F5C99').lineWidth(0.5).stroke();

  // Drawing text below page.height - margins.bottom otherwise silently
  // triggers PDFKit's auto-page-break (it treats that as overflow), which
  // sends the footer onto a *new* blank page instead of this one. Shrink
  // the bottom margin just for this call so PDFKit sees it as in-bounds.
  const originalBottom = doc.page.margins.bottom;
  doc.page.margins.bottom = 0;
  doc
    .fontSize(7)
    .font('Helvetica')
    .fillColor('#4A5A7A')
    .text(DEPT_FOOTER, margins.left, footerRuleY + 6, { width: contentWidth, align: 'center', lineBreak: true });
  doc.page.margins.bottom = originalBottom;
}

/**
 * Call once, right before doc.end() — stamps the letterhead on every page
 * that already exists (requires the doc to have been created with
 * bufferPages: true). Safe: no drawing here can trigger a new page.
 */
export function stampLetterheadOnAllPages(doc) {
  const range = doc.bufferedPageRange();
  for (let i = range.start; i < range.start + range.count; i++) {
    doc.switchToPage(i);
    drawHeaderFooter(doc);
  }
}

/** Draws the standard "DEPARTMENT OF ..." + document title block. Call once, right after creating the doc. */
export function drawDocumentTitle(doc, documentTitle, subtitle) {
  doc.y = 110;
  doc.x = doc.page.margins.left;
  doc.fontSize(13).font('Helvetica-Bold').fillColor('#0E1B3D').text(DEPT_NAME, { align: 'center' });
  doc.moveDown(0.4);
  doc.fontSize(18).font('Helvetica-Bold').fillColor('#0E1B3D').text(documentTitle, { align: 'center' });
  if (subtitle) {
    doc.moveDown(0.2);
    doc.fontSize(11).font('Helvetica').fillColor('#1F5C99').text(subtitle, { align: 'center' });
  }
  doc.moveDown(1.2);
  doc.fillColor('#0E1B3D');
}

/** Renders simple markdown (#/##/###, -/*, blank lines, plain paragraphs) into the current doc. */
export function renderMarkdownBody(doc, markdownText) {
  for (const line of markdownText.split('\n')) {
    const trimmed = line.trim();

    if (trimmed.startsWith('### ')) {
      doc.moveDown(0.5);
      doc.fontSize(12).font('Helvetica-Bold').text(trimmed.slice(4));
      doc.moveDown(0.2);
    } else if (trimmed.startsWith('## ')) {
      doc.moveDown(0.7);
      doc.fontSize(14).font('Helvetica-Bold').text(trimmed.slice(3));
      doc.moveDown(0.3);
    } else if (trimmed.startsWith('# ')) {
      doc.addPage();
      doc.fontSize(17).font('Helvetica-Bold').text(trimmed.slice(2));
      doc.moveDown(0.5);
    } else if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
      doc.fontSize(10.5).font('Helvetica').text(`  •  ${trimmed.slice(2)}`, { indent: 16 });
    } else if (trimmed === '') {
      doc.moveDown(0.4);
    } else {
      doc.fontSize(10.5).font('Helvetica').text(trimmed, { align: 'justify', lineGap: 3 });
    }
  }
}
