extends Node
class_name ImageIncoder

export var Img : Image = Image.new()
export var Bitmap : BitMap = BitMap.new()
var Imap : IntMap = IntMap.new()
var Smap : StringMap = StringMap.new()

var Buffer : Array
var BufferLimit := 64
var BufferWarning := true

func GenrateBitmap(trueColor : Color, thershold := 64, Invers := false):
	var size := Img.get_size()

	BufferResource(Smap.duplicate())

	Bitmap.create(size)
	Img.lock()
	yield(get_tree(), "idle_frame")
	for x in size.x:
		if x != 0 and x % 32 == 0:
			yield(get_tree(), "idle_frame")

		for y in size.y:
			Bitmap.set_bit(Vector2(x, y), Utils.AproxEquallToColorAlpha( trueColor, Img.get_pixel(x, y), Color(thershold, thershold, thershold, thershold) ) != Invers)
	Img.unlock()
	pass

func GenrateStringmap(palet : Dictionary, thershold := Color8(64, 64, 64, 64)):
	var size := Img.get_size()

	BufferResource(Smap.duplicate())
	for i in palet:
		if palet[i] is Array:
			palet[i] = Utils.Array2ColorA(palet[i]) / 255.0

	yield(get_tree(), "idle_frame")
	Smap.Create(size)
	Img.lock()
	yield(get_tree(), "idle_frame")

	for x in size.x:
		if x != 0 and x % 32 == 0:
			yield(get_tree(), "idle_frame")

		for y in size.y:
			var c : Color = Img.get_pixel(x, y)
			var Found := false

			for i in palet:

				if palet[i] is Color:
					if Utils.AproxEquallToColorAlpha( palet[i], c, thershold ):
						Smap.SetString(x, y, i)
						Found = true
						break

				if palet[i] is Array:

					var p := Utils.Array2ColorA(palet[i])
					if Utils.AproxEquallToColorAlpha( p, c, thershold ):
						Smap.SetString(x, y, i)
						Found = true
						break


			if Found:
				continue

			Smap.SetString(x, y, "_")


	Img.unlock()

func GenrateIntmap(palet : Dictionary, thershold := Color(64, 64, 64, 64)):
	var size := Img.get_size()
	for i in palet:
		if palet[i] is Array:
			palet[i] = Utils.Array2ColorA(palet[i]) / 255.0
	var p_palet := {}
	for i in palet:
		if !Utils.isNum(i):
			palet.erase(i)
			continue
		p_palet[int(i)] = palet[i]
	palet = p_palet

	BufferResource(Imap.duplicate())

	yield(get_tree(), "idle_frame")

	Imap.Create(size)
	Img.lock()
	yield(get_tree(), "idle_frame")
	for x in size.x:
		if x != 0 and x % 32 == 0:
			yield(get_tree(), "idle_frame")

		for y in size.y:
			var c : Color = Img.get_pixel(x, y)
			var Found := false

			for i in palet:

				if palet[i] is Color:

					if Utils.AproxEquallToColorAlpha( palet[i], c, thershold ):
						Imap.SetInt(x, y, i)
						Found = true
						break

				if palet[i] is Array:
					var p := Utils.Array2ColorA(palet[i])
					if Utils.AproxEquallToColorAlpha( p, c, thershold ):
						Imap.SetInt(x, y, i)
						Found = true
						break

			if Found:
				continue

			Imap.SetInt(x, y, -Utils.MAXI)
	Img.unlock()

func BufferResource(res : Reference):
	Buffer.append(res)

	if BufferWarning:
		if Buffer.size() > 10:
			if Buffer.size() > 24:
				if Buffer.size() > 48:
					if Buffer.size() > 96:
						Reporter.Report("BufferInurmesOverflow: buffer size has past 48, has a sever impact on performance. \n\t Wow, this pc survived this much with that huge buffer, Clearing buffer")
						return
					Reporter.Report("BufferExteremOverflow: buffer size has past 48, has a sever impact on performance.\n\t this may be a bug or the acts of mods.")
					return
				Reporter.Report("BufferSeverOverflow: buffer size has past 24, has a minor impact on performance.")
				return
			Reporter.Report("BufferMinorOverflow: buffer size has past 10, has a little impact on performance.", 1)

	if Buffer.size() > BufferLimit and BufferLimit > 0:
		Buffer.erase(Buffer.size() - 1)

