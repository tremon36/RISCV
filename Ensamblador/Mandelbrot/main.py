from PIL import Image, ImageDraw
from fractal import compute, MAX_ITER

# Gradient for colors

gradient = Image.open(r"gradient.png")
gradient_lut = list(gradient.getdata())
print(gradient_lut)

# Image size (pixels)
WIDTH = 5760
HEIGHT = 3840

# Plot window
RE_START = -2
RE_END = 1
IM_START = -1
IM_END = 1

palette = []

im = Image.new('RGB', (WIDTH, HEIGHT), (0, 0, 0))
draw = ImageDraw.Draw(im)

for x in range(0, WIDTH):
    for y in range(0, HEIGHT):
        # Convert pixel coordinate to complex number
        c = complex(RE_START + (x / WIDTH) * (RE_END - RE_START),
                    IM_START + (y / HEIGHT) * (IM_END - IM_START))
        # Compute the number of iterations
        m = compute(c)
        # Plot the point
        draw.point([x, y], (gradient_lut[m][0], gradient_lut[m][1], gradient_lut[m][2]))

im.save('output4.png', 'PNG')
