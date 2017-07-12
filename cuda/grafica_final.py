from bokeh.plotting import figure, output_file, show
import csv


x1 = [1, 23, 33, 42, 52]   
y1 = [6, 7, 8, 7, 3]
    
print x1
print y1


output_file("grafica.html")

p = figure(plot_width=500, plot_height=400)

p.line(x1, y1, line_width=2,legend="sin memoria compartida", line_color="red")
p.circle(x1, y1, legend="sin memoria compartida",fill_color=None, line_color="red")


p.legend.location = "bottom_right"
p.legend.background_fill_color = "white"
p.legend.background_fill_alpha = 0.5


show(p)
