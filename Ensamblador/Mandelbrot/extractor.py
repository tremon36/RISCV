from PIL import Image, ImageDraw

# Gradient for colors

gradient = Image.open(r"gradient.png")
gradient_lut = list(gradient.getdata())
file_bytes = []

i = 0
while(i<len(gradient_lut)):
    r = round(gradient_lut[i][0] * (15/255));
    file_bytes = file_bytes + [r]
    i = i + 1

i = 0
while(i<len(gradient_lut)):
    r = round(gradient_lut[i][1] * (15/255));
    file_bytes = file_bytes + [r]
    i = i + 1

i = 0
while(i<len(gradient_lut)):
    r = round(gradient_lut[i][2] * (15/255));
    file_bytes = file_bytes + [r]
    i = i + 1





newFile = open("gradient.bin", "wb")
for byte in file_bytes:
    newFile.write(byte.to_bytes(1, byteorder='big'))







