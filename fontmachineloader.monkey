Import bitmapfont
Interface FontLoader
	Method Load:Bool(font:BitmapFont, documentPath:String, dynamicLoad:Bool)
	Method FontLoaderName:String()
End


Class FontMachineLoader Implements FontLoader
	Method Load:Bool(font:BitmapFont, documentPath:String, dynamicLoad:Bool)

		If documentPath.ToLower().EndsWith(".txt") = False Then Return False
		Local text:String = LoadString(documentPath)
		If text = "" Then Return False 'Print "FONT " + documentPath + " WAS NOT FOUND!!!"
		Local result:= LoadFontData(font, text, documentPath, dynamicLoad)

		If result Then
			Return True
		Else

			'Free resources created by the failed load attempt:
			For Local chr:= EachIn font.borderChars
				If chr.image <> Null Then chr.image.Discard()
			Next
		
			For Local chr:= EachIn font.faceChars
				If chr.image <> Null Then chr.image.Discard()
			Next
		
			For Local chr:= EachIn font.shadowChars
				If chr.image <> Null Then chr.image.Discard()
			Next
			
			For Local image:= EachIn font.packedImages
				image.Discard
			Next
		
			font.borderChars.Resize(0)
			font.faceChars.Resize(0)
			font.shadowChars.Resize(0)
			
			Return False
		EndIf
	End

	Method Load:Bool(font:BitmapFont, documentPath:String)
		Return Load(font, documentPath, False)
	End
	
	
	Method FontLoaderName:String()
		'Just a random GUID
		Return "8f7fab4e-b003-45f2-b252-a03f0e129a8f"
	End
	
	Private
	
	Method LoadFontData:Bool(font:BitmapFont, Info:String, fontName:String, dynamicLoad:bool)
		If Info.StartsWith("P1") Then
			Return LoadPacked(font, Info, fontName, dynamicLoad)
			 
		EndIf
		Local tokenStream:String[] = Info.Split(",")
		Local index:Int = 0
		font.borderChars = New BitMapChar[65536]
		font.faceChars = New BitMapChar[65536]
		font.shadowChars = New BitMapChar[65536]

		Local prefixName:String = fontName
		if prefixName.ToLower().EndsWith(".txt") Then prefixName = prefixName[..-4]
		
		Local char:Int = 0
		while index<tokenStream.Length
			'We get char to load:
			Local strChar:String = tokenStream[index]
			if strChar.Trim() = "" Then
				'Print "This is going to fail..."
				index+=1
				Exit
			endif
			char = int(strChar)
			'Print "Loading char: " + char + " at index: " + index
			index+=1
			
			Local kind:String = tokenStream[index]
			'Print "Found kind= " + kind
			index +=1
			
			Select kind
				Case "{BR"
					index+=3 '3 control point for future use
					font.borderChars[char] = New BitMapChar
					font.borderChars[char].drawingMetrics.drawingOffset.x = Int(tokenStream[index])
					font.borderChars[char].drawingMetrics.drawingOffset.y = Int(tokenStream[index + 1])
					font.borderChars[char].drawingMetrics.drawingSize.x = Int(tokenStream[index + 2])
					font.borderChars[char].drawingMetrics.drawingSize.y = Int(tokenStream[index + 3])
					font.borderChars[char].drawingMetrics.drawingWidth = Int(tokenStream[index + 4])
					If dynamicLoad = False Then
						'Print("Set handle 2")
						font.borderChars[char].image = Image.Load(prefixName + "_BORDER_" + char + ".png")
						font.borderChars[char].image.SetHandle(-font.borderChars[char].drawingMetrics.drawingOffset.x, -font.borderChars[char].drawingMetrics.drawingOffset.y)
						font.borderChars[char].drawingMetrics.drawingOffset.Set(-font.borderChars[char].image.HandleX, -font.borderChars[char].image.HandleX)
						font.borderChars[char].image.SetHandle(0, 0)
					Else
						font.borderChars[char].SetImageResourceName prefixName + "_BORDER_" + char + ".png"
					endif
					index+=5
					index+=1 ' control point for future use

				Case "{SH"
					index+=3 '3 control point for future use
					font.shadowChars[char] = New BitMapChar
					font.shadowChars[char].drawingMetrics.drawingOffset.x = Int(tokenStream[index])
					font.shadowChars[char].drawingMetrics.drawingOffset.y = Int(tokenStream[index + 1])
					font.shadowChars[char].drawingMetrics.drawingSize.x = Int(tokenStream[index + 2])
					font.shadowChars[char].drawingMetrics.drawingSize.y = Int(tokenStream[index + 3])
					font.shadowChars[char].drawingMetrics.drawingWidth = Int(tokenStream[index + 4])
					Local filename:String = prefixName + "_SHADOW_" + char + ".png"
					If dynamicLoad = False Then
						'Print("Set handle 3")
						font.shadowChars[char].image = Image.Load(filename)
						font.shadowChars[char].image.SetHandle(-font.shadowChars[char].drawingMetrics.drawingOffset.x, -font.shadowChars[char].drawingMetrics.drawingOffset.y)
						font.shadowChars[char].drawingMetrics.drawingOffset.Set(-font.shadowChars[char].image.HandleX, -font.shadowChars[char].image.HandleX)
						font.shadowChars[char].image.SetHandle(0, 0)
					Else
						font.shadowChars[char].SetImageResourceName filename
					endif

					
					'shadowChars[char].image = LoadImage(filename)
					'shadowChars[char].image.SetHandle(-shadowChars[char].drawingMetrics.drawingOffset.x,-shadowChars[char].drawingMetrics.drawingOffset.y)

					index+=5
					index+=1 ' control point for future use
					
				Case "{FC"
					index+=3 '3 control point for future use
					font.faceChars[char] = New BitMapChar
					font.faceChars[char].drawingMetrics.drawingOffset.x = Int(tokenStream[index])
					font.faceChars[char].drawingMetrics.drawingOffset.y = Int(tokenStream[index + 1])
					font.faceChars[char].drawingMetrics.drawingSize.x = Int(tokenStream[index + 2])
					font.faceChars[char].drawingMetrics.drawingSize.y = Int(tokenStream[index + 3])
					font.faceChars[char].drawingMetrics.drawingWidth = Int(tokenStream[index + 4])
					If dynamicLoad = False Then
						'Print("Set handle 4")
						font.faceChars[char].image = Image.Load(prefixName + "_" + char + ".png")
						font.faceChars[char].image.SetHandle(-font.faceChars[char].drawingMetrics.drawingOffset.x, -font.faceChars[char].drawingMetrics.drawingOffset.y)
						font.faceChars[char].drawingMetrics.drawingOffset.Set(-font.faceChars[char].image.HandleX, -font.faceChars[char].image.HandleX)
						font.faceChars[char].image.SetHandle(0, 0)
						
					Else
						font.faceChars[char].SetImageResourceName prefixName + "_" + char + ".png"
					endif
					index+=5
					index+=1 ' control point for future use

				Default
					'Print "Error loading font! Char = " + char
					Return False
				
			End
		Wend
		font.borderChars = font.borderChars[ .. char + 1]
		font.faceChars = font.faceChars[ .. char + 1]
		font.shadowChars = font.shadowChars[ .. char + 1]
		Return True
	End

		
	Method LoadPacked:Bool(tmpFont:BitmapFont, info:String, fontName:String, dynamicLoad:bool)
		
		Local header:String = info[ .. info.Find(",")]
		
		Local separator:String
		Select header
			Case "P1"
				separator = "."
			Case "P1.01"
				separator = "_P_"
			Default
				Return False
		End Select
		info = info[info.Find(",")+1..]
		tmpFont.borderChars = New BitMapChar[65536]
		tmpFont.faceChars = New BitMapChar[65536]
		tmpFont.shadowChars = New BitMapChar[65536]

		tmpFont.packedImages = New Image[256]
		Local maxPacked:Int = 0
		Local maxChar:Int = 0

		Local prefixName:String = fontName
		if prefixName.ToLower().EndsWith(".txt") Then prefixName = prefixName[..-4]

		Local charList:string[] = info.Split(";")
		Local LoadingKerning:Bool = False
		For Local chr:String = EachIn charList

			Local chrdata:string[] = chr.Split(",")
			if chrdata.Length() <2 Then Exit
			Local char:bitmapchar.BitMapChar
			Local currentData:= chrdata[0]
			If currentData = "{KP" Then
				Print("Loading kerning!")
				LoadingKerning = True
			EndIf
			If LoadingKerning
				If currentData = "KP}" Then
					LoadingKerning = False
				ElseIf currentData = "{KP" Then
					'Do nothing
				Else
					Local charIndex:Int = int(chrdata[0])
					Local curChar:BitMapChar = tmpFont.faceChars[charIndex]
					If curChar <> Null Then curChar.DefineKerningPair(Int(chrdata[1]), Int(chrdata[2]))
				EndIf
			Else
				Local charIndex:Int = int(chrdata[0])
				If maxChar < charIndex Then maxChar = charIndex
			
				select chrdata[1]
					Case "B"
						tmpFont.borderChars[charIndex] = New BitMapChar
						char = tmpFont.borderChars[charIndex]
					Case "F"
						tmpFont.faceChars[charIndex] = New BitMapChar
						char = tmpFont.faceChars[charIndex]
					Case "S"
						tmpFont.shadowChars[charIndex] = New BitMapChar
						char = tmpFont.shadowChars[charIndex]
					Case "{KP"
					
				End Select
				char.packedFontIndex = Int(chrdata[2])
				If tmpFont.packedImages[char.packedFontIndex] = Null Then
					'Print("No handle set here.")
					tmpFont.packedImages[char.packedFontIndex] = Image.Load(prefixName + separator + char.packedFontIndex + ".png")
					if maxPacked<char.packedFontIndex Then maxPacked = char.packedFontIndex
				endif
				char.packedPosition.x = Int(chrdata[3])
				char.packedPosition.y = Int(chrdata[4])
				char.packedSize.x = Int(chrdata[5])
				char.packedSize.y = Int(chrdata[6])
				char.drawingMetrics.drawingOffset.x = Int(chrdata[8])
				char.drawingMetrics.drawingOffset.y = Int(chrdata[9])
				char.drawingMetrics.drawingSize.x = Int(chrdata[10])
				char.drawingMetrics.drawingSize.y = Int(chrdata[11])
				char.drawingMetrics.drawingWidth = Int(chrdata[12])
			EndIf

		Next
		tmpFont.borderChars = tmpFont.borderChars[ .. maxChar + 1]
		tmpFont.faceChars = tmpFont.faceChars[ .. maxChar + 1]
		tmpFont.shadowChars = tmpFont.shadowChars[ .. maxChar + 1]
		tmpFont.packedImages = tmpFont.packedImages[ .. maxPacked + 1]
		Return True
	end

	
End

