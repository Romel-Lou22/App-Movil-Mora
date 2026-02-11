"""
Generador simple de PDF para DOCUMENTATION.md
Genera DOCUMENTATION.pdf en la raíz del repo.
Requiere: reportlab, markdown, beautifulsoup4
Instalación (PowerShell):
    python -m pip install --user reportlab markdown beautifulsoup4
Ejecución (PowerShell):
    python .\scripts\generate_documentation_pdf.py
"""
from pathlib import Path
from markdown import markdown
from bs4 import BeautifulSoup
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
from reportlab.lib.pagesizes import A4
from reportlab.lib.units import mm


def md_to_pdf(md_path: Path, pdf_path: Path):
    md_text = md_path.read_text(encoding='utf-8')

    # Convertir MD a HTML
    html = markdown(md_text)

    # Parsear HTML
    soup = BeautifulSoup(html, 'html.parser')

    # Preparar documento
    doc = SimpleDocTemplate(str(pdf_path), pagesize=A4,
                            leftMargin=20*mm, rightMargin=20*mm,
                            topMargin=20*mm, bottomMargin=20*mm)

    styles = getSampleStyleSheet()
    normal = styles['BodyText']
    normal.fontSize = 10
    normal.leading = 13

    h1 = ParagraphStyle('Heading1', parent=styles['Heading1'], fontSize=18, leading=22)
    h2 = ParagraphStyle('Heading2', parent=styles['Heading2'], fontSize=14, leading=18)
    h3 = ParagraphStyle('Heading3', parent=styles['Heading3'], fontSize=12, leading=15)

    flowables = []

    # Mapear bloques HTML a flowables simples
    for elem in soup.find_all(['h1', 'h2', 'h3', 'p', 'ul', 'ol']):
        if elem.name == 'h1':
            flowables.append(Paragraph(elem.get_text(), h1))
            flowables.append(Spacer(1, 6))
        elif elem.name == 'h2':
            flowables.append(Paragraph(elem.get_text(), h2))
            flowables.append(Spacer(1, 4))
        elif elem.name == 'h3':
            flowables.append(Paragraph(elem.get_text(), h3))
            flowables.append(Spacer(1, 3))
        elif elem.name == 'p':
            txt = elem.get_text()
            flowables.append(Paragraph(txt, normal))
            flowables.append(Spacer(1, 4))
        elif elem.name in ('ul', 'ol'):
            # procesar cada <li>
            for li in elem.find_all('li'):
                bullet = '• ' if elem.name == 'ul' else '1. '
                text = f"{bullet}{li.get_text()}"
                flowables.append(Paragraph(text, normal))
            flowables.append(Spacer(1, 4))

    # Footer: fuente del documento
    flowables.append(Spacer(1, 12))
    flowables.append(Paragraph('Generado desde DOCUMENTATION.md', styles['Italic']))

    doc.build(flowables)


if __name__ == '__main__':
    repo_root = Path(__file__).resolve().parent.parent
    md_path = repo_root / 'DOCUMENTATION.md'
    pdf_path = repo_root / 'DOCUMENTATION.pdf'

    if not md_path.exists():
        print(f'DOCUMENTATION.md no encontrado en: {md_path}')
    else:
        print(f'Generando PDF: {pdf_path} ...')
        try:
            md_to_pdf(md_path, pdf_path)
            print('PDF generado correctamente.')
        except Exception as e:
            print('Error generando PDF:', e)

