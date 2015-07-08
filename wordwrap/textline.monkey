#REM monkeydoc module fontmachine.wordwrap.textline
	This module contains the TextLine class. 
	This class handles the creation of [txtinterval] instances to handle wordwrapping of strings in FontMachine.
#END
Import intervalslist
Import fontmachine
#REM monkeydoc
	This class represents a line of text that needs to be wordwrapped. It's internally used by the [[WordWrappedText]] component.
#END
Class TextLine

	#rem monkeydoc
		This field contains the string that will be wordwrapped.
	#END
	Field text:String
	#rem monkeydoc
		This field contains the list of intervals that represent the wordwrapping of the [[text]]
	#END
	Field Intervals:= New IntervalsList
	
	#rem monkeydoc
		This method return the number of text lines that are created after the wordwrap operation.
	#END
	Method Lines:Int()
		Return intervalsCount
	End
	
	#rem monkeydoc
		This method calculates wordwrap on current [[text]].
		This method does not create any substring so it's fast.
	#END
	Method AdjustLine(font:bitmapfont.BitmapFont, maxwidth:Int)
		Local tokeninit:Int = 0
		Local linestart:Int = 0
		Local linesize:Int = 0
		Local previousIsSeparator:Bool = False
		Intervals.Clear()
		intervalsCount = 0
		For Local i:Int = 0 Until text.Length
			Local char:Int = text[i]
			
			'This calculates the drawing VISUAL size, but not spacing (kerning, overlapping of chars, etc.)
			Local tokensize:Int = font.GetTxtWidth(text, tokeninit + 1, i + 1) '- font.GetTxtWidth(text, i, i)

			If (char >= "a"[0] And char <= "z"[0]) or (char >= "A"[0] And char <= "Z"[0]) or (char >= "0"[0] And char <= "9"[0]) or (char = "_"[0]) Then
				If previousIsSeparator Then
					previousIsSeparator = False
					linesize += GetTxtSpacing(text, font, tokeninit, i)
					tokeninit = i
					tokensize = font.GetTxtWidth(text, tokeninit + 1, i + 1) '- font.GetTxtWidth(text, i, i)
				EndIf
			Else
				'This calculates text spacing:
				tokensize = GetTxtSpacing(text, font, tokeninit, i)
				linesize += tokensize
				tokeninit = i  	'We begin next token
				
				'tokensize = 0	'No token, it was a separator
				tokensize = font.GetTxtWidth(text, tokeninit + 1, i + 1) '- font.GetTxtWidth(text, i, i)
				previousIsSeparator = True
				
			EndIf
			
			
			If linesize + tokensize > maxwidth Then	'Slip the line!
				AddInterval(linestart, tokeninit)	'previous line starts BEFORE splitting token
				linesize = 0
				linestart = tokeninit	'next line Starts at spliting token
			End
			
		Next
		AddInterval(linestart, text.Length)	'previous line starts BEFORE splitting token
		
	End
	
	Private
	Method GetTxtSpacing:Int(text:String, font:BitmapFont, init:Int, ending:Int)
		Local size:Int = 0
		For Local i:Int = init Until Min(ending, text.Length)
			Local charinfo:= font.GetFaceInfo(text[i])
			If charinfo = Null Continue
			size += charinfo.drawingWidth + font.Kerning.x
		Next
		Return size
	End
	Method AddInterval(linestart:Int, length:Int)
		Intervals.AddInterval(linestart, length)	'previous line starts BEFORE splitting token
		intervalsCount += 1
	End
	Field intervalsCount:Int = 0
End


