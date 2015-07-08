'This sample shows how to use the WordWrap functionality

Import mojo2fontmachine

'Import mojo
Function Main()
	Local g:= New Game
End

Class Game Extends App

	Field font:BitmapFont
	
	'We use "wrappedtext" to handle wordwrap text:
	Field wrappedtext:WordWrappedText
	Field canvas:Canvas
	Method OnCreate()
		'SetUpdateRate(60)
		canvas = New Canvas
		font = New BitmapFont("smallfont.txt")
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
		wrappedtext.Width = 150
	End
	
	Method OnUpdate()
		'When A or S is pressed, we modify the wrap area width, so text is re-wrapped accordingly automatically
		If KeyDown(KEY_A) Then wrappedtext.Width += 5
		If KeyDown(KEY_S) Then wrappedtext.Width -= 5
	End
	
	Method OnRender()
		'We just render the whole thing:
		
		canvas.Reset()
		canvas.SetColor(0.7, 0.7, 0.7)
		canvas.DrawRect(0, 0, canvas.Width, canvas.Height)
				
		'Some instructions on screen:
		Local text:= "Press A or S to modify the wordwrapp area width ~n" +
					 "Text lines= " + wrappedtext.Lines + " Wrapped text lines = " + wrappedtext.WrappedLinesCount
		
		font.DrawText(text, 0, 0)
		
		
		'Now we render a background rectangle:
		canvas.SetColor(1, 1, 1)
		canvas.DrawRect(20, 40, wrappedtext.Width, 5000)
		canvas.SetColor(1, 1, 1)
		
		'And now we render the wrapped text:
		wrappedtext.Draw(20, 40, eDrawAlign.LEFT)
		canvas.Flush
	End
End