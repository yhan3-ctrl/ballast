"""Build the submission report from GDD.md; never fabricates publication links."""
from pathlib import Path
import re, html
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'output/pdf/Ballast-Game-Design-Report-Yu-Han.pdf'
OUT.parent.mkdir(parents=True, exist_ok=True)
styles=getSampleStyleSheet()
styles.add(ParagraphStyle(name='BodyReport',fontName='Helvetica',fontSize=10.5,leading=15,spaceAfter=9,textColor=colors.HexColor('#21343c')))
styles.add(ParagraphStyle(name='TableReport',fontName='Helvetica',fontSize=9,leading=12,spaceAfter=0))
styles.add(ParagraphStyle(name='SmallReport',fontName='Helvetica',fontSize=9,leading=12,textColor=colors.HexColor('#526970'),spaceAfter=8))
for key in ['Heading1','Heading2','Heading3']:
 styles[key].textColor=colors.HexColor('#125b64')
 styles[key].spaceBefore=12;styles[key].spaceAfter=10
styles['Heading1'].fontSize=23;styles['Heading1'].leading=28
styles['Heading2'].fontSize=17;styles['Heading2'].leading=21
styles['Heading3'].fontSize=12;styles['Heading3'].leading=16

def fmt(s):
 s=s.replace('—','-').replace('–','-').replace('“','"').replace('”','"').replace('’',"'").replace('韩玉','Han Yu').replace('玉','jade').replace('鱼','fish')
 s=html.escape(s)
 s=re.sub(r'\*\*(.+?)\*\*',r'<b>\1</b>',s)
 s=re.sub(r'\*(.+?)\*',r'<i>\1</i>',s)
 s=re.sub(r'`(.+?)`',r'<font name="Courier">\1</font>',s)
 s=re.sub(r'(https://[^\s<]+)',r'<link href="\1" color="#126e85">\1</link>',s)
 return s

def para(s,style='BodyReport'): return Paragraph(fmt(s),styles[style])
lines=(ROOT/'GDD.md').read_text().splitlines();story=[];i=0
breaks={'## 2. Concept, genre and background','### Pearls and score','## 3. What I want the player to learn','## 5. Mechanics and rules','### Light, Glimmer and coral','## 6. How the three levels build on each other','## 7. Design schemas','## 8. Animation and sound','### How the design changed','## 10. Builds and verification'}
while i<len(lines):
 l=lines[i].strip()
 if not l: i+=1;continue
 if l in breaks: story.append(PageBreak())
 if l.startswith('|'):
  rows=[]
  while i<len(lines) and lines[i].strip().startswith('|'):
   cells=[c.strip() for c in lines[i].strip().strip('|').split('|')]
   if not all(re.fullmatch(r'[-: ]+',c) for c in cells): rows.append([para(c,'TableReport') for c in cells])
   i+=1
  n=len(rows[0]);widths={2:[125,379],3:[135,230,139]}.get(n,[504/n]*n)
  t=Table(rows,colWidths=widths,repeatRows=1,hAlign='LEFT')
  t.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),colors.HexColor('#dceef0')),('VALIGN',(0,0),(-1,-1),'TOP'),('LEFTPADDING',(0,0),(-1,-1),8),('RIGHTPADDING',(0,0),(-1,-1),8),('TOPPADDING',(0,0),(-1,-1),7),('BOTTOMPADDING',(0,0),(-1,-1),7),('LINEBELOW',(0,0),(-1,-1),.4,colors.HexColor('#c4d5d8'))]))
  story.extend([t,Spacer(1,12)]);continue
 if l.startswith('#'):
  count=len(l)-len(l.lstrip('#'));story.append(para(l[count:].strip(),'Heading'+str(min(count,3))));i+=1;continue
 parts=[l];i+=1
 while i<len(lines) and lines[i].strip() and not lines[i].startswith(('#','|')): parts.append(lines[i].strip());i+=1
 story.append(para(' '.join(parts)))
def footer(c,doc):
 c.setStrokeColor(colors.HexColor('#aac7cd'));c.line(54,43,558,43)
 c.setFont('Helvetica',8);c.setFillColor(colors.HexColor('#526970'));c.drawString(54,30,'BALLAST  /  YU HAN  /  CSCI 5999B');c.drawRightString(558,30,str(doc.page))
SimpleDocTemplate(str(OUT),pagesize=(612,792),rightMargin=54,leftMargin=54,topMargin=40,bottomMargin=58,title='Ballast - My Game Design Report',author='Yu Han').build(story,onFirstPage=footer,onLaterPages=footer)
print(OUT)
