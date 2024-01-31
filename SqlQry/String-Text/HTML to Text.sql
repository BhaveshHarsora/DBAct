/*
BH20230926 : UDF Convert HTML text to Plain text
*/

GO
CREATE OR ALTER FUNCTION dbo.udf_StripHTML
(
	@pHTMLText varchar(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @vStart INT, @vEnd INT, @vLength INT;

	SET @pHTMLText = REPLACE(@pHTMLText, '<br>',CHAR(13) + CHAR(10))
	SET @pHTMLText = REPLACE(@pHTMLText, '<br/>',CHAR(13) + CHAR(10))
	SET @pHTMLText = REPLACE(@pHTMLText, '<br />',CHAR(13) + CHAR(10))
	SET @pHTMLText = REPLACE(@pHTMLText, '<li>','- ')
	SET @pHTMLText = REPLACE(@pHTMLText, '</li>',CHAR(13) + CHAR(10))

	SET @pHTMLText = REPLACE(@pHTMLText, '&rsquo;' COLLATE Latin1_General_CS_AS, ''''  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&quot;' COLLATE Latin1_General_CS_AS, '"'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&amp;' COLLATE Latin1_General_CS_AS, '&'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&euro;' COLLATE Latin1_General_CS_AS, '€'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&lt;' COLLATE Latin1_General_CS_AS, '<'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&gt;' COLLATE Latin1_General_CS_AS, '>'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&oelig;' COLLATE Latin1_General_CS_AS, 'oe'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&nbsp;' COLLATE Latin1_General_CS_AS, ' '  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&copy;' COLLATE Latin1_General_CS_AS, '©'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&laquo;' COLLATE Latin1_General_CS_AS, '«'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&reg;' COLLATE Latin1_General_CS_AS, '®'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&plusmn;' COLLATE Latin1_General_CS_AS, '±'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&sup2;' COLLATE Latin1_General_CS_AS, '²'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&sup3;' COLLATE Latin1_General_CS_AS, '³'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&micro;' COLLATE Latin1_General_CS_AS, 'µ'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&middot;' COLLATE Latin1_General_CS_AS, '·'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&ordm;' COLLATE Latin1_General_CS_AS, 'º'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&raquo;' COLLATE Latin1_General_CS_AS, '»'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&frac14;' COLLATE Latin1_General_CS_AS, '¼'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&frac12;' COLLATE Latin1_General_CS_AS, '½'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&frac34;' COLLATE Latin1_General_CS_AS, '¾'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&Aelig' COLLATE Latin1_General_CS_AS, 'Æ'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&Ccedil;' COLLATE Latin1_General_CS_AS, 'Ç'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&Egrave;' COLLATE Latin1_General_CS_AS, 'È'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&Eacute;' COLLATE Latin1_General_CS_AS, 'É'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&Ecirc;' COLLATE Latin1_General_CS_AS, 'Ê'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&Ouml;' COLLATE Latin1_General_CS_AS, 'Ö'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&agrave;' COLLATE Latin1_General_CS_AS, 'à'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&acirc;' COLLATE Latin1_General_CS_AS, 'â'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&auml;' COLLATE Latin1_General_CS_AS, 'ä'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&aelig;' COLLATE Latin1_General_CS_AS, 'æ'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&ccedil;' COLLATE Latin1_General_CS_AS, 'ç'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&egrave;' COLLATE Latin1_General_CS_AS, 'è'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&eacute;' COLLATE Latin1_General_CS_AS, 'é'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&ecirc;' COLLATE Latin1_General_CS_AS, 'ê'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&euml;' COLLATE Latin1_General_CS_AS, 'ë'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&icirc;' COLLATE Latin1_General_CS_AS, 'î'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&ocirc;' COLLATE Latin1_General_CS_AS, 'ô'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&ouml;' COLLATE Latin1_General_CS_AS, 'ö'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&divide;' COLLATE Latin1_General_CS_AS, '÷'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&oslash;' COLLATE Latin1_General_CS_AS, 'ø'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&ugrave;' COLLATE Latin1_General_CS_AS, 'ù'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&uacute;' COLLATE Latin1_General_CS_AS, 'ú'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&ucirc;' COLLATE Latin1_General_CS_AS, 'û'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&uuml;' COLLATE Latin1_General_CS_AS, 'ü'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&quot;' COLLATE Latin1_General_CS_AS, '"'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&amp;' COLLATE Latin1_General_CS_AS, '&'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&lsaquo;' COLLATE Latin1_General_CS_AS, '<'  COLLATE Latin1_General_CS_AS)
	SET @pHTMLText = REPLACE(@pHTMLText, '&rsaquo;' COLLATE Latin1_General_CS_AS, '>'  COLLATE Latin1_General_CS_AS)


	-- Remove anything between <STYLE> tags
	SET @vStart = CHARINDEX('<STYLE', @pHTMLText)
	SET @vEnd = CHARINDEX('</STYLE>', @pHTMLText, CHARINDEX('<', @pHTMLText)) + 7
	SET @vLength = (@vEnd - @vStart) + 1

	WHILE (@vStart > 0 AND @vEnd > 0 AND @vLength > 0) BEGIN
		SET @pHTMLText = STUFF(@pHTMLText, @vStart, @vLength, '')
		SET @vStart = CHARINDEX('<STYLE', @pHTMLText)
		SET @vEnd = CHARINDEX('</STYLE>', @pHTMLText, CHARINDEX('</STYLE>', @pHTMLText)) + 7
		SET @vLength = (@vEnd - @vStart) + 1
	END

	-- Remove anything between <whatever> tags
	SET @vStart = CHARINDEX('<', @pHTMLText)
	SET @vEnd = CHARINDEX('>', @pHTMLText, CHARINDEX('<', @pHTMLText))
	SET @vLength = (@vEnd - @vStart) + 1

	WHILE (@vStart > 0 AND @vEnd > 0 AND @vLength > 0) BEGIN
		SET @pHTMLText = STUFF(@pHTMLText, @vStart, @vLength, '')
		SET @vStart = CHARINDEX('<', @pHTMLText)
		SET @vEnd = CHARINDEX('>', @pHTMLText, CHARINDEX('<', @pHTMLText))
		SET @vLength = (@vEnd - @vStart) + 1
	END

	RETURN LTRIM(RTRIM(@pHTMLText));

END;
GO

GO
----------------------------------------------
-- Example:
----------------------------------------------
DECLARE @vHtmlText AS NVARCHAR(MAX);

SET @vHtmlText = '<html xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word" xmlns:m="http://schemas.microsoft.com/office/2004/12/omml" xmlns="http://www.w3.org/TR/REC-html40"><head><META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=us-ascii"><meta name=Generator content="Microsoft Word 14 (filtered medium)"><!--[if !mso]><style>v\:* {behavior:url(#default#VML);}   o\:* {behavior:url(#default#VML);}   w\:* {behavior:url(#default#VML);}   ..shape {behavior:url(#default#VML);}   </style><![endif]--><style><!--   /* Font Definitions */   @font-face    {font-family:Helvetica;    panose-1:2 11 6 4 2 2 2 2 2 4;}   @font-face    {font-family:Helvetica;    panose-1:2 11 6 4 2 2 2 2 2 4;}   @font-face    {font-family:Calibri;    panose-1:2 15 5 2 2 2 4 3 2 4;}   @font-face    {font-family:Tahoma;    panose-1:2 11 6 4 3 5 4 4 2 4;}   @font-face    {font-family:"Bookman Old Style";    panose-1:2 5 6 4 5 5 5 2 2 4;}   @font-face    {font-family:"Bradley Hand ITC";    panose-1:3 7 4 2 5 3 2 3 2 3;}   @font-face    {font-family:"Brush Script MT";    panose-1:3 6 8 2 4 4 6 7 3 4;}   @font-face    {font-family:Perpetua;    panose-1:2 2 5 2 6 4 1 2 3 3;}   /* Style Definitions */   p.MsoNormal, li.MsoNormal, div.MsoNormal    {margin:0in;    margin-bottom:.0001pt;    font-size:11.0pt;    font-family:"Calibri","sans-serif";}   a:link, span.MsoHyperlink    {mso-style-priority:99;    color:blue;    text-decoration:underline;}   a:visited, span.MsoHyperlinkFollowed    {mso-style-priority:99;    color:purple;    text-decoration:underline;}   p.MsoAcetate, li.MsoAcetate, div.MsoAcetate    {mso-style-priority:99;    mso-style-link:"Balloon Text Char";    margin:0in;    margin-bottom:.0001pt;    font-size:8.0pt;    font-family:"Tahoma","sans-serif";}   span.EmailStyle17    {mso-style-type:personal-compose;    font-family:"Calibri","sans-serif";    color:windowtext;}   span.BalloonTextChar    {mso-style-name:"Balloon Text Char";    mso-style-priority:99;    mso-style-link:"Balloon Text";    font-family:"Tahoma","sans-serif";}   ..MsoChpDefault    {mso-style-type:export-only;    font-family:"Calibri","sans-serif";}   @page WordSection1    {size:8.5in 11.0in;    margin:1.0in 1.0in 1.0in 1.0in;}   div.WordSection1    {page:WordSection1;}   --></style><!--[if gte mso 9]><xml>   <o:shapedefaults v:ext="edit" spidmax="1026" />   </xml><![endif]--><!--[if gte mso 9]><xml>   <o:shapelayout v:ext="edit">   <o:idmap v:ext="edit" data="1" />   </o:shapelayout></xml><![endif]--></head><body lang=EN-US link=blue vlink=purple><div class=WordSection1><p class=MsoNormal><o:p> </o:p></p><p class=MsoNormal><o:p> </o:p></p><p class=MsoNormal><b><i><span style=''font-size:16.0pt;font-family:"Bookman Old Style","serif";color:red''>Please note we moved:</span></i></b><b><i><span style=''font-size:16.0pt;font-family:"Bradley Hand ITC";color:red''>  </span></i></b>15 Boutwell St. San Francisco Ca. 94124<o:p></o:p></p><p class=MsoNormal><b><i><span style=''font-size:16.0pt;font-family:"Bookman Old Style","serif";color:red''><o:p> </o:p></span></i></b></p><p class=MsoNormal><b><i><span style=''font-size:16.0pt;font-family:"Bookman Old Style","serif";color:#4F81BD''>Thx&#8230;</span></i></b><b><span style=''font-size:16.0pt;font-family:"Bookman Old Style","serif";color:#4F81BD''><o:p></o:p></span></b></p><p class=MsoNormal><b><u><span style=''font-family:"Bookman Old Style","serif";color:#4F81BD''><o:p><span style=''text-decoration:none''> </span></o:p></span></u></b></p><p class=MsoNormal><b><i><u><span style=''font-size:9.0pt;font-family:"Bookman Old Style","serif";color:#4F81BD''>Please Keep In mind that we also carry GE, CUTLER HAMMER(WESTINGHOUSE, EATON), SIEMENS, SQD&#8230;TRANSFORMERS , FUSES, MOTOR CONTROLS, DISCONNECTS AND BUSWAY PRODUCTS.<o:p></o:p></span></u></i></b></p><p class=MsoNormal><b><i><u><span style=''font-family:"Perpetua","serif";color:red''><o:p><span style=''text-decoration:none''> </span></o:p></span></u></i></b></p><p class=MsoNormal><span style=''font-size:14.0pt;font-family:"Bookman Old Style","serif"''>Napoleon Esparrago<o:p></o:p></span></p><p class=MsoNormal><img width=225 height=56 id="Picture_x0020_1" src="cid:image001.png@01D2505C.87B2EFF0"><span style=''color:red''><o:p></o:p></span></p><p class=MsoNormal><span style=''color:navy''><o:p> </o:p></span></p><p class=MsoNormal>15 Boutwell St. San Francisco Ca. 94124<o:p></o:p></p><p class=MsoNormal><span style=''font-family:"Bookman Old Style","serif"''>800.390.3299   X 302<o:p></o:p></span></p><p class=MsoNormal><span style=''font-family:"Bookman Old Style","serif"''>415.699.6975 Cell Phone<o:p></o:p></span></p><p class=MsoNormal><span style=''font-family:"Bookman Old Style","serif"''>650.692.0711   FAX</span><span style=''font-family:"Bradley Hand ITC"''><o:p></o:p></span></p><p class=MsoNormal><i><u><span style=''font-size:12.0pt;font-family:"Bookman Old Style","serif";color:#1F497D''><a href="mailto:po@livewiresupply.com"><span style=''color:blue''>po@livewiresupply.com</span></a><o:p></o:p></span></u></i></p><p class=MsoNormal><i><u><span style=''font-size:12.0pt;font-family:"Bookman Old Style","serif";color:#1F497D''><o:p><span style=''text-decoration:none''> </span></o:p></span></u></i></p><p class=MsoNormal><span style=''font-size:8.5pt;color:#215868''>LiveWire Supply&#8217;s Mission: Provide superior products quickly at below market prices to help our customer&#8217;s maintain their competitive advantage. </span><o:p></o:p></p><p class=MsoNormal><i><u><span style=''font-size:12.0pt;font-family:"Bookman Old Style","serif";color:#1F497D''><o:p><span style=''text-decoration:none''> </span></o:p></span></u></i></p><p class=MsoNormal style=''mso-margin-top-alt:auto;mso-margin-bottom-alt:auto''><b><i><span style=''font-size:16.0pt;font-family:"Brush Script MT";color:#1F497D''>The Internet''s #1 electrical supply house.<o:p></o:p></span></i></b></p><p class=MsoNormal><span style=''font-size:7.5pt;font-family:"Courier New","serif";color:black''>This email and any attachments thereto may contain private, confidential, and privileged material for the sole use of the intended recipient.  Any review, copying, or distribution of this email (or any attachments thereto) by others is strictly prohibited.  If you are not the intended recipient, please contact the sender immediately and permanently delete the original and any copies of this email and any attachments thereto.</span><span style=''font-size:9.0pt;font-family:"Helvetica","sans-serif";color:black''><o:p></o:p></span></p><p class=MsoNormal><o:p> </o:p></p></div></body></html>'

SELECT dbo.udf_StripHtml(@vHtmlText);

----------------------------------------------

GO