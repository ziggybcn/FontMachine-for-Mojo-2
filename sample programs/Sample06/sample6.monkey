'This sample shows how to use the WordWrap functionality to scroll text up/down of a wordwrap area

Import mojo2fontmachine

'Import mojo
Function Main()
	Local g:= New Game
End

Class Game Extends App

	Field font:BitmapFont
	
	'We use "wrappedtext" to handle wordwrap text:
	Field wrappedtext:WordWrappedText
	
	Field startingLine:Float = 0

	Field canvas:Canvas
	
	Method OnCreate()
		'SetUpdateRate(60)
		canvas = New Canvas
		font = New BitmapFont("ZooSmall.txt")
		font.DrawingTarget = canvas
		
		'We load the text we're going to use for this sample:
		Local text:= LoadString("sampletext.txt")
		If text = "" Then Error("Could not load text!")

		'We create a new WrappedText area:
		wrappedtext = New WordWrappedText

		'We set the WrappedText area its font (so it can calculate wraping):
		wrappedtext.Font = font

		'We set it the text to show wrapped:
		wrappedtext.Text = text
		
		'We give it a default a width to calculate wrapping:
		wrappedtext.Width = 600
	End
	
	Method OnUpdate()
		'When A or S is pressed, we modify the startingLine variable. This will be used on the rendering to scroll up/down the text.
		If KeyDown(KEY_A) Then startingLine -= 1
		If KeyDown(KEY_S) Then startingLine += 1
		If KeyHit(KEY_K) Then font.UseKPairs = Not font.UseKPairs
		If startingLine < 0 Then startingLine = 0
	End
	
	Method OnRender()
	
		Const LinesToShow:Int = 10
		'We just render the whole thing:
		
		canvas.Reset()
		canvas.SetColor(0.7, 0.7, 0.7)
		canvas.DrawRect(0, 0, canvas.Width, canvas.Height)

		font.DrawText("Press A or S to scroll up/down", DeviceWidth / 2, 0, eDrawAlign.CENTER)
				
		'Now we render a background rectangle:
		canvas.SetColor(0.7, 0.7, 0.7)
		canvas.DrawRect(20, 40, wrappedtext.Width, LinesToShow * font.GetFontHeight)
		canvas.SetColor(1, 1, 1)
		
		'And now we render the wrapped text starting by the "startingLine" line. That's how we get scrolling!
		wrappedtext.PartialDraw(startingLine, LinesToShow, 20, 40, eDrawAlign.LEFT)
		
		'We show some additional information in a sort of footer:
		font.DrawText("Showing lines " + startingLine + " to " + (startingLine + LinesToShow) + " of " + wrappedtext.WrappedLinesCount, DeviceWidth / 2, 400, eDrawAlign.CENTER)
		Local txt:= ""
		If font.UseKPairs Then
			txt = "Kerning mode ON"
		Else
			txt = "Kerning mode OFF"
		EndIf
		font.DrawText(txt, DeviceWidth / 2, 380, eDrawAlign.CENTER)
		canvas.Flush()
	End
End